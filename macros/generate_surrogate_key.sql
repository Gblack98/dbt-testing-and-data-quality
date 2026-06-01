-- generate_surrogate_key.sql
-- Macro pour générer une clé de substitution MD5 à partir de plusieurs colonnes

{% macro generate_surrogate_key(columns) %}
    md5(
        concat_ws('|',
            {% for col in columns %}
                coalesce(cast({{ col }} as varchar), 'NULL')
                {% if not loop.last %},{% endif %}
            {% endfor %}
        )
    )
{% endmacro %}
