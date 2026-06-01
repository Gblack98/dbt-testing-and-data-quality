-- data_quality_report.sql
-- Analyse ad-hoc : rapport de qualité globale du portefeuille

-- 1. Vue d'ensemble des prêts
select
    loan_status,
    count(*)                            as nb_loans,
    sum(loan_amount_xof)                as total_amount_xof,
    avg(interest_rate_pct)              as avg_rate,
    avg(repayment_ratio_pct)            as avg_repayment_pct,
    avg(payment_reliability_score)      as avg_reliability_score
from {{ ref('int_loan_payments') }}
group by loan_status
order by nb_loans desc;

-- 2. Répartition des risques clients
select
    risk_category,
    count(*)                            as nb_clients,
    avg(credit_score)                   as avg_credit_score,
    sum(total_outstanding_xof)          as total_exposure_xof
from {{ ref('mart_customer_credit_profile') }}
group by risk_category
order by total_exposure_xof desc;

-- 3. Provisions par type de prêt
select
    loan_type,
    payment_status,
    count(*)                            as nb_loans,
    sum(outstanding_balance_xof)        as total_outstanding,
    sum(provision_amount_xof)           as total_provisions
from {{ ref('mart_loan_risk_dashboard') }}
group by loan_type, payment_status
order by total_provisions desc;
