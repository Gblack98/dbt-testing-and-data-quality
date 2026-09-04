# dbt testing and data quality

[![dbt CI](https://github.com/Gblack98/dbt-testing-and-data-quality/actions/workflows/dbt_ci.yml/badge.svg)](https://github.com/Gblack98/dbt-testing-and-data-quality/actions/workflows/dbt_ci.yml)

A dbt project on fintech data where the point is not the models but everything that
checks them: custom generic tests, business rule tests, macros that log the results,
and a CI that blocks a merge when something breaks.

Three seeds, six models, 55 tests. It runs on DuckDB, so `dbt build` works with
nothing installed but dbt.

## Layout

```
seeds/                  raw customers, loans, transactions
models/
  staging/              cleaned views on the sources
  intermediate/         int_loan_payments, payments aggregated per loan
  marts/credit/         customer credit profile
  marts/risk/           loan portfolio risk dashboard
tests/
  generic/              reusable tests, applied from schema.yml
  singular/             business rules written as sql
macros/                 surrogate key, quality logging and summary
analyses/               ad hoc quality report
```

## Quick start

```bash
pip install dbt-core dbt-duckdb
dbt deps
dbt seed
dbt run
dbt test
```

## The custom generic tests

| Test | What it checks | Parameters |
|---|---|---|
| `not_null_ratio` | share of nulls in a column | `max_ratio`, default 0.05 |
| `row_count_min` | the table has at least N rows | `min_rows`, default 1 |
| `column_sum_positive` | the column sums above zero | none |
| `no_future_dates` | no date lands in the future | none |

A column that is allowed to be partly empty declares how empty it may be:

```yaml
columns:
  - name: phone
    tests:
      - not_null_ratio:
          max_ratio: 0.10
  - name: income_monthly_xof
    tests:
      - column_sum_positive
```

## CI

Every push runs `dbt deps`, `seed`, `run`, then `test --store-failures`, and uploads
`manifest.json` and `run_results.json` as artifacts. A failing test fails the job.

On a pull request, a second job builds only the models touched by the branch and their
children, so a one-line change does not rebuild the project.

## Packages

- [`dbt_utils`](https://github.com/dbt-labs/dbt-utils), generic tests and macros
- [`audit_helper`](https://github.com/dbt-labs/dbt-audit-helper), comparing two versions of a model
- [`dbt_expectations`](https://github.com/calogica/dbt-expectations), expectation style tests

Stack: dbt-core, DuckDB, GitHub Actions.
