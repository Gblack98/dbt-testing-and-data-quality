-- assert_credit_score_bounds.sql
-- Test singulier : tous les credit scores doivent être entre 300 et 850

select
    customer_id,
    credit_score
from {{ ref('mart_customer_credit_profile') }}
where credit_score < 300
   or credit_score > 850
