# AREARPT.cobol - Area Wise Consumption Report Program Documentation

## Overview
AREARPT is a COBOL batch program that generates area-wise consumption reports by processing meter records and customer data, calculating consumption totals, and producing formatted reports with area-wise statistics.

## Program Structure

### IDENTIFICATION DIVISION (Lines 1-2)
```cobol
IDENTIFICATION DIVISION.
PROGRAM-ID.  arearpt.
```
- **Purpose**: Area-wise consumption report generation
- **Key Point**: Program name in lowercase (arearpt)
- **Viva Tip**: "PROGRAM-ID can be in mixed case but is typically lowercase for compatibility"

### ENVIRONMENT DIVISION (Lines 4-25)
```cobol
ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
```

#### File Definitions (Lines 10-25)
**Three files are defined:**

1. **MI01-METER-KSDS** (Lines 10-14)
   - Type: Indexed VSAM KSDS
   - Assignment: MTRKSDS
   - Access: Sequential
   - Record Key: MTR-CUST-ID
   - Purpose: Meter reading data
   - **Key Insight**: Sequential access processes all meter records in order

2. **MI01-CUSTOMER-KSDS** (Lines 16-20)
   - Type: Indexed VSAM KSDS
   - Assignment: CUSTKSDS
   - Access: Random
   - Record Key: CUST-KEY
   - Purpose: Customer master data
   - **Key Insight**: Random access allows quick customer lookup by ID

3. **TO01-AREA-RPT** (Lines 22-25)
   - Type: Sequential output file
   - Assignment: AREARPT
   - Purpose: Formatted area report output
   - **Key Insight**: Report file contains formatted printable output

### DATA DIVISION (Lines 27-166)

#### FILE SECTION (Lines 29-53)
**Record Layouts:**

1. **Meter Record** (Lines 30-37)
   ```cobol
   01 MI01-METER-RECORD.
      05 MTR-ID           PIC X(14).
      05 MTR-CUST-ID      PIC X(12).
      05 MTR-PREV-READ    PIC 9(06).
      05 MTR-CURR-READ    PIC 9(06).
   ```
   - Total length: 38 characters
   - **Purpose**: Contains meter ID, customer ID, and previous/current readings

2. **Customer Record** (Lines 38-48)
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
   - **Purpose**: Customer master data including area code

3. **Report Record** (Lines 50-53)
   ```cobol
   01 TO01-AREA-RPT-RECORD PIC X(72).
   ```
   - Total length: 72 characters (formatted report lines)

#### WORKING-STORAGE SECTION (Lines 55-166)

**File Status Codes** (Lines 57-65)
```cobol
01 WS-FILE-STATUS-CODES.
   05 WS-MTR-STATUS       PIC X(02).
      88 MTR-IO-STATUS    VALUE '00'.
      88 MTR-EOF          VALUE '10'.
   05 WS-CUST-STATUS      PIC X(02).
      88 CUST-IO-STATUS   VALUE '00'.
      88 CUST-NOT-FOUND   VALUE '23'.
   05 WS-RPT-STATUS       PIC X(02).
      88 RPT-IO-STATUS    VALUE '00'.
```
- **Viva Tip**: "88-level condition names make code more readable"
- **Key Insight**: Different file statuses for different file types

**Date Variables** (Lines 67-74)
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
- **Purpose**: Date handling for report formatting
- **Format**: DD/MM/YY for report display

**Calculation Variables** (Lines 76-79)
```cobol
01 WS-CALC-VARIABLES.
   05 WS-PREV-READ-NUM      PIC 9(06) VALUE 0.
   05 WS-CURR-READ-NUM      PIC 9(06) VALUE 0.
   05 WS-UNITS-CONSUMED     PIC 9(06) VALUE 0.
```
- **Purpose**: Consumption calculations
- **Formula**: Current Reading - Previous Reading = Units Consumed

**Report Variables** (Lines 81-90)
```cobol
01 WS-REPORT-VARIABLES.
   05 WS-PAGE-NUM           PIC 9(03) VALUE 1.
   05 WS-LINE-COUNT         PIC 9(03) VALUE 0.
   05 WS-MAX-LINES          PIC 9(03) VALUE 15.
01 WS-COUNTERS.
   05 WS-READ-CTR           PIC 9(04) VALUE ZEROS.
   05 WS-WRITE-CTR          PIC 9(04) VALUE ZEROS.
   05 WS-ERROR-CTR          PIC 9(04) VALUE ZEROS.
   05 WS-TOTAL-CUSTOMERS    PIC 9(04) VALUE ZEROS.
   05 WS-TOTAL-UNITS        PIC 9(08) VALUE ZEROS.
```
- **Key Insight**: Page formatting with 15 lines per page
- **Purpose**: Report pagination and statistics

