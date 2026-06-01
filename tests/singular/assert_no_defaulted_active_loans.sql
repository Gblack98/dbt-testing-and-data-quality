-- assert_no_defaulted_active_loans.sql
-- Test singulier : un prêt ne peut pas être à la fois 'active' ET avoir
-- un repayment_ratio > 100% (surpaiement incohérent)

select
    loan_id,
    loan_status,
    repayment_ratio_pct
from {{ ref('int_loan_payments') }}
where loan_status = 'active'
  and repayment_ratio_pct > 100
