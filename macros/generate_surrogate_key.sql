-- generate_surrogate_key.sql
-- Macro to generate an MD5 surrogate key from multiple columns

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