**Area Storage Table** (Lines 92-106)
```cobol
01 WS-AREA-STORAGE.
   05 WS-AREA-TABLE.
      10 WS-AREA-RECORD OCCURS 100 TIMES
                          INDEXED BY WS-AREA-IDX.
         15 WS-A-AREA-CODE        PIC X(6).
         15 WS-A-CUSTOMER-COUNT   PIC 9(04) VALUE ZEROS.
         15 WS-A-TOTAL-UNITS      PIC 9(08) VALUE ZEROS.
   05 WS-AREA-COUNT         PIC 9(04) VALUE ZEROS.
   05 WS-MAX-AREAS          PIC 9(04) VALUE 100.
```
- **Key Concept**: OCCURS clause creates table/array structure
- **Purpose**: Store area-wise statistics
- **Viva Tip**: "INDEXED BY allows efficient table access with SET statement"

**Report Formatting Templates** (Lines 108-166)
- **Headers**: Multiple header lines for report formatting
- **Detail Line**: Template for area data display
- **Total Line**: Template for grand total
- **Footer**: Page numbering information

### PROCEDURE DIVISION (Lines 167-437)

#### Main Program Flow (Lines 168-172)
```cobol
0000-MAIN-LINE   SECTION.
    PERFORM 1000-INITIALIZE.
    PERFORM 2000-PROCESS.
    PERFORM 9000-TERMINATE.
```
- **Pattern**: Standard initialize → process → terminate structure

#### Initialization Section (Lines 174-189)
```cobol
1000-INITIALIZE  SECTION.
    DISPLAY '----------------------------------------'
    DISPLAY 'AREARPT EXECUTION BEGINS HERE ........'
    DISPLAY '  AREA WISE CONSUMPTION REPORT PROGRAM   '
    DISPLAY '----------------------------------------'

    ACCEPT WS-DATE FROM DATE YYYYMMDD.
    MOVE WS-DD TO WS-REPORT-DATE(1:2)
    MOVE '/'   TO WS-REPORT-DATE(3:1)
    MOVE WS-MM TO WS-REPORT-DATE(4:2)
    MOVE '/'   TO WS-REPORT-DATE(6:1)
    MOVE WS-YY TO WS-REPORT-DATE(7:2).

    INITIALIZE WS-AREA-TABLE.
    MOVE ZEROS TO WS-AREA-COUNT.
```
- **Purpose**: Initialize program, format date, reset tables
- **Date Format**: Converts YYYYMMDD to DD/MM/YY
- **Viva Tip**: "INITIALIZE sets all alphanumeric fields to spaces and numeric to zero"

#### Main Processing Section (Lines 191-196)
```cobol
2000-PROCESS     SECTION.
    PERFORM 2100-OPEN-FILES.
    PERFORM 2200-PROCESS-METER-RECORDS.
    PERFORM 2400-WRITE-AREA-REPORT.
    PERFORM 2500-CLOSE-FILES.
```
- **Flow**: Open files → Process data → Generate report → Close files

#### File Operations (Lines 198-250)
- **2100-OPEN-FILES**: Opens all three files with error checking
- **2200-PROCESS-METER-RECORDS**: Main processing loop
- **2300-PROCESS-SINGLE-METER**: Individual meter record processing
- **2400-WRITE-AREA-REPORT**: Report generation
- **2500-CLOSE-FILES**: File cleanup

#### Meter Processing Logic (Lines 220-280)
```cobol
2200-PROCESS-METER-RECORDS.
    PERFORM 2100-OPEN-FILES.
    
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
- **Pattern**: Standard file reading loop with AT END handling
- **Key Insight**: Processes each meter record individually

#### Individual Meter Processing (Lines 230-280)
```cobol
2300-PROCESS-SINGLE-METER.
    MOVE MTR-CUST-ID TO CUST-KEY.
    READ MI01-CUSTOMER-KSDS
        INVALID KEY
            DISPLAY 'CUSTOMER NOT FOUND: ' MTR-CUST-ID
            ADD 1 TO WS-ERROR-CTR
        NOT INVALID KEY
            COMPUTE WS-UNITS-CONSUMED = MTR-CURR-READ - MTR-PREV-READ
            PERFORM 2350-UPDATE-AREA-TABLE
    END-READ.
