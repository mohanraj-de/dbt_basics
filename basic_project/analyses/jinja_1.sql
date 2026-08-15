{%- set var_name="Mohan" -%}

{{var_name}}


{% set a=['RAJ','JON','RAJNI']%}

{% for i in a %}
    {{i}}
{% endfor %}

{% set a=['RAM','ravan','lakshman']%}

{%- for i in a -%}
    {%- if i=="RAM" -%}
        this is not the candiate: {{i}}
        {% continue %}
    {% endif %}

    {{i}}
{% endfor %}
