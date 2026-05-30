-- assert_no_defaulted_active_loans.sql
-- Singular test: an active loan cannot have a repayment_ratio > 100%
-- (overpayment would indicate inconsistent data)

select
    loan_id,
    loan_status,
    repayment_ratio_pct
from {{ ref('int_loan_payments') }}
where loan_status = 'active'
  and repayment_ratio_pct > 100
