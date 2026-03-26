# DB2 Integration for COBOL Programs

## Programs to Update
- `elect001.cobol` - Customer ID generation and KSDS writes
- `meter001.cobol` - Meter processing and consumption calculation
- `billpay.cobol` - Bill payment processing
- `highcons.cobol` - High consumption report
- `arearpt.cobol` - Area-wise consumption report

## Required Changes

### 1. Add DB2 Connection
Add `EXEC SQL INCLUDE SQLCA` and `EXEC SQL INCLUDE DCLGEN` for each table.

### 2. Replace File I/O with SQL
- Convert `READ`/`WRITE`/`REWRITE` to `SELECT`/`INSERT`/`UPDATE`
- Replace KSDS file operations with DB2 table operations
- Use cursors for sequential processing

### 3. Tables Needed
| Table | Purpose |
|-------|---------|
| CUSTOMER | Store customer data (replaces CUST-KSDS) |
| METER | Store meter data (replaces METER-KSDS) |
| BILL | Store bill data (replaces BILL-KSDS) |
| PAYMENT | Store payment transactions |
| READING | Store meter readings (replaces READ-TXN) |

### 4. Key Modifications
- `elect001.cobol`: Change KSDS WRITE to INSERT into CUSTOMER table
- `meter001.cobol`: Change KSDS READ/WRITE to SELECT/INSERT METER table
- `billpay.cobol`: Change BILL KSDS to SQL SELECT/UPDATE BILL table
- `highcons.cobol`/`arearpt.cobol`: Change to SQL SELECT with JOINs

### 5. Error Handling
Replace file status checks (`WS-KSDS-STATUS`) with SQLCODE checks.

### 6. JCL Updates
Add `DB2LIB` DD and `SYSTSIN` for DB2 binds to each JCL.
