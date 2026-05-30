-- assert_credit_score_bounds.sql
-- Singular test: all credit scores must be between 300 and 850

select
    customer_id,
    credit_score
from {{ ref('mart_customer_credit_profile') }}
where credit_score < 300
   or credit_score > 850
