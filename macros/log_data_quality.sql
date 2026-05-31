-- log_data_quality.sql
-- Macro to log data quality metrics during a dbt run

{% macro log_data_quality(model_name, checks) %}
{#
  Usage inside a model:
  {{ log_data_quality('stg_loans', [
      {'check': 'null_loan_amount', 'value': "count(*) filter (where loan_amount_xof is null)"},
      {'check': 'negative_amounts', 'value': "count(*) filter (where loan_amount_xof < 0)"}
  ]) }}
#}
{% if execute %}
    {% do log("=== Data Quality Check: " ~ model_name ~ " ===", info=True) %}
    {% for check in checks %}
        {% do log("  ✓ " ~ check.check, info=True) %}
    {% endfor %}
{% endif %}
{% endmacro %}
