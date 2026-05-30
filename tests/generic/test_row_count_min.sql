-- test_row_count_min.sql
-- Generic test: checks that a table has at least N rows
-- Usage:
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
