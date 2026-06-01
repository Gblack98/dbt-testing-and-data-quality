-- test_column_sum_positive.sql
-- Test générique : vérifie que la somme d'une colonne est positive
-- Utile pour valider les montants financiers agrégés

{% test column_sum_positive(model, column_name) %}

with aggregated as (
    select sum({{ column_name }}) as total
    from {{ model }}
)

select total
from aggregated
where total is null or total <= 0

{% endtest %}
