# POMS Meter Management System - DB2 Refactored Version

## Overview
This system has been completely refactored to use DB2 database instead of VSAM files, providing better data integrity, scalability, and modern database capabilities.

## Architecture Changes

### Database Layer
- **Previous**: VSAM KSDS files
- **Current**: DB2 Database with POMS_METER table
- **Benefits**: ACID compliance, SQL queries, better indexing, data integrity

### Data Structure
```
POMS_METER Table:
- CUSTOMER_ID   CHAR(12)  - Customer identifier
- METER_ID      CHAR(12)  - Primary key, unique meter identifier  
- PREV_READ     DECIMAL(6,0) - Previous meter reading
- CURR_READ     DECIMAL(6,0) - Current meter reading
- CREATED_DATE  DATE      - Record creation date
- UPDATED_DATE  TIMESTAMP - Last update timestamp
```

## Programs Description

### 1. MTRCR001 - Meter Creation Program
- **Purpose**: Create new meter records in DB2
- **Input**: Customer ID
- **Output**: Generated Meter ID with initial readings
- **Features**:
  - Automatic meter ID generation (MTR-YYYY-CXXX format)
  - Initial reading set to 0
  - DB2 INSERT operation with error handling

### 2. MTRRD002 - Meter Read Program  
- **Purpose**: Display meter information
- **Input**: Meter ID
- **Output**: Customer ID, Previous Read, Current Read
- **Features**:
  - SQL SELECT query
  - Clean display of only essential fields
  - Error handling for missing records

### 3. MTRUP003 - Meter Update Program
- **Purpose**: Update current meter reading
- **Input**: Meter ID, New Current Reading
- **Output**: Updated Previous/Current readings
- **Features**:
  - Dynamic PREV_READ update (old CURR_READ becomes PREV_READ)
  - Validation (new reading must be greater than current)
  - SQL UPDATE with proper transaction handling

### 4. MTR02MSD - Menu Map
- **Purpose**: Main menu interface
- **Options**:
  - 1: Create Meter (→ MTRCR001)
  - 2: Read Meter (→ MTRRD002)  
  - 3: Update Meter (→ MTRUP003)

## Map Definitions

### MTR02MSD - Menu Map
- Menu selection interface
- Input field for option selection
- Message display area

### MTR03MSD - Read Map  
- Meter ID input field
- Display fields: Customer ID, Previous Read, Current Read
- Clean, focused interface

### MTR04MSD - Update Map
- Meter ID input field
- Display fields: Customer ID, Previous Read, Current Read
- Input field for New Current Reading
- Validation feedback

## Key Features

### 1. Dynamic Read Management
- **Automatic PREV_READ update**: When updating CURR_READ, old CURR_READ automatically becomes PREV_READ
- **Validation**: Ensures new readings are always greater than current readings
- **Data Integrity**: Prevents invalid meter readings

### 2. Proper Input/Output Variables
- **Numeric fields**: PREV_READ and CURR_READ defined as DECIMAL(6,0)
- **Character fields**: Proper length definitions for IDs
- **SQL Host Variables**: Correctly typed for DB2 compatibility

### 3. Error Handling
- **SQLCODE checking**: Proper DB2 error handling
- **User-friendly messages**: Clear feedback for all operations
- **Data validation**: Prevents invalid operations

## File Structure
```
cobol.cics/meter/
├── MTR02MSD          - Menu map definition
├── MTR03MSD          - Read map definition  
├── MTR04MSD          - Update map definition
├── MTRCR001          - Create program (DB2)
├── MTRRD002          - Read program (DB2)
├── MTRUP003          - Update program (DB2)
├── CREATE_POMS_METER.sql - DB2 table creation script
└── README.md         - This documentation
```

## Database Setup

### Prerequisites
- DB2 Database installed and configured
- Proper DB2 connectivity from CICS region
- Appropriate user permissions

### Setup Steps
1. Run `CREATE_POMS_METER.sql` to create the table
2. Verify table creation with sample data
3. Configure CICS-DB2 connection
4. Test programs with sample meter data

## Migration from VSAM

### Data Migration
```sql
-- Example migration script (adjust as needed)
INSERT INTO POMS_METER (CUSTOMER_ID, METER_ID, PREV_READ, CURR_READ)
SELECT 
    MTR-CUST-ID,
    MTR-ID, 
    MTR-PREV-READ,
    MTR-CURR-READ
FROM VSAM_METER_FILE;
```

### Benefits of Migration
- **Performance**: Better query optimization
- **Reliability**: ACID transactions
- **Scalability**: Handles larger datasets
- **Maintenance**: Standard SQL interface
- **Integration**: Easier integration with other systems

## Usage Examples

### Creating a Meter
1. Select option 1 from menu
2. Enter Customer ID (e.g., CUST00000001)
3. System generates Meter ID (e.g., MTR-2024-C001)
4. Initial readings set to 0

### Reading a Meter
1. Select option 2 from menu
2. Enter Meter ID
3. View Customer ID, Previous Read, Current Read

### Updating a Meter
1. Select option 3 from menu  
2. Enter Meter ID
3. View current readings
4. Enter New Current Reading (must be > current)
5. System updates PREV_READ and CURR_READ

## Technical Specifications

### COBOL Data Types
- **CHAR(12)**: Customer ID, Meter ID
- **DECIMAL(6,0)**: Previous Read, Current Read  
- **DATE**: Creation date
- **TIMESTAMP**: Update timestamp

### SQL Operations
- **INSERT**: Create new meter records
- **SELECT**: Read meter information
- **UPDATE**: Modify meter readings
- **Indexes**: Optimized for CUSTOMER_ID lookups

### CICS Integration
- **EXEC SQL**: Embedded SQL statements
- **EXEC CICS**: CICS commands for screen handling
- **MAP**: BMS map definitions for user interface

## Error Codes
- **SQLCODE = 0**: Success
- **SQLCODE = -100**: No data found
- **SQLCODE = -803**: Duplicate key violation
- **SQLCODE < 0**: Other database errors

## Future Enhancements
1. **Batch Processing**: Create batch programs for bulk meter updates
2. **Reporting**: Add meter consumption reports
3. **Audit Trail**: Enhanced audit logging
4. **Integration**: Connect with billing system
5. **Web Interface**: Modern web-based meter management

## Support
For technical support or questions about the refactored meter system, contact the development team.
