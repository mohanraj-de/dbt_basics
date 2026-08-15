{%- set inc_flag=0 -%}
{%- set last_load_date=3 -%}


{% set col_list=['sales_id','net_amount','date_sk']%}

select 
    {{resolve_col(col_list)}}

from 
{{ref("bronze_fact_sales")}}

{% if inc_flag!=1 %}
    where date_sk> {{last_load_date}}
{% endif %}

