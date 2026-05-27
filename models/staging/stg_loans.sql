-- stg_loans.sql
-- Clean and standardize raw loan data

with source as (
    select * from {{ ref('raw_loans') }}
),

cleaned as (
    select
        loan_id,
        customer_id,
        loan_amount::decimal(15,2)                      as loan_amount_xof,
        interest_rate::decimal(5,2)                     as interest_rate_pct,
        term_months::integer                            as term_months,
        lower(loan_type)                                as loan_type,
        lower(status)                                   as loan_status,
        cast(disbursement_date as date)                 as disbursement_date,
        cast(due_date as date)                          as due_date,
        cast(created_at as date)                        as created_at,
        -- Total amount due including interest (simple formula)
        round(
            loan_amount * (1 + (interest_rate / 100) * term_months / 12),
            2
        )::decimal(15,2)                                as total_amount_due_xof,
        -- Estimated monthly installment
        round(
            loan_amount * (1 + (interest_rate / 100) * term_months / 12) / term_months,
            2
        )::decimal(15,2)                                as monthly_installment_xof,
        current_timestamp                               as _loaded_at
    from source
    where loan_id is not null
      and customer_id is not null
      and loan_amount > 0
)

select * from cleaned
