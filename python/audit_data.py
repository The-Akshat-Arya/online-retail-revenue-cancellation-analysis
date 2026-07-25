import pandas as pd

file_path = "data/Online Retail.xlsx"

df = pd.read_excel(file_path)

print("Rows and columns:", df.shape)

print("\nColumn names:")
print(df.columns.tolist())

print("\nFirst five rows:")
print(df.head())

print("\nMissing values:")
print(df.isnull().sum())

print("\nAdditional data audit:")

print("Total rows:", len(df))
print("Unique invoices:", df["InvoiceNo"].nunique())
print("Unique products:", df["StockCode"].nunique())
print("Known customers:", df["CustomerID"].nunique(dropna=True))

print(
    "Date range:",
    df["InvoiceDate"].min(),
    "to",
    df["InvoiceDate"].max()
)

cancelled_rows = (
    df["InvoiceNo"]
    .astype(str)
    .str.upper()
    .str.startswith("C")
)

print("Cancelled invoice rows:", cancelled_rows.sum())
print(
    "Unique cancelled invoices:",
    df.loc[cancelled_rows, "InvoiceNo"].nunique()
)

print("Negative quantity rows:", (df["Quantity"] < 0).sum())
print("Zero or negative price rows:", (df["UnitPrice"] <= 0).sum())
print("Exact duplicate rows:", df.duplicated().sum())

print("\nIssue overlap check:")

cancelled = (
    df["InvoiceNo"]
    .astype(str)
    .str.upper()
    .str.startswith("C")
)

negative_quantity = df["Quantity"] < 0
non_positive_price = df["UnitPrice"] <= 0
missing_description = df["Description"].isna()

print(
    "Negative quantity and cancelled:",
    (negative_quantity & cancelled).sum()
)

print(
    "Negative quantity but not cancelled:",
    (negative_quantity & ~cancelled).sum()
)

print(
    "Cancelled but quantity is positive:",
    (cancelled & ~negative_quantity).sum()
)

print(
    "Missing description with non-positive price:",
    (missing_description & non_positive_price).sum()
)

print(
    "Missing description with positive price:",
    (missing_description & (df["UnitPrice"] > 0)).sum()
)

print(
    "Non-positive price with positive quantity:",
    (non_positive_price & (df["Quantity"] > 0)).sum()
)

print("\nSample negative quantities not marked as cancelled:")

print(
    df.loc[
        negative_quantity & ~cancelled,
        [
            "InvoiceNo",
            "StockCode",
            "Description",
            "Quantity",
            "UnitPrice",
        ],
    ]
    .head(10)
    .to_string(index=False)
)