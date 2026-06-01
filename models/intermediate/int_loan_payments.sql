-- int_loan_payments.sql
-- Agrégation des paiements par prêt

with transactions as (
    select * from {{ ref('stg_transactions') }}
),

loans as (
    select * from {{ ref('stg_loans') }}
),

payment_summary as (
    select
        t.loan_id,
        count(*)                                            as total_transactions,
        count(case when transaction_status = 'success' then 1 end) as successful_payments,
        count(case when transaction_status = 'failed'  then 1 end) as failed_payments,
        coalesce(sum(case when transaction_status = 'success' then amount_xof end), 0)
                                                            as total_paid_xof,
        max(case when transaction_status = 'success' then transaction_date end)
                                                            as last_payment_date,
        min(transaction_date)                               as first_payment_date
    from transactions
    group by t.loan_id
),

enriched as (
    select
        l.loan_id,
        l.customer_id,
        l.loan_amount_xof,
        l.total_amount_due_xof,
        l.monthly_installment_xof,
        l.loan_status,
        l.loan_type,
        l.disbursement_date,
        l.due_date,
        l.term_months,
        l.interest_rate_pct,
        coalesce(p.total_paid_xof, 0)                       as total_paid_xof,
        coalesce(p.successful_payments, 0)                  as successful_payments,
        coalesce(p.failed_payments, 0)                      as failed_payments,
        coalesce(p.total_transactions, 0)                   as total_transactions,
        p.last_payment_date,
        p.first_payment_date,
        -- Montant restant dû
        greatest(l.total_amount_due_xof - coalesce(p.total_paid_xof, 0), 0)
                                                            as outstanding_balance_xof,
        -- Ratio de remboursement
        case
            when l.total_amount_due_xof > 0
            then round(coalesce(p.total_paid_xof, 0) / l.total_amount_due_xof * 100, 2)
            else 0
        end                                                 as repayment_ratio_pct,
        -- Score de paiement (0-100)
        case
            when coalesce(p.total_transactions, 0) = 0 then 50
            else round(
                coalesce(p.successful_payments, 0)::decimal /
                coalesce(p.total_transactions, 1) * 100, 2
            )
        end                                                 as payment_reliability_score
    from loans l
    left join payment_summary p on l.loan_id = p.loan_id
)

select * from enriched
