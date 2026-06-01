-- data_quality_summary.sql
-- Macro qui génère un résumé de qualité des données pour une table
-- Usage : {{ data_quality_summary(ref('ma_table'), ['col1', 'col2']) }}

{% macro data_quality_summary(model, columns) %}

with base as (
    select * from {{ model }}
),

total as (
    select count(*) as total_rows from base
),

{% for col in columns %}
col_{{ loop.index }}_stats as (
    select
        '{{ col }}'                                     as column_name,
        (select total_rows from total)                  as total_rows,
        count({{ col }})                                as non_null_count,
        (select total_rows from total) - count({{ col }}) as null_count,
        round(
            ((select total_rows from total) - count({{ col }}))::decimal /
            nullif((select total_rows from total), 0) * 100, 2
        )                                               as null_pct,
        count(distinct {{ col }})                       as distinct_count
    from base
){% if not loop.last %},{% endif %}
{% endfor %}

{% for col in columns %}
select * from col_{{ loop.index }}_stats
{% if not loop.last %} union all {% endif %}
{% endfor %}

{% endmacro %}
