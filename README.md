# dbt Testing & Data Quality Framework

> Framework complet de tests dbt pour la qualité des données en fintech — avec tests custom, macros, monitoring et CI/CD.

[![dbt CI](https://github.com/Gblack98/dbt-testing-and-data-quality/actions/workflows/dbt_ci.yml/badge.svg)](https://github.com/Gblack98/dbt-testing-and-data-quality/actions/workflows/dbt_ci.yml)

## 🏗️ Architecture

```
dbt-testing-and-data-quality/
│
├── seeds/                          # Données de test CSV (fintech)
│   ├── raw_customers.csv           # Clients
│   ├── raw_loans.csv               # Prêts
│   └── raw_transactions.csv        # Transactions
│
├── models/
│   ├── staging/                    # Vue nettoyées des sources
│   │   ├── stg_customers.sql
│   │   ├── stg_loans.sql
│   │   ├── stg_transactions.sql
│   │   └── _stg_sources.yml        # Tests de sources
│   │
│   ├── intermediate/               # Transformations métier
│   │   └── int_loan_payments.sql   # Agrégation paiements/prêts
│   │
│   └── marts/
│       ├── credit/
│       │   └── mart_customer_credit_profile.sql   # Profil crédit client
│       └── risk/
│           └── mart_loan_risk_dashboard.sql        # Dashboard risque
│
├── tests/
│   ├── generic/                    # Tests réutilisables custom
│   │   ├── test_not_null_ratio.sql
│   │   ├── test_row_count_min.sql
│   │   ├── test_column_sum_positive.sql
│   │   └── test_no_future_dates.sql
│   │
│   └── singular/                   # Tests SQL spécifiques métier
│       ├── assert_no_defaulted_active_loans.sql
│       ├── assert_credit_score_bounds.sql
│       └── assert_total_paid_not_exceeds_due.sql
│
├── macros/                         # Macros utilitaires
│   ├── data_quality_summary.sql
│   ├── generate_surrogate_key.sql
│   └── log_data_quality.sql
│
├── analyses/                       # Requêtes ad-hoc
│   └── data_quality_report.sql
│
└── .github/workflows/
    └── dbt_ci.yml                  # CI/CD avec quality gates
```

## 🚀 Démarrage rapide

### Prérequis
```bash
pip install dbt-core dbt-duckdb
```

### Installation
```bash
git clone https://github.com/Gblack98/dbt-testing-and-data-quality.git
cd dbt-testing-and-data-quality

# Installer les packages dbt
dbt deps

# Charger les données de test
dbt seed

# Exécuter les modèles
dbt run

# Lancer tous les tests
dbt test
```

### Résultat attendu
```
✅ 3 seeds chargées
✅ 7 modèles construits (staging → intermediate → marts)
✅ 25+ tests passés (generic + singular + sources)
```

## 🧪 Tests custom disponibles

| Test | Description | Paramètres |
|------|-------------|------------|
| `not_null_ratio` | Vérifie le % de nulls | `max_ratio` (défaut: 0.05) |
| `row_count_min` | Vérifie un minimum de lignes | `min_rows` (défaut: 1) |
| `column_sum_positive` | Vérifie que la somme est > 0 | — |
| `no_future_dates` | Vérifie l'absence de dates futures | — |

### Exemple d'utilisation dans `schema.yml`
```yaml
columns:
  - name: phone
    tests:
      - not_null_ratio:
          max_ratio: 0.10   # 10% de nulls tolérés
  - name: income_monthly_xof
    tests:
      - column_sum_positive
```

## 🔁 CI/CD

Chaque push/PR déclenche :
1. **dbt debug** — vérifie la configuration
2. **dbt seed** — charge les données de test
3. **dbt run** — construit tous les modèles
4. **dbt test** — lance tous les tests (quality gate ❌ si échec)
5. **Slim CI** (PR uniquement) — ne teste que les modèles modifiés

## 📦 Packages utilisés

- [`dbt_utils`](https://github.com/dbt-labs/dbt-utils) — utilitaires génériques
- [`audit_helper`](https://github.com/dbt-labs/dbt-audit-helper) — comparaison de modèles
- [`dbt_expectations`](https://github.com/calogica/dbt-expectations) — tests type Great Expectations
- [`elementary`](https://github.com/elementary-data/elementary) — monitoring de données

## 🎯 Cas d'usage couverts

- ✅ Validation des données de transactions financières
- ✅ Cohérence des prêts et remboursements
- ✅ Détection d'anomalies (montants, ratios, scores)
- ✅ Intégrité référentielle client ↔ prêt
- ✅ Calcul de score de crédit et provisions
- ✅ Quality gates automatisés en CI

---

**Stack** : dbt-core · DuckDB · GitHub Actions · Python
