with dedup as (
    select * ,
    row_number() over(partition by id order by updated_date desc) as rn 
    from {{ source('source','items') }}
)

select id,name,category, updated_date
from dedup where rn=1