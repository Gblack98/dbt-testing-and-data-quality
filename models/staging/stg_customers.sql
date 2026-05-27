-- stg_customers.sql
-- Clean and standardize raw customer data

with source as (
    select * from {{ ref('raw_customers') }}
),

cleaned as (
    select
        customer_id,
        trim(lower(first_name))                         as first_name,
        trim(lower(last_name))                          as last_name,
        trim(lower(email))                              as email,
        phone,
        upper(country)                                  as country_code,
        age,
        income_monthly::decimal(15,2)                   as income_monthly_xof,
        case
            when income_monthly < 100000  then 'low'
            when income_monthly < 500000  then 'medium'
            when income_monthly < 1000000 then 'high'
            else 'very_high'
        end                                             as income_segment,
        cast(created_at as date)                        as customer_since,
        is_active::boolean                              as is_active,
        current_timestamp                               as _loaded_at
    from source
    where customer_id is not null
      and email is not null
)

select * from cleaned
