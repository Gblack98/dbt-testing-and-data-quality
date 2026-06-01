-- test_row_count_min.sql
-- Test générique : vérifie qu'une table a au moins N lignes
-- Usage :
--   tests:
--     - row_count_min:
--         min_rows: 100

{% test row_count_min(model, min_rows=1) %}

with counts as (
    select count(*) as total_rows
    from {{ model }}
)

select total_rows
from counts
where total_rows < {{ min_rows }}

{% endtest %}
