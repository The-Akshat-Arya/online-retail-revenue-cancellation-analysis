from pathlib import Path

import pandas as pd


# Full cleaned CSV from the original working project
source_file = Path(
    r"C:\Users\Akshat Arya\Desktop\online-retail-performance\data\sales_transactions.csv"
)

# Sample file to be created inside the new GitHub project
output_file = Path(
    r"C:\Users\Akshat Arya\Desktop\online-retail-revenue-cancellation-analysis\data\sales_transactions_sample.csv"
)

if not source_file.exists():
    raise FileNotFoundError(f"Source file not found: {source_file}")

sales_sample = pd.read_csv(source_file, nrows=10_000)
sales_sample.to_csv(output_file, index=False)

print(f"Created {len(sales_sample):,} rows")
print(f"Saved to: {output_file}")