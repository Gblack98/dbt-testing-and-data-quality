-- test_no_future_dates.sql
-- Test générique : vérifie qu'aucune date n'est dans le futur
-- Usage :
--   tests:
--     - no_future_dates

{% test no_future_dates(model, column_name) %}

select {{ column_name }}, count(*) as nb_rows
from {{ model }}
where {{ column_name }} > current_date
group by {{ column_name }}

{% endtest %}