```
- **Logic**: 
  1. Use meter customer ID to read customer record
  2. Calculate consumption (current - previous)
  3. Update area statistics table

#### Area Table Update (Lines 235-260)
```cobol
2350-UPDATE-AREA-TABLE.
    MOVE CUST-AREA-CODE TO WS-TEMP-AREA-CODE.
    SET AREA-NOT-FOUND TO TRUE.
    
    SEARCH WS-AREA-TABLE
        AT END SET AREA-NOT-FOUND TO TRUE
        WHEN WS-A-AREA-CODE(WS-AREA-IDX) = WS-TEMP-AREA-CODE
            SET AREA-FOUND TO TRUE
    END-SEARCH
    
    IF AREA-FOUND
        ADD 1 TO WS-A-CUSTOMER-COUNT(WS-AREA-IDX)
        ADD WS-UNITS-CONSUMED TO WS-A-TOTAL-UNITS(WS-AREA-IDX)
    ELSE
        IF WS-AREA-COUNT < WS-MAX-AREAS
            ADD 1 TO WS-AREA-COUNT
            SET WS-AREA-IDX TO WS-AREA-COUNT
            MOVE WS-TEMP-AREA-CODE TO WS-A-AREA-CODE(WS-AREA-IDX)
            MOVE 1 TO WS-A-CUSTOMER-COUNT(WS-AREA-IDX)
            MOVE WS-UNITS-CONSUMED TO WS-A-TOTAL-UNITS(WS-AREA-IDX)
        END-IF
    END-IF.
```
- **Key Concept**: SEARCH statement for table lookup
- **Logic**: Find existing area or create new entry
- **Viva Tip**: "SEARCH is like a linear search through the table"

#### Report Generation (Lines 240-350)
```cobol
2400-WRITE-AREA-REPORT.
    PERFORM 2410-WRITE-REPORT-HEADERS.
    PERFORM VARYING WS-AREA-IDX FROM 1 BY 1
            UNTIL WS-AREA-IDX > WS-AREA-COUNT
        PERFORM 2420-WRITE-AREA-DETAIL
    END-PERFORM.
    PERFORM 2430-WRITE-REPORT-TOTAL.
```
- **Pattern**: Headers → Details → Totals
- **Key Insight**: VARYING for loop through table entries

## Key Programming Concepts

### 1. Table Processing
- **OCCURS Clause**: Creates table/array structure
- **SEARCH Statement**: Linear search through table
- **INDEXED BY**: Efficient table access
- **Viva Tip**: "OCCURS with INDEXED BY is COBOL's way of creating arrays"

### 2. File Handling
- **Multiple Files**: Three different file types (meter KSDS, customer KSDS, report)
- **Mixed Access**: Sequential and random access patterns
- **Error Handling**: INVALID KEY and AT END conditions

### 3. Report Generation
- **Pagination**: Page numbering and line counting
- **Formatting**: Spaced output with proper alignment
- **Templates**: Predefined report layouts

### 4. Data Aggregation
- **Area-wise Statistics**: Grouping by area code
- **Consumption Calculation**: Current - previous readings
- **Totals**: Grand totals for all areas

## Viva Questions and Answers

### Q1: What is the purpose of the AREARPT program?
**Answer**: "AREARPT generates area-wise consumption reports by processing meter records, calculating consumption, and producing formatted reports with customer and area statistics."

### Q2: How does the program calculate consumption?
**Answer**: "Consumption is calculated by subtracting the previous meter reading from the current meter reading: WS-UNITS-CONSUMED = MTR-CURR-READ - MTR-PREV-READ."

### Q3: What is the purpose of the area table?
**Answer**: "The area table stores aggregated statistics for each area including customer count and total units consumed. It uses OCCURS 100 TIMES to handle up to 100 different areas."

### Q4: How does the program handle new area codes?
**Answer**: "When a new area code is encountered, the program searches the table. If not found and space is available, it creates a new entry with the area code and initializes counters."

### Q5: What is the difference between sequential and random file access?
**Answer**: "Sequential access processes records in order (meter file), while random access allows direct retrieval using a key (customer file accessed by customer ID)."

### Q6: How is report pagination handled?
**Answer**: "The program tracks line count with WS-LINE-COUNT and WS-MAX-LINES (15). When the limit is reached, it advances to the next page and resets counters."

### Q7: What is the purpose of the SEARCH statement?
**Answer**: "SEARCH performs a linear search through the table to find matching area codes. It's equivalent to a sequential search in other languages."

### Q8: How are report formats defined?
**Answer**: "Report formats are defined using templates with FILLER for spacing and edited fields (like Z,ZZ9) for proper numeric display formatting."

## Performance Considerations

1. **Table Search**: Linear search could be slow for many areas
2. **File Access**: Random customer lookup is efficient
3. **Memory Usage**: Table limited to 100 areas
4. **I/O Optimization**: Sequential meter processing is efficient

## Possible Enhancements

1. **Binary Search**: For faster area lookup
2. **Dynamic Table Size**: Handle more than 100 areas
3. **Sorting**: Sort areas by code or consumption
4. **Subtotals**: Add intermediate totals
5. **Error Recovery**: Better handling of missing customers

## Summary
AREARPT demonstrates advanced COBOL concepts including table processing, report generation, file handling, and data aggregation. It shows how to create business reports from master data files using standard mainframe programming techniques.
