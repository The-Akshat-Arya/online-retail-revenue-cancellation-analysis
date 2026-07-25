import pandas as pd

input_file = "data/Online Retail.xlsx"

sales_output = "data/sales_transactions.csv"
cancelled_output = "data/cancelled_transactions.csv"

df = pd.read_excel(input_file)

print("Original rows:", len(df))

# Remove exact duplicate rows
df = df.drop_duplicates().copy()

# Standardise text columns
df["InvoiceNo"] = df["InvoiceNo"].astype(str).str.strip()
df["StockCode"] = df["StockCode"].astype(str).str.strip()
df["Country"] = df["Country"].astype(str).str.strip()

# Identify cancellation rows
df["IsCancelled"] = df["InvoiceNo"].str.upper().str.startswith("C")

# Keep only genuine completed sales
sales_df = df[
    (~df["IsCancelled"])
    & (df["Quantity"] > 0)
    & (df["UnitPrice"] > 0)
    & (df["Description"].notna())
    & (
        ~df["Description"]
        .str.contains("adjust bad debt", case=False, na=False)
    )
].copy()
# Keep genuine cancellation rows separately
cancelled_df = df[
    (df["IsCancelled"])
    & (df["Quantity"] < 0)
    & (df["UnitPrice"] > 0)
    & (df["Description"].notna())
].copy()

# CustomerID is an identifier, not a decimal measurement
# Use -1 for transactions where the customer is unknown.
sales_df["CustomerID"] = sales_df["CustomerID"].fillna(-1).astype(int)

cancelled_df["CustomerID"] = (
    cancelled_df["CustomerID"].fillna(-1).astype(int)
)

# Convert True/False into MySQL-friendly 1/0.
sales_df["IsCancelled"] = sales_df["IsCancelled"].astype(int)
cancelled_df["IsCancelled"] = cancelled_df["IsCancelled"].astype(int)

# Create useful date columns
for dataset in [sales_df, cancelled_df]:
    dataset["InvoiceDate"] = pd.to_datetime(dataset["InvoiceDate"])
    dataset["InvoiceYear"] = dataset["InvoiceDate"].dt.year
    dataset["InvoiceMonth"] = dataset["InvoiceDate"].dt.month
    dataset["MonthName"] = dataset["InvoiceDate"].dt.month_name()
    dataset["InvoiceYearMonth"] = (
    dataset["InvoiceDate"].dt.to_period("M").astype(str)
)

# Revenue values
sales_df["Revenue"] = sales_df["Quantity"] * sales_df["UnitPrice"]

sales_df["Revenue"] = (
    sales_df["Quantity"] * sales_df["UnitPrice"]
).round(2)

cancelled_df["CancelledQuantity"] = cancelled_df["Quantity"].abs()

cancelled_df["CancellationValue"] = (
    cancelled_df["CancelledQuantity"] * cancelled_df["UnitPrice"]
).round(2)

sales_df.to_csv(sales_output, index=False)
cancelled_df.to_csv(cancelled_output, index=False)

print("Sales rows:", len(sales_df))
print("Cancellation rows:", len(cancelled_df))
print("Sales file created:", sales_output)
print("Cancellation file created:", cancelled_output)
print("Total sales revenue:", round(sales_df["Revenue"].sum(), 2))
print(
    "Total cancellation value:",
    round(cancelled_df["CancellationValue"].sum(), 2)
)