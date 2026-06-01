-- mart_loan_risk_dashboard.sql
-- Dashboard de risque par portefeuille de prêts

with loan_payments as (
    select * from {{ ref('int_loan_payments') }}
),

customers as (
    select customer_id, income_segment, country_code, risk_category
    from {{ ref('mart_customer_credit_profile') }}
),

final as (
    select
        lp.loan_id,
        lp.customer_id,
        lp.loan_type,
        lp.loan_status,
        lp.loan_amount_xof,
        lp.total_amount_due_xof,
        lp.total_paid_xof,
        lp.outstanding_balance_xof,
        lp.repayment_ratio_pct,
        lp.payment_reliability_score,
        lp.successful_payments,
        lp.failed_payments,
        lp.interest_rate_pct,
        lp.term_months,
        lp.disbursement_date,
        lp.due_date,
        lp.last_payment_date,

        c.income_segment,
        c.country_code,
        c.risk_category,

        -- Jours depuis le dernier paiement
        case
            when lp.last_payment_date is not null
            then current_date - lp.last_payment_date
            else null
        end                                                 as days_since_last_payment,

        -- Statut de retard
        case
            when lp.loan_status = 'defaulted'               then 'defaulted'
            when lp.loan_status = 'repaid'                  then 'current'
            when current_date > lp.due_date                 then 'overdue'
            when lp.last_payment_date is null
              and current_date > lp.disbursement_date + 35  then 'first_payment_missed'
            else 'current'
        end                                                 as payment_status,

        -- Niveau de provision (% à provisionner selon le risque)
        case
            when lp.loan_status = 'defaulted'              then 1.00
            when current_date > lp.due_date                then 0.50
            when lp.payment_reliability_score < 50         then 0.25
            when lp.payment_reliability_score < 70         then 0.10
            else 0.00
        end                                                 as provision_rate,

        -- Montant à provisionner
        round(
            lp.outstanding_balance_xof * case
                when lp.loan_status = 'defaulted'          then 1.00
                when current_date > lp.due_date            then 0.50
                when lp.payment_reliability_score < 50     then 0.25
                when lp.payment_reliability_score < 70     then 0.10
                else 0.00
            end, 2
        )                                                   as provision_amount_xof,

        current_timestamp                                   as _loaded_at

    from loan_payments lp
    left join customers c on lp.customer_id = c.customer_id
)

select * from final
