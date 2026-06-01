-- assert_total_paid_not_exceeds_due.sql
-- Test singulier : le montant total payé ne doit pas dépasser le montant dû
-- (avec une tolérance de 1% pour arrondi)

select
    loan_id,
    total_paid_xof,
    total_amount_due_xof,
    round(total_paid_xof / total_amount_due_xof * 100, 2) as paid_ratio
from {{ ref('int_loan_payments') }}
where total_paid_xof > total_amount_due_xof * 1.01   -- tolérance 1%
  and loan_status != 'repaid'
