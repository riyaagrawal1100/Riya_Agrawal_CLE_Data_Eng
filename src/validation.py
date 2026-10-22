import pandas as pd

def validate_data(df, required_columns, key_column, date_columns=None):
    df = df.copy()
    date_columns = date_columns or {}
    reasons = pd.Series("", index=df.index, dtype="object")

    missing_columns = [col for col in required_columns if col not in df.columns]
    if missing_columns:
        raise ValueError("Missing columns: " + ", ".join(missing_columns))

    for col in required_columns:
        missing = df[col].isna() | df[col].astype(str).str.strip().eq("")
        reasons.loc[missing] = reasons.loc[missing].apply(
            lambda old: f"{old};missing_{col}" if old else f"missing_{col}"
        )

    for col, date_format in date_columns.items():
        parsed = pd.to_datetime(df[col], format=date_format, errors="coerce")
        invalid = df[col].notna() & df[col].astype(str).str.strip().ne("") & parsed.isna()
        reasons.loc[invalid] = reasons.loc[invalid].apply(
            lambda old: f"{old};invalid_date_{col}" if old else f"invalid_date_{col}"
        )

    duplicate = df[key_column].notna() & df[key_column].astype(str).duplicated(keep=False)
    reasons.loc[duplicate] = reasons.loc[duplicate].apply(
        lambda old: f"{old};duplicate_{key_column}" if old else f"duplicate_{key_column}"
    )

    valid = df.loc[reasons.eq("")].copy()
    rejected = df.loc[~reasons.eq("")].copy()
    rejected["rejection_reason"] = reasons.loc[~reasons.eq("")]
    return valid, rejected
