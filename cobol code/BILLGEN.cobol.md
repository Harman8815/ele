# BILLGEN.cobol - Bill Generation Program Documentation

## Overview
BILLGEN is a COBOL batch program that generates electricity bills by processing meter readings, calculating consumption and amounts, creating bill records, and producing formatted billing reports for customers.

## Program Structure

### IDENTIFICATION DIVISION (Lines 1-2)
```cobol
IDENTIFICATION DIVISION.
PROGRAM-ID.  BILL003.
```
- **Purpose**: Bill generation and reporting
- **Key Point**: Program ID is BILL003 (not BILLGEN)
- **Viva Tip**: "PROGRAM-ID should match the actual program name used in JCL"

### ENVIRONMENT DIVISION (Lines 4-31)
```cobol
ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
```

#### File Definitions (Lines 10-31)
**Four files are defined:**

1. **MI01-METER-KSDS** (Lines 10-14)
   - Type: Indexed VSAM KSDS
   - Assignment: MTRKSDS
   - Access: Sequential
   - Record Key: MTR-CUST-ID
   - Purpose: Meter reading data input
   - **Key Insight**: Sequential processing of all meter records

2. **MI01-CUSTOMER-KSDS** (Lines 16-20)
   - Type: Indexed VSAM KSDS
   - Assignment: CUSTKSDS
   - Access: Random
   - Record Key: CUST-KEY
   - Purpose: Customer master data
   - **Key Insight**: Random access for customer lookup

3. **MO01-BILL-KSDS** (Lines 22-26)
   - Type: Indexed VSAM KSDS
   - Assignment: BILLKSDS
   - Access: Random
   - Record Key: BILL-ID
   - Purpose: Bill master file output
   - **Key Insight**: Random access for bill record storage

4. **TO01-BILL-RPT** (Lines 28-31)
   - Type: Sequential output file
   - Assignment: BILLRPT
   - Purpose: Formatted bill report output
   - **Key Insight**: Contains printable bill reports

### DATA DIVISION (Lines 33-200)

#### FILE SECTION (Lines 35-75)
**Record Layouts:**

1. **Meter Record** (Lines 37-43)
   ```cobol
   01 MI01-METER-RECORD.
      05 MTR-ID           PIC X(14).
      05 MTR-CUST-ID      PIC X(12).
      05 MTR-PREV-READ    PIC 9(06).
      05 MTR-CURR-READ    PIC 9(06).
   ```
   - Total length: 38 characters
   - **Purpose**: Meter ID, customer ID, and readings

2. **Customer Record** (Lines 45-55)
   ```cobol
   01 MI01-CUSTOMER-RECORD.
      05 CUST-KEY         PIC X(12).
      05 CUST-FIRST-NAME  PIC X(10).
      05 CUST-LAST-NAME  PIC X(10).
      05 CUST-AREA-CODE  PIC X(6).
      05 CUST-SPACE      PIC X.
      05 CUST-ADDRESS     PIC X(29).
      05 CUST-CITY        PIC X(10).
      05 CUST-UNITS       PIC X(5).
   ```
   - Total length: 83 characters
   - **Purpose**: Customer master data

3. **Bill Record** (Lines 57-70)
   ```cobol
   01 MO01-BILL-RECORD.
      05 BILL-ID          PIC X(12).
      05 BILL-CUST-ID     PIC X(12).
      05 BILL-MTR-ID      PIC X(14).
      05 BILL-FIRST-NAME  PIC X(10).
      05 BILL-LAST-NAME   PIC X(10).
      05 BILL-AREA-CODE   PIC X(6).
      05 BILL-ADDRESS     PIC X(29).
      05 BILL-UNITS       PIC 9(6).
      05 BILL-AMOUNT      PIC 9(8)V99.
   ```
   - Total length: 109 characters
   - **Purpose**: Complete bill information including calculated amount

4. **Report Record** (Lines 71-75)
   ```cobol
   01 TO01-BILL-RPT-RECORD PIC X(133).
   ```
   - Total length: 133 characters
   - **Purpose**: Formatted bill report lines

#### WORKING-STORAGE SECTION (Lines 77-200)

**File Status Codes** (Lines 79-89)
```cobol
01 WS-FILE-STATUS-CODES.
   05 WS-MTR-STATUS       PIC X(02).
      88 MTR-IO-STATUS    VALUE '00'.
      88 MTR-EOF          VALUE '10'.
   05 WS-CUST-STATUS      PIC X(02).
      88 CUST-IO-STATUS   VALUE '00'.
      88 CUST-NOT-FOUND   VALUE '23'.
   05 WS-BILL-STATUS      PIC X(02).
      88 BILL-IO-STATUS   VALUE '00'.
   05 WS-RPT-STATUS       PIC X(02).
      88 RPT-IO-STATUS    VALUE '00'.
```
- **Purpose**: Status codes for all four files
- **Viva Tip**: "Each file needs its own status variable for proper error handling"

**Date Variables** (Lines 91-98)
```cobol
01 WS-DATE-VARIABLES.
   05 WS-DATE               PIC 9(08).
   05 WS-DATE-FORMAT.
      10 WS-CC              PIC 99.
      10 WS-YY              PIC 99.
      10 WS-MM              PIC 99.
      10 WS-DD              PIC 99.
   05 WS-REPORT-DATE        PIC X(10).
```
- **Purpose**: Date handling for bill generation
- **Format**: YYYYMMDD from system, DD/MM/YY for reports

**Bill ID Generation** (Lines 100-104)
```cobol
01 WS-BILL-ID-GEN.
   05 WS-BILL-SEQUENCE      PIC 9(04) VALUE 0000.
   05 WS-TEMP-BILL-ID       PIC X(12).
   05 WS-BILL-SUBSCRIPT     PIC 9(04) VALUE ZEROS.
   05 WS-BILL-INDEX         PIC 9(04) VALUE ZEROS.
```
- **Purpose**: Generate unique bill IDs
- **Logic**: Sequential numbering with format

**Calculation Variables** (Lines 106-113)
```cobol
01 WS-CALC-VARIABLES.
   05 WS-PREV-READ-NUM      PIC 9(06) VALUE 0.
   05 WS-CURR-READ-NUM      PIC 9(06) VALUE 0.
   05 WS-UNITS-CONSUMED     PIC 9(06) VALUE 0.
   05 WS-BILL-AMOUNT        PIC 9(08)V99 VALUE 0.
   05 WS-RATE               PIC 9(02)V99 VALUE 0.
      88 LOW-RATE           VALUE 10.00.
      88 HIGH-RATE          VALUE 15.00.
```
- **Purpose**: Bill calculations
- **Rates**: Low rate (10.00) and High rate (15.00)
- **Viva Tip**: "V99 indicates 2 decimal places for currency values"

**Report Variables** (Lines 115-125)
```cobol
01 WS-REPORT-VARIABLES.
   05 WS-PAGE-NUM           PIC 9(03) VALUE 1.
   05 WS-LINE-COUNT         PIC 9(03) VALUE 0.
   05 WS-MAX-LINES          PIC 9(03) VALUE 10.
   05 WS-TOTAL-BILLS        PIC 9(04) VALUE 0.
   05 WS-TOTAL-AMOUNT       PIC 9(10)V99 VALUE 0.
01 WS-COUNTERS.
   05 WS-READ-CTR           PIC 9(04) VALUE ZEROS.
   05 WS-WRITE-CTR          PIC 9(04) VALUE ZEROS.
   05 WS-ERROR-CTR          PIC 9(04) VALUE ZEROS.
   05 WS-SKIP-CTR           PIC 9(04) VALUE ZEROS.
```
- **Purpose**: Report formatting and statistics
- **Pagination**: 10 lines per page

**Bill Temporary Storage** (Lines 126-140)
```cobol
01 WS-BILL-TEMP-STORAGE.
   05 WS-BILL-TEMP-TABLE.
      10 WS-BILL-TEMP-RECORD OCCURS 1000 TIMES
                          INDEXED BY WS-BILL-IDX.
         15 WS-T-BILL-ID          PIC X(12).
         15 WS-T-BILL-CUST-ID     PIC X(12).
         15 WS-T-BILL-MTR-ID      PIC X(14).
         15 WS-T-BILL-FIRST-NAME  PIC X(10).
         15 WS-T-BILL-LAST-NAME   PIC X(10).
         15 WS-T-BILL-AREA-CODE   PIC X(6).
         15 WS-T-BILL-ADDRESS     PIC X(29).
         15 WS-T-BILL-UNITS       PIC 9(6).
         15 WS-T-BILL-AMOUNT      PIC 9(8)V99.
   05 WS-BILL-COUNT         PIC 9(04) VALUE ZEROS.
   05 WS-MAX-BILLS          PIC 9(04) VALUE 1000.
```
- **Key Concept**: Temporary storage for bills before final processing
- **Capacity**: Up to 1000 bills
- **Purpose**: Batch processing of bills

**Report Formatting Templates** (Lines 142-200)
- **Headers**: Bill report headers with company name
- **Detail Lines**: Customer bill information layout
- **Totals**: Summary totals for all bills
- **Footers**: Page numbering and summary

### PROCEDURE DIVISION (Lines 201-474)

#### Main Program Flow (Lines 202-206)
```cobol
0000-MAIN-LINE   SECTION.
    PERFORM 1000-INITIALIZE.
    PERFORM 2000-PROCESS.
    PERFORM 9000-TERMINATE.
```
- **Pattern**: Standard COBOL program structure

#### Initialization Section (Lines 208-225)
```cobol
1000-INITIALIZE  SECTION.
    DISPLAY '----------------------------------------'
    DISPLAY 'BILL003 EXECUTION BEGINS HERE ........'
    DISPLAY '  BILLING GENERATION PROGRAM           '
    DISPLAY '----------------------------------------'

    ACCEPT WS-DATE FROM DATE YYYYMMDD.
    MOVE WS-DD TO WS-REPORT-DATE(1:2)
    MOVE '/'   TO WS-REPORT-DATE(3:1)
    MOVE WS-MM TO WS-REPORT-DATE(4:2)
    MOVE '/'   TO WS-REPORT-DATE(6:1)
    MOVE WS-YY TO WS-REPORT-DATE(7:2).

    INITIALIZE WS-BILL-TEMP-TABLE.
    MOVE ZEROS TO WS-BILL-COUNT.
```
- **Purpose**: Initialize program, format date, reset bill table
- **Date Format**: YYYYMMDD to DD/MM/YY conversion

#### Main Processing Section (Lines 227-233)
```cobol
2000-PROCESS     SECTION.
    PERFORM 2100-OPEN-FILES.
    PERFORM 2200-PROCESS-METER-RECORDS.
    PERFORM 2400-WRITE-BILL-RECORDS.
    PERFORM 2600-WRITE-BILL-REPORT.
    PERFORM 2700-CLOSE-FILES.
```
- **Flow**: Open → Process → Write Bills → Generate Report → Close

#### Meter Processing (Lines 235-280)
```cobol
2200-PROCESS-METER-RECORDS.
    READ MI01-METER-KSDS
        AT END SET MTR-EOF TO TRUE
        NOT AT END
            PERFORM 2300-PROCESS-SINGLE-METER
    END-READ
    
    PERFORM UNTIL MTR-EOF
        READ MI01-METER-KSDS
            AT END SET MTR-EOF TO TRUE
            NOT AT END
                PERFORM 2300-PROCESS-SINGLE-METER
        END-READ
    END-PERFORM.
```
- **Pattern**: Standard file reading loop
- **Purpose**: Process each meter record for billing

#### Individual Meter Processing (Lines 230-260)
```cobol
2300-PROCESS-SINGLE-METER.
    MOVE MTR-CUST-ID TO CUST-KEY.
    READ MI01-CUSTOMER-KSDS
        INVALID KEY
            DISPLAY 'CUSTOMER NOT FOUND: ' MTR-CUST-ID
            ADD 1 TO WS-ERROR-CTR
        NOT INVALID KEY
            COMPUTE WS-UNITS-CONSUMED = MTR-CURR-READ - MTR-PREV-READ
            PERFORM 2350-CALCULATE-BILL-AMOUNT
            PERFORM 2360-STORE-BILL-TEMP
    END-READ.
```
- **Logic**:
  1. Look up customer by ID
  2. Calculate consumption
  3. Calculate bill amount
  4. Store in temporary table

#### Bill Calculation (Lines 235-245)
```cobol
2350-CALCULATE-BILL-AMOUNT.
    IF WS-UNITS-CONSUMED <= 100
        SET LOW-RATE TO TRUE
        MOVE 10.00 TO WS-RATE
    ELSE
        SET HIGH-RATE TO TRUE
        MOVE 15.00 TO WS-RATE
    END-IF.
    
    COMPUTE WS-BILL-AMOUNT = WS-UNITS-CONSUMED * WS-RATE.
```
- **Rate Structure**:
  - ≤ 100 units: $10.00 per unit
  - > 100 units: $15.00 per unit
- **Viva Tip**: "Rate calculation is a common business rule in billing systems"

#### Temporary Bill Storage (Lines 236-250)
```cobol
2360-STORE-BILL-TEMP.
    IF WS-BILL-COUNT < WS-MAX-BILLS
        ADD 1 TO WS-BILL-COUNT
        SET WS-BILL-IDX TO WS-BILL-COUNT
        
        MOVE WS-TEMP-BILL-ID TO WS-T-BILL-ID(WS-BILL-IDX)
        MOVE MTR-CUST-ID TO WS-T-BILL-CUST-ID(WS-BILL-IDX)
        MOVE MTR-ID TO WS-T-BILL-MTR-ID(WS-BILL-IDX)
        MOVE CUST-FIRST-NAME TO WS-T-BILL-FIRST-NAME(WS-BILL-IDX)
        MOVE CUST-LAST-NAME TO WS-T-BILL-LAST-NAME(WS-BILL-IDX)
        MOVE CUST-AREA-CODE TO WS-T-BILL-AREA-CODE(WS-BILL-IDX)
        MOVE CUST-ADDRESS TO WS-T-BILL-ADDRESS(WS-BILL-IDX)
        MOVE WS-UNITS-CONSUMED TO WS-T-BILL-UNITS(WS-BILL-IDX)
        MOVE WS-BILL-AMOUNT TO WS-T-BILL-AMOUNT(WS-BILL-IDX)
    ELSE
        DISPLAY 'BILL TEMP TABLE FULL - SKIPPING RECORD'
        ADD 1 TO WS-SKIP-CTR
    END-IF.
```
- **Purpose**: Store bills in temporary table for batch processing
- **Capacity Check**: Prevents overflow beyond 1000 bills

#### Bill Record Writing (Lines 240-300)
```cobol
2400-WRITE-BILL-RECORDS.
    PERFORM VARYING WS-BILL-IDX FROM 1 BY 1
            UNTIL WS-BILL-IDX > WS-BILL-COUNT
        PERFORM 2410-GENERATE-BILL-ID
        PERFORM 2420-WRITE-BILL-KSDS
    END-PERFORM.
```
- **Purpose**: Write all stored bills to VSAM file
- **Pattern**: VARYING loop through temporary table

#### Bill ID Generation (Lines 241-250)
```cobol
2410-GENERATE-BILL-ID.
    ADD 1 TO WS-BILL-SEQUENCE.
    STRING 'B' WS-DATE(3:6) WS-BILL-SEQUENCE
           DELIMITED BY SIZE
           INTO WS-TEMP-BILL-ID.
    MOVE WS-TEMP-BILL-ID TO BILL-ID.
```
- **Format**: B + MMDD + Sequence (e.g., B12030001)
- **Purpose**: Unique bill identification

