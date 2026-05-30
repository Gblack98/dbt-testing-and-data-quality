-- test_not_null_ratio.sql
-- Generic test: checks that the null ratio does not exceed a threshold
-- Usage in schema.yml:
--   tests:
--     - not_null_ratio:
--         max_ratio: 0.05   # max 5% nulls allowed

{% test not_null_ratio(model, column_name, max_ratio=0.05) %}

with base as (
    select
        count(*)                                    as total_rows,
        count({{ column_name }})                    as non_null_rows,
        count(*) - count({{ column_name }})         as null_rows
    from {{ model }}
),

validation as (
    select
        total_rows,
        null_rows,
        case
            when total_rows = 0 then 0
            else null_rows::decimal / total_rows
        end                                         as null_ratio
    from base
)

select *
from validation
where null_ratio > {{ max_ratio }}

{% endtest %}
