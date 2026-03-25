import random
from datetime import datetime, timedelta

# =====================
# Master Data
# =====================

# Sample meter IDs (14 characters each)
meter_ids = [
    "MTR10000000001",
    "MTR10000000002",
    "MTR10000000003",
    "MTR10000000004",
    "MTR10000000005",
    "MTR10000000006",
    "MTR10000000007",
    "MTR10000000008",
    "MTR10000000009",
    "MTR10000000010",
    "MTR10000000011",
    "MTR10000000012",
    "MTR10000000013",
    "MTR10000000014",
    "MTR10000000015",
    "MTR10000000016",
    "MTR10000000017",
    "MTR10000000018",
    "MTR10000000019",
    "MTR10000000020"
]

# =====================
# Formatter
# =====================

def format_field(value, length):
    return str(value).ljust(length)[:length]

# =====================
# Record Generator
# =====================

def generate_record(meter_id, reading_date, prev_read):
    # Current reading should be >= prev_read (can't go backward)
    # Max value is 100, range is 0-100
    max_increase = 100 - prev_read
    if max_increase > 0:
        curr_read = prev_read + round(random.uniform(0, max_increase), 2)
    else:
        curr_read = prev_read
    
    # Ensure curr_read doesn't exceed 100
    curr_read = min(curr_read, 100)
    
    # Format date as YYYY-MM-DD (10 characters)
    date_str = reading_date.strftime("%Y-%m-%d")
    
    record = (
        format_field(meter_id, 14) +
        format_field(date_str, 10) +
        format_field(prev_read, 6) +
        format_field(curr_read, 6)
    )
    
    return record, curr_read

# =====================
# File Generation
# =====================

# Generate readings for multiple months
# Starting from January 2024, generate monthly readings
start_date = datetime(2024, 1, 1)
num_months = 12
records = []

# Track previous readings per meter
prev_readings = {meter_id: 0.0 for meter_id in meter_ids}

for month_offset in range(num_months):
    reading_date = start_date + timedelta(days=30*month_offset)
    
    for meter_id in meter_ids:
        prev_read = prev_readings[meter_id]
        record, curr_read = generate_record(meter_id, reading_date, prev_read)
        records.append(record)
        # Update previous reading for next month
        prev_readings[meter_id] = curr_read

# Write to file
with open("reading_txn.txt", "w") as f:
    for record in records:
        f.write(record + "\n")

print(f"Generated {len(records)} meter reading transactions.")