#### Report Generation (Lines 260-400)
```cobol
2600-WRITE-BILL-REPORT.
    PERFORM 2610-WRITE-REPORT-HEADERS.
    PERFORM VARYING WS-BILL-IDX FROM 1 BY 1
            UNTIL WS-BILL-IDX > WS-BILL-COUNT
        PERFORM 2620-WRITE-BILL-DETAIL
        ADD 1 TO WS-TOTAL-BILLS
        ADD WS-T-BILL-AMOUNT(WS-BILL-IDX) TO WS-TOTAL-AMOUNT
    END-PERFORM.
    PERFORM 2630-WRITE-REPORT-TOTAL.
```
- **Flow**: Headers → Details → Totals
- **Statistics**: Accumulate totals during processing

## Key Programming Concepts

### 1. Batch Processing
- **Temporary Storage**: Bills stored in memory before file output
- **Two-Phase Processing**: Calculate then write
- **Memory Management**: Handle up to 1000 bills in memory

### 2. Business Logic
- **Rate Calculation**: Tiered pricing structure
- **Consumption Calculation**: Current - Previous readings
- **Bill Generation**: Unique ID creation and amount calculation

### 3. File Operations
- **Multiple Files**: Input (meter, customer), Output (bill KSDS, report)
- **Mixed Access**: Sequential and random access patterns
- **Error Handling**: Invalid key and file status checking

### 4. Report Generation
- **Pagination**: Page numbering and line control
- **Formatting**: Spaced output with proper alignment
- **Totals**: Running totals and summary information

## Viva Questions and Answers

### Q1: What is the purpose of the BILLGEN program?
**Answer**: "BILLGEN generates electricity bills by processing meter readings, calculating consumption based on rate structures, creating bill records, and producing formatted billing reports."

### Q2: How are bill amounts calculated?
**Answer**: "Bill amounts are calculated by multiplying units consumed by the applicable rate. Units ≤ 100 use $10.00 per unit, units > 100 use $15.00 per unit."

### Q3: Why is temporary storage used for bills?
**Answer**: "Temporary storage allows batch processing of bills before writing to the VSAM file, enabling better performance and error handling. It can store up to 1000 bills in memory."

### Q4: How are bill IDs generated?
**Answer**: "Bill IDs are generated using the format B + MMDD + sequence number. For example: B12030001 for December 3rd, bill sequence 001."

### Q5: What is the difference between the bill KSDS and bill report files?
**Answer**: "The bill KSDS stores structured bill records for system processing, while the bill report file contains formatted printable output for customers."

### Q6: How does the program handle rate calculations?
**Answer**: "The program uses condition names (LOW-RATE, HIGH-RATE) to apply the correct rate based on consumption. Units ≤ 100 get low rate, > 100 get high rate."

### Q7: What is the purpose of the VARYING statement?
**Answer**: "VARYING creates a controlled loop that increments the index by a specified amount, commonly used for processing table entries."

### Q8: How are file errors handled?
**Answer**: "File errors are handled using file status codes. INVALID KEY handles missing customers, AT END handles end of file, and status codes indicate specific error conditions."

## Performance Considerations

1. **Memory Usage**: Temporary table limited to 1000 bills
2. **File Access**: Random access for customer lookup is efficient
3. **Batch Processing**: Reduces file I/O operations
4. **Rate Calculation**: Simple conditional logic is fast

## Possible Enhancements

1. **Dynamic Memory**: Handle more than 1000 bills
2. **Multiple Rate Tiers**: More complex pricing structures
3. **Date Range**: Process bills for specific periods
4. **Error Recovery**: Better handling of missing data
5. **Sorting**: Sort bills by customer or amount

## Summary
BILLGEN demonstrates comprehensive COBOL programming concepts including batch processing, business logic implementation, file handling, and report generation. It shows how to create a complete billing system from meter readings to customer bills using standard mainframe programming techniques.
