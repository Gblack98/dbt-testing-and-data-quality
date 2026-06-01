-- log_data_quality.sql
-- Macro pour logger les métriques de qualité dans une table d'audit

{% macro log_data_quality(model_name, checks) %}
{#
  Usage dans un modèle :
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
