# House Price Prediction

Predicting house sale prices from property characteristics (square footage, bedrooms/bathrooms, condition, location, year built, etc.) using regression models.

## Approach

1. **EDA** — price distribution, price vs. living area, correlation heatmap, average price by city.
2. **Cleaning** — removed rows with invalid (`0`) prices.
3. **Data leakage check** — found that the `price_per_sqft` column is derived directly from `price` (correlation ≈ 1.0 with `price_per_sqft × sqft_living`) and excluded it from the features, since a model trained with it would score unrealistically well but fail on real-world data where it isn't known in advance.
4. **Feature engineering** — `house_age`, `renovated` flag, one-hot encoded `city`.
5. **Modeling** — built a `scikit-learn` `Pipeline` (so preprocessing never leaks across the train/test split) and compared Linear Regression against Random Forest, with and without a log-price target.
6. **Evaluation** — 5-fold cross-validation plus a held-out test set, scored with R², MAE, RMSE, and MAPE.

## Results

| Model | CV R² (mean) | Test R² | Test MAE | Test RMSE | Test MAPE |
|---|---|---|---|---|---|
| Linear Regression | 0.461 | 0.600 | $153,951 | $243,989 | 32.3% |
| Random Forest (raw price) | 0.198 | 0.441 | $128,366 | $288,501 | 26.6% |
| **Random Forest (log price)** | **0.500** | **0.623** | **$117,779** | $236,712 | **21.4%** |

Random Forest trained on `log1p(price)` performed best overall — the log transform helps it handle the right-skewed price distribution and a few very expensive outlier houses.

**Strongest predictors:** location (`city`) and `sqft_living`, consistent with the EDA.

## Project structure

```
House-Price-Prediction/
├── README.md
├── requirements.txt
├── data/
│   └── modified_data.csv
├── house_price_prediction.ipynb   # full analysis: EDA, leakage check, pipeline, model comparison
└── app.py                         # Streamlit demo for interactive predictions
```

## How to run

```bash
git clone https://github.com/<your-username>/House-Price-Prediction.git
cd House-Price-Prediction
pip install -r requirements.txt
jupyter notebook house_price_prediction.ipynb
```

### Interactive demo

```bash
streamlit run app.py
```

## Dataset

House sales dataset with features including `sqft_living`, `bedrooms`, `bathrooms`, `condition`, `city`, `yr_built`, `yr_renovated`, and `price`.

## Next steps

- Use `statezip` as a finer-grained location signal.
- Try Gradient Boosting / XGBoost / LightGBM.
- Hyperparameter tuning with `GridSearchCV`.
- SHAP values for per-prediction explanations.
