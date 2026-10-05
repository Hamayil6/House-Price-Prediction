"""
Streamlit demo for the House Price Prediction project.

Run with:
    streamlit run app.py
"""

import numpy as np
import pandas as pd
import streamlit as st
from sklearn.compose import ColumnTransformer, TransformedTargetRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder

RANDOM_STATE = 42

st.set_page_config(page_title="House Price Prediction", page_icon="🏠", layout="centered")


@st.cache_data
def load_data():
    df = pd.read_csv("data/modified_data.csv")
    df = df[df["price"] > 0].copy()
    df["date"] = pd.to_datetime(df["date"])
    df["house_age"] = df["date"].dt.year - df["yr_built"]
    df["renovated"] = (df["yr_renovated"] > 0).astype(int)
    return df


@st.cache_resource
def train_model(df: pd.DataFrame):
    feature_cols = [
        "bedrooms", "bathrooms", "sqft_living", "sqft_lot", "floors",
        "waterfront", "view", "condition", "sqft_above", "sqft_basement",
        "yr_built", "yr_renovated", "house_age", "renovated", "city",
    ]
    X = df[feature_cols]
    y = df["price"]

    preprocessor = ColumnTransformer(
        transformers=[("city", OneHotEncoder(handle_unknown="ignore"), ["city"])],
        remainder="passthrough",
    )
    regressor = TransformedTargetRegressor(
        regressor=RandomForestRegressor(n_estimators=300, random_state=RANDOM_STATE, n_jobs=-1),
        func=np.log1p,
        inverse_func=np.expm1,
    )
    pipe = Pipeline(steps=[("preprocess", preprocessor), ("model", regressor)])
    pipe.fit(X, y)
    return pipe, feature_cols


df = load_data()
model, feature_cols = train_model(df)
cities = sorted(df["city"].unique())

st.title("🏠 House Price Prediction")
st.caption(
    "Random Forest regression trained on log(price). "
    "See the full analysis in `house_price_prediction.ipynb`."
)

st.divider()
st.subheader("Enter house details")

col1, col2 = st.columns(2)
with col1:
    bedrooms = st.number_input("Bedrooms", min_value=0, max_value=10, value=3)
    bathrooms = st.number_input("Bathrooms", min_value=0.0, max_value=8.0, value=2.0, step=0.25)
    sqft_living = st.number_input("Living area (sqft)", min_value=200, max_value=15000, value=2000, step=50)
    sqft_lot = st.number_input("Lot size (sqft)", min_value=500, max_value=1_100_000, value=7500, step=100)
    floors = st.number_input("Floors", min_value=1.0, max_value=3.5, value=1.0, step=0.5)
    condition = st.slider("Condition (1 = poor, 5 = excellent)", 1, 5, 3)

with col2:
    view = st.slider("View quality (0 = none, 4 = excellent)", 0, 4, 0)
    waterfront = st.checkbox("Waterfront property")
    sqft_above = st.number_input("Above-ground sqft", min_value=200, max_value=10000, value=1700, step=50)
    sqft_basement = st.number_input("Basement sqft", min_value=0, max_value=5000, value=0, step=50)
    yr_built = st.number_input("Year built", min_value=1900, max_value=2024, value=1990, step=1)
    yr_renovated = st.number_input("Year renovated (0 if never)", min_value=0, max_value=2024, value=0, step=1)

city = st.selectbox("City", cities, index=cities.index("Seattle") if "Seattle" in cities else 0)

if st.button("Predict price", type="primary"):
    house_age = 2024 - yr_built
    renovated = int(yr_renovated > 0)

    input_df = pd.DataFrame([{
        "bedrooms": bedrooms,
        "bathrooms": bathrooms,
        "sqft_living": sqft_living,
        "sqft_lot": sqft_lot,
        "floors": floors,
        "waterfront": int(waterfront),
        "view": view,
        "condition": condition,
        "sqft_above": sqft_above,
        "sqft_basement": sqft_basement,
        "yr_built": yr_built,
        "yr_renovated": yr_renovated,
        "house_age": house_age,
        "renovated": renovated,
        "city": city,
    }])[feature_cols]

    prediction = model.predict(input_df)[0]
    st.success(f"### Predicted price: ${prediction:,.0f}")

st.divider()
st.caption(
    "This demo trains on the full dataset for simplicity. "
    "See the notebook for a proper train/test evaluation (R² ≈ 0.62, MAPE ≈ 21%)."
)
