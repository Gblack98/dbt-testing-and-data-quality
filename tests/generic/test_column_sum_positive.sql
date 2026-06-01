-- test_column_sum_positive.sql
-- Generic test: checks that the sum of a column is positive
-- Useful for validating aggregated financial amounts

{% test column_sum_positive(model, column_name) %}

with aggregated as (
    select sum({{ column_name }}) as total
    from {{ model }}
)

select total
from aggregated
where total is null or total <= 0

{% endtest %}
