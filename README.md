# dbt Testing & Data Quality Framework

> A production-grade dbt testing framework for fintech data quality — featuring custom tests, macros, automated monitoring, and CI/CD quality gates.

[![dbt CI](https://github.com/Gblack98/dbt-testing-and-data-quality/actions/workflows/dbt_ci.yml/badge.svg)](https://github.com/Gblack98/dbt-testing-and-data-quality/actions/workflows/dbt_ci.yml)

## Architecture

```
dbt-testing-and-data-quality/
│
├── seeds/                          # Test CSV data (fintech)
│   ├── raw_customers.csv           # Customers
│   ├── raw_loans.csv               # Loans
│   ├── raw_transactions.csv        # Transactions
│   └── schema.yml                  # Seed column types
│
├── models/
│   ├── staging/                    # Cleaned source views
│   │   ├── stg_customers.sql
│   │   ├── stg_loans.sql
│   │   ├── stg_transactions.sql
│   │   └── _stg_sources.yml        # Source & model tests
│   │
│   ├── intermediate/               # Business logic layer
│   │   └── int_loan_payments.sql   # Payment aggregation per loan
│   │
│   └── marts/
│       ├── credit/
│       │   ├── mart_customer_credit_profile.sql  # Full customer credit profile
│       │   └── _mart_credit.yml
│       └── risk/
│           ├── mart_loan_risk_dashboard.sql      # Loan portfolio risk dashboard
│           └── _mart_risk.yml
│
├── tests/
│   ├── generic/                    # Reusable custom tests
│   │   ├── test_not_null_ratio.sql
│   │   ├── test_row_count_min.sql
│   │   ├── test_column_sum_positive.sql
│   │   └── test_no_future_dates.sql
│   │
│   └── singular/                   # Business-specific SQL tests
│       ├── assert_no_defaulted_active_loans.sql
│       ├── assert_credit_score_bounds.sql
│       └── assert_total_paid_not_exceeds_due.sql
│
├── macros/                         # Utility macros
│   ├── data_quality_summary.sql
│   ├── generate_surrogate_key.sql
│   └── log_data_quality.sql
│
├── analyses/                       # Ad-hoc queries
│   └── data_quality_report.sql
│
└── .github/workflows/
    └── dbt_ci.yml                  # CI/CD with quality gates
```

## Quick Start

### Prerequisites
```bash
pip install dbt-core dbt-duckdb
```

### Setup
```bash
git clone https://github.com/Gblack98/dbt-testing-and-data-quality.git
cd dbt-testing-and-data-quality

# Install dbt packages
dbt deps

# Load test data
dbt seed

# Build all models
dbt run

# Run all tests
dbt test
```

### Expected output
```
✅ 3 seeds loaded
✅ 6 models built  (staging → intermediate → marts)
✅ 55 tests passed (generic + singular + sources)
```

## Custom Generic Tests

| Test | Description | Parameters |
|------|-------------|------------|
| `not_null_ratio` | Checks the null percentage in a column | `max_ratio` (default: 0.05) |
| `row_count_min` | Ensures a table has at least N rows | `min_rows` (default: 1) |
| `column_sum_positive` | Verifies that the column sum is > 0 | — |
| `no_future_dates` | Ensures no date values are in the future | — |

### Usage example in `schema.yml`
```yaml
columns:
  - name: phone
    tests:
      - not_null_ratio:
          max_ratio: 0.10   # Allow up to 10% nulls
  - name: income_monthly_xof
    tests:
      - column_sum_positive
```

## CI/CD Pipeline

Every push and pull request triggers:
1. **dbt debug** — validates project configuration
2. **dbt seed** — loads test data
3. **dbt run** — builds all models
4. **dbt test** — runs all tests (❌ blocks merge on failure)
5. **Slim CI** (PR only) — runs only modified models and their downstream dependencies

## Packages

- [`dbt_utils`](https://github.com/dbt-labs/dbt-utils) — generic utility tests and macros
- [`audit_helper`](https://github.com/dbt-labs/dbt-audit-helper) — model comparison and regression detection
- [`dbt_expectations`](https://github.com/calogica/dbt-expectations) — Great Expectations-style tests

## Use Cases

- ✅ Financial transaction data validation
- ✅ Loan and repayment consistency checks
- ✅ Anomaly detection (amounts, ratios, scores)
- ✅ Referential integrity (customer ↔ loan)
- ✅ Credit scoring and loan loss provisioning
- ✅ Automated CI quality gates

---

**Stack**: dbt-core · DuckDB · GitHub Actions · Python
