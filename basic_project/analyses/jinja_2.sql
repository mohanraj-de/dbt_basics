{%- set inc_flag=0 -%}
{%- set last_load_date=3 -%}


{% set col_list=['sales_id','net_amount','date_sk']%}

select 
    {% for i in col_list %}
        {{i}} {%if not loop.last %} , {% endif %}
    {% endfor %}

from 
{{ref("bronze_fact_sales")}}

{% if inc_flag!=1 %}
    where date_sk> {{last_load_date}}
{% endif %}

