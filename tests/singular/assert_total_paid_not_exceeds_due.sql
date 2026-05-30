-- assert_total_paid_not_exceeds_due.sql
-- Singular test: total amount paid must not exceed total amount due
-- (1% tolerance for rounding errors)

select
    loan_id,
    total_paid_xof,
    total_amount_due_xof,
    round(total_paid_xof / total_amount_due_xof * 100, 2) as paid_ratio
from {{ ref('int_loan_payments') }}
where total_paid_xof > total_amount_due_xof * 1.01   -- 1% tolerance
  and loan_status != 'repaid'
