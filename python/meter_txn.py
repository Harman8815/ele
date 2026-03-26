import random
from datetime import datetime, timedelta

# =====================
# Master Data
# =====================

# Sample meter IDs (14 characters each)
meter_ids = [
    "MTR-Aa26031748",
    "MTR-Aa26031923",
    "MTR-Aa26032023",
    "MTR-Aa26032898",
    "MTR-Aa26033723",
    "MTR-Aa26034598",
    "MTR-Aa26035073",
    "MTR-Aa26035098",
    "MTR-Aa26035348",
    "MTR-Aa26035448",
    "MTR-Aa26035473",
    "MTR-Aa26035598",
    "MTR-Aa26035848",
    "MTR-Aa26037123",
    "MTR-Aa26037398",
    "MTR-Aa26037498",
    "MTR-Aa26038448",
    "MTR-Ad26031573",
    "MTR-Ad26032048",
    "MTR-Ad26033173",
    "MTR-Ad26033323",
    "MTR-Ad26034423",
    "MTR-Ad26036123",
    "MTR-Ad26036548",
    "MTR-Ad26038273",
    "MTR-Ad26038423",
    "MTR-Ad26038523",
    "MTR-An26030723",
    "MTR-An26031998",
    "MTR-An26033998",
    "MTR-An26034948",
    "MTR-An26036323",
    "MTR-An26036623",
    "MTR-An26037123",
    "MTR-An26038548",
    "MTR-An26038898",
    "MTR-An26039823",
    "MTR-Ar26030098",
    "MTR-Ar26031198",
    "MTR-Ar26031548",
    "MTR-Ar26032673",
    "MTR-Ar26032923",
    "MTR-Ar26033848",
    "MTR-Ar26033973",
    "MTR-Ar26034073",
    "MTR-Ar26035273",
    "MTR-Ar26035898",
    "MTR-Ar26038273",
    "MTR-Ar26039648",
    "MTR-Ay26031123",
    "MTR-Ay26031748",
    "MTR-Ay26031998",
    "MTR-Ay26032398",
    "MTR-Ay26032748",
    "MTR-Ay26034473",
    "MTR-Ay26034773",
    "MTR-Ay26036648",
    "MTR-Ay26037198",
    "MTR-Di26031873",
    "MTR-Di26032823",
    "MTR-Di26036673",
    "MTR-Di26036823",
    "MTR-Di26036998",
    "MTR-Di26039073",
    "MTR-Di26039348",
    "MTR-Di26039598",
    "MTR-Ir26030748",
    "MTR-Ir26031548",
    "MTR-Ir26033198",
    "MTR-Ir26033423",
    "MTR-Ir26034698",
    "MTR-Ir26036773",
    "MTR-Ir26037123",
    "MTR-Ir26037548",
    "MTR-Ir26037798",
    "MTR-Is26030598",
    "MTR-Is26030973",
    "MTR-Is26031773",
    "MTR-Is26032173",
    "MTR-Is26032598",
    "MTR-Is26034148",
    "MTR-Is26035848",
    "MTR-Is26036173",
    "MTR-Is26036598",
    "MTR-Is26037048",
    "MTR-Ki26031173",
    "MTR-Ki26032023",
    "MTR-Ki26033373",
    "MTR-Ki26033548",
    "MTR-Ki26034698",
    "MTR-Ki26034898",
    "MTR-Ki26035173",
    "MTR-Ki26037223",
    "MTR-Ki26038523",
    "MTR-Ki26038848",
    "MTR-Kr26033673",
    "MTR-Kr26034298",
    "MTR-Kr26035173",
    "MTR-Kr26036498",
    "MTR-Kr26036973",
    "MTR-Kr26037798",
    "MTR-Kr26039448",
    "MTR-Me26030123",
    "MTR-Me26030323",
    "MTR-Me26030573",
    "MTR-Me26030623",
    "MTR-Me26031273",
    "MTR-Me26031798",
    "MTR-Me26032048",
    "MTR-Me26032948",
    "MTR-Me26032998",
    "MTR-Me26033348",
    "MTR-Me26033823",
    "MTR-Me26035223",
    "MTR-Me26038773",
    "MTR-Me26039698",
    "MTR-Me26039748",
    "MTR-Me26039823",
    "MTR-Na26030048",
    "MTR-Na26033448",
    "MTR-Na26035298",
    "MTR-Na26035548",
    "MTR-Na26035798",
    "MTR-Na26036473",
    "MTR-Na26037373",
    "MTR-Na26037548",
    "MTR-Na26038123",
    "MTR-Na26039048",
    "MTR-Pa26031073",
    "MTR-Pa26033023",
    "MTR-Pa26035123",
    "MTR-Pa26035473",
    "MTR-Pa26037148",
    "MTR-Pa26037173",
    "MTR-Re26030173",
    "MTR-Re26031523",
    "MTR-Re26033848",
    "MTR-Re26036073",
    "MTR-Re26036698",
    "MTR-Re26036773",
    "MTR-Re26038473",
    "MTR-Re26039173",
    "MTR-Re26039523",
    "MTR-Ri26031523",
    "MTR-Ri26033748",
    "MTR-Ri26034323",
    "MTR-Ri26036173",
    "MTR-Ri26036223",
    "MTR-Ri26037873",
    "MTR-Ri26039748",
    "MTR-Sa26030623",
    "MTR-Sa26031498",
    "MTR-Sa26033073",
    "MTR-Sa26033448",
    "MTR-Sa26033948",
    "MTR-Sa26034873",
    "MTR-Sa26035148",
    "MTR-Sa26035223",
    "MTR-Sa26035273",
    "MTR-Sa26035348",
    "MTR-Sa26035623",
    "MTR-Sa26036273",
    "MTR-Sa26036473",
    "MTR-Sa26037673",
    "MTR-Sa26037723",
    "MTR-Sa26037998",
    "MTR-Sa26039573",
    "MTR-Sa26039823",
    "MTR-Sh26031048",
    "MTR-Sh26032123",
    "MTR-Sh26032848",
    "MTR-Sh26033123",
    "MTR-Sh26034698",
    "MTR-Sh26034823",
    "MTR-Sh26035123",
    "MTR-Sh26035573",
    "MTR-Sh26036098",
    "MTR-Sh26036598",
    "MTR-Sh26036623",
    "MTR-Sh26036798",
    "MTR-Sh26039473",
    "MTR-Vi26030048",
    "MTR-Vi26030348",
    "MTR-Vi26030598",
    "MTR-Vi26031323",
    "MTR-Vi26031798",
    "MTR-Vi26032173",
    "MTR-Vi26032748",
    "MTR-Vi26033273",
    "MTR-Vi26035123",
    "MTR-Vi26035673",
    "MTR-Vi26035823",
    "MTR-Vi26035998",
    "MTR-Vi26036148",
    "MTR-Vi26036823",
    "MTR-Vi26036973",
    "MTR-Vi26037473",
    "MTR-Vi26038248",
    "MTR-Vi26038473",
    "MTR-Vi26039298"
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
