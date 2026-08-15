{# 
Macros are functions for making reusable companents for sql jinja templates like col resolver, hardcoded values, math func,etc.,
namespace is jinja object to assign global variables
- is whitespace controler to delete the space space before or after #}


{% macro resolve_col(col_list) %}
    {% set ns = namespace(op='') -%}

    {%- for i in col_list -%}
        {%- set ns.op = ns.op ~ i -%}
        {%- if not loop.last -%}
            {%- set ns.op = ns.op ~ ', ' -%}
        {%- endif -%}
    {%- endfor -%}

    {{ ns.op }}
{%- endmacro %}