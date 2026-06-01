-- stg_transactions.sql
-- Nettoyage et standardisation des transactions

with source as (
    select * from {{ ref('raw_transactions') }}
),

cleaned as (
    select
        transaction_id,
        loan_id,
        customer_id,
        amount::decimal(15,2)                           as amount_xof,
        lower(transaction_type)                         as transaction_type,
        lower(channel)                                  as payment_channel,
        lower(status)                                   as transaction_status,
        cast(transaction_date as date)                  as transaction_date,
        cast(created_at as date)                        as created_at,
        -- Flag transactions suspectes (montant anormal)
        case
            when amount > 5000000 then true
            else false
        end                                             as is_high_value,
        -- Flag transactions échouées
        case
            when lower(status) = 'failed' then true
            else false
        end                                             as is_failed,
        current_timestamp                               as _loaded_at
    from source
    where transaction_id is not null
      and amount > 0
)

select * from cleaned
