-- mart_customer_credit_profile.sql
-- Profil crédit complet par client (table finale pour BI / scoring)

with customers as (
    select * from {{ ref('stg_customers') }}
),

loan_payments as (
    select * from {{ ref('int_loan_payments') }}
),

customer_loans as (
    select
        customer_id,
        count(*)                                            as total_loans,
        count(case when loan_status = 'active'    then 1 end) as active_loans,
        count(case when loan_status = 'repaid'    then 1 end) as repaid_loans,
        count(case when loan_status = 'defaulted' then 1 end) as defaulted_loans,
        sum(loan_amount_xof)                                as total_borrowed_xof,
        sum(total_paid_xof)                                 as total_repaid_xof,
        sum(outstanding_balance_xof)                        as total_outstanding_xof,
        avg(interest_rate_pct)                              as avg_interest_rate,
        avg(payment_reliability_score)                      as avg_payment_score,
        sum(failed_payments)                                as total_failed_payments,
        max(last_payment_date)                              as last_payment_date
    from loan_payments
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.country_code,
        c.age,
        c.income_monthly_xof,
        c.income_segment,
        c.customer_since,
        c.is_active,

        -- Métriques de prêts
        coalesce(cl.total_loans, 0)                         as total_loans,
        coalesce(cl.active_loans, 0)                        as active_loans,
        coalesce(cl.repaid_loans, 0)                        as repaid_loans,
        coalesce(cl.defaulted_loans, 0)                     as defaulted_loans,
        coalesce(cl.total_borrowed_xof, 0)                  as total_borrowed_xof,
        coalesce(cl.total_repaid_xof, 0)                    as total_repaid_xof,
        coalesce(cl.total_outstanding_xof, 0)               as total_outstanding_xof,
        cl.avg_interest_rate,
        coalesce(cl.avg_payment_score, 0)                   as avg_payment_score,
        coalesce(cl.total_failed_payments, 0)               as total_failed_payments,
        cl.last_payment_date,

        -- Ratio dette/revenu (DTI)
        case
            when c.income_monthly_xof > 0
            then round(
                coalesce(cl.total_outstanding_xof, 0) /
                (c.income_monthly_xof * 12) * 100, 2
            )
            else null
        end                                                 as debt_to_income_ratio,

        -- Catégorie de risque
        case
            when coalesce(cl.defaulted_loans, 0) > 0          then 'high_risk'
            when coalesce(cl.avg_payment_score, 100) < 70     then 'medium_risk'
            when coalesce(cl.total_loans, 0) = 0              then 'no_history'
            else 'low_risk'
        end                                                 as risk_category,

        -- Score crédit simplifié (300-850)
        least(850, greatest(300,
            300
            + (coalesce(cl.avg_payment_score, 50) * 2)
            + (coalesce(cl.repaid_loans, 0) * 20)
            - (coalesce(cl.defaulted_loans, 0) * 100)
            - (coalesce(cl.total_failed_payments, 0) * 5)
        ))::integer                                         as credit_score,

        current_timestamp                                   as _loaded_at

    from customers c
    left join customer_loans cl on c.customer_id = cl.customer_id
)

select * from final
