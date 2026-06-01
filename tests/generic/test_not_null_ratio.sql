-- test_not_null_ratio.sql
-- Test générique : vérifie que le ratio de nulls ne dépasse pas un seuil
-- Usage dans schema.yml :
--   tests:
--     - not_null_ratio:
--         max_ratio: 0.05   # max 5% de nulls

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
