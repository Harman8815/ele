# HIGHCONS.cobol - High Consumption Report Program Documentation

## Overview
HIGHCONS is a COBOL batch program that identifies and reports customers with the highest electricity consumption by processing meter records, calculating consumption, sorting customers by usage, and generating a top-5 high consumption report.

## Program Structure

### IDENTIFICATION DIVISION (Lines 1-2)
```cobol
IDENTIFICATION DIVISION.
PROGRAM-ID.  highcons.
```
- **Purpose**: High consumption analysis and reporting
- **Key Point**: Program name in lowercase
- **Viva Tip**: "PROGRAM-ID should be unique within the system and match JCL execution name"

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
   - Purpose: Meter reading data input
   - **Key Insight**: Sequential processing of all meter records

2. **MI01-CUSTOMER-KSDS** (Lines 16-20)
   - Type: Indexed VSAM KSDS
   - Assignment: CUSTKSDS
   - Access: Random
   - Record Key: CUST-KEY
   - Purpose: Customer master data
   - **Key Insight**: Random access for efficient customer lookup

3. **TO01-HIGH-CONS-RPT** (Lines 22-25)
   - Type: Sequential output file
   - Assignment: HIGHCONS
   - Purpose: High consumption report output
   - **Key Insight**: Formatted report with top 5 consumers

### DATA DIVISION (Lines 27-180)

#### FILE SECTION (Lines 29-55)
**Record Layouts:**

1. **Meter Record** (Lines 31-37)
   ```cobol
   01 MI01-METER-RECORD.
      05 MTR-ID           PIC X(14).
      05 MTR-CUST-ID      PIC X(12).
      05 MTR-PREV-READ    PIC 9(06).
      05 MTR-CURR-READ    PIC 9(06).
   ```
   - Total length: 38 characters
   - **Purpose**: Meter readings for consumption calculation

2. **Customer Record** (Lines 39-49)
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
   - **Purpose**: Customer information for report

3. **Report Record** (Lines 51-55)
   ```cobol
   01 TO01-HIGH-CONS-RPT-RECORD PIC X(133).
   ```
   - Total length: 133 characters
   - **Purpose**: Formatted high consumption report lines

#### WORKING-STORAGE SECTION (Lines 57-180)

**File Status Codes** (Lines 59-67)
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
- **Purpose**: Status monitoring for all three files
- **Viva Tip**: "88-level condition names make file status checking more readable"

**Date Variables** (Lines 69-76)
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
- **Purpose**: Date handling for report generation
- **Format**: YYYYMMDD to DD/MM/YY conversion

**Calculation Variables** (Lines 78-81)
```cobol
01 WS-CALC-VARIABLES.
   05 WS-PREV-READ-NUM      PIC 9(06) VALUE 0.
   05 WS-CURR-READ-NUM      PIC 9(06) VALUE 0.
   05 WS-UNITS-CONSUMED     PIC 9(06) VALUE 0.
```
- **Purpose**: Consumption calculation
- **Formula**: Current Reading - Previous Reading

**Report Variables** (Lines 83-92)
```cobol
01 WS-REPORT-VARIABLES.
   05 WS-PAGE-NUM           PIC 9(03) VALUE 1.
   05 WS-LINE-COUNT         PIC 9(03) VALUE 0.
   05 WS-MAX-LINES          PIC 9(03) VALUE 10.

01 WS-COUNTERS.
   05 WS-READ-CTR           PIC 9(04) VALUE ZEROS.
   05 WS-WRITE-CTR          PIC 9(04) VALUE ZEROS.
   05 WS-ERROR-CTR          PIC 9(04) VALUE ZEROS.
   05 WS-CUSTOMER-COUNT     PIC 9(04) VALUE ZEROS.
```
- **Purpose**: Report formatting and statistics
- **Pagination**: 10 lines per page

**High Consumption Storage** (Lines 94-106)
```cobol
01 WS-HIGH-CONS-STORAGE.
   05 WS-HIGH-CONS-TABLE.
      10 WS-HIGH-CONS-RECORD OCCURS 1000 TIMES
                          INDEXED BY WS-HIGH-IDX ws-sort-idx2.
         15 WS-H-CUST-ID          PIC X(12).
         15 WS-H-FIRST-NAME       PIC X(10).
         15 WS-H-LAST-NAME        PIC X(10).
         15 WS-H-AREA-CODE        PIC X(6).
         15 WS-H-ADDRESS          PIC X(29).
         15 WS-H-CITY             PIC X(10).
         15 WS-H-UNITS            PIC 9(6).
   05 WS-HIGH-COUNT         PIC 9(04) VALUE ZEROS.
   05 WS-MAX-CUSTOMERS      PIC 9(04) VALUE 1000.
```
- **Key Concept**: OCCURS clause creates table for high consumption customers
- **Capacity**: Up to 1000 customers
- **Dual Indexes**: WS-HIGH-IDX and ws-sort-idx2 for different access patterns
- **Viva Tip**: "Multiple indexes allow different ways to access the same table"

**Sort Work Area** (Lines 108-114)
```cobol
01 WS-SORT-WORK-AREA.
   05 WS-SORT-TABLE.
      10 WS-SORT-RECORD OCCURS 1000 TIMES
                          INDEXED BY WS-SORT-IDX.
         15 WS-S-UNITS-CONSUMED   PIC 9(6).
         15 WS-S-INDEX            PIC 9(4).
   05 WS-SORT-COUNT         PIC 9(04) VALUE ZEROS.
```
- **Purpose**: Temporary storage for sorting operations
- **Structure**: Units consumed and original index
- **Viva Tip**: "Sort work area is essential for ranking operations"

**Report Formatting Templates** (Lines 116-180)
- **Headers**: Report title and column headers
- **Detail Lines**: Customer information layout with ranking
- **Column Layout**: Rank, Customer ID, First Name, Last Name, Area, Units

### PROCEDURE DIVISION (Lines 181-429)

#### Main Program Flow (Lines 182-186)
```cobol
0000-MAIN-LINE   SECTION.
    PERFORM 1000-INITIALIZE.
    PERFORM 2000-PROCESS.
    PERFORM 9000-TERMINATE.
```
- **Pattern**: Standard initialize → process → terminate structure

#### Initialization Section (Lines 188-203)
```cobol
1000-INITIALIZE  SECTION.
    DISPLAY '----------------------------------------'
    DISPLAY 'HIGHCONS EXECUTION BEGINS HERE ........'
    DISPLAY '  HIGH CONSUMPTION ANALYSIS PROGRAM     '
    DISPLAY '----------------------------------------'

    ACCEPT WS-DATE FROM DATE YYYYMMDD.
    MOVE WS-DD TO WS-REPORT-DATE(1:2)
    MOVE '/'   TO WS-REPORT-DATE(3:1)
    MOVE WS-MM TO WS-REPORT-DATE(4:2)
    MOVE '/'   TO WS-REPORT-DATE(6:1)
    MOVE WS-YY TO WS-REPORT-DATE(7:2).

    INITIALIZE WS-HIGH-CONS-TABLE.
    MOVE ZEROS TO WS-HIGH-COUNT.
```
- **Purpose**: Initialize program, format date, reset tables
- **Date Format**: YYYYMMDD to DD/MM/YY conversion

#### Main Processing Section (Lines 205-211)
```cobol
2000-PROCESS     SECTION.
    PERFORM 2100-OPEN-FILES.
    PERFORM 2200-PROCESS-METER-RECORDS.
    PERFORM 2300-SORT-HIGH-CONSUMPTION.
    PERFORM 2400-WRITE-HIGH-CONS-REPORT.
    PERFORM 2500-CLOSE-FILES.
```
- **Flow**: Open → Process → Sort → Report → Close
- **Key Step**: Sorting to identify top consumers

#### Meter Processing (Lines 213-250)
```cobol
2200-PROCESS-METER-RECORDS.
    READ MI01-METER-KSDS
        AT END SET MTR-EOF TO TRUE
        NOT AT END
            PERFORM 2210-PROCESS-SINGLE-METER
    END-READ
    
    PERFORM UNTIL MTR-EOF
        READ MI01-METER-KSDS
            AT END SET MTR-EOF TO TRUE
            NOT AT END
                PERFORM 2210-PROCESS-SINGLE-METER
        END-READ
    END-PERFORM.
```
- **Pattern**: Standard file reading loop
- **Purpose**: Process all meter records for consumption analysis

#### Individual Meter Processing (Lines 221-240)
```cobol
2210-PROCESS-SINGLE-METER.
    MOVE MTR-CUST-ID TO CUST-KEY.
    READ MI01-CUSTOMER-KSDS
        INVALID KEY
            DISPLAY 'CUSTOMER NOT FOUND: ' MTR-CUST-ID
            ADD 1 TO WS-ERROR-CTR
        NOT INVALID KEY
            COMPUTE WS-UNITS-CONSUMED = MTR-CURR-READ - MTR-PREV-READ
            IF WS-UNITS-CONSUMED > 0
                PERFORM 2220-STORE-HIGH-CONS
            END-IF
    END-READ.
```
- **Logic**:
  1. Look up customer by ID
  2. Calculate consumption
  3. Store if consumption > 0
- **Validation**: Only store customers with positive consumption

#### High Consumption Storage (Lines 222-235)
```cobol
2220-STORE-HIGH-CONS.
    IF WS-HIGH-COUNT < WS-MAX-CUSTOMERS
        ADD 1 TO WS-HIGH-COUNT
        SET WS-HIGH-IDX TO WS-HIGH-COUNT
        
        MOVE MTR-CUST-ID TO WS-H-CUST-ID(WS-HIGH-IDX)
        MOVE CUST-FIRST-NAME TO WS-H-FIRST-NAME(WS-HIGH-IDX)
        MOVE CUST-LAST-NAME TO WS-H-LAST-NAME(WS-HIGH-IDX)
        MOVE CUST-AREA-CODE TO WS-H-AREA-CODE(WS-HIGH-IDX)
        MOVE CUST-ADDRESS TO WS-H-ADDRESS(WS-HIGH-IDX)
        MOVE CUST-CITY TO WS-H-CITY(WS-HIGH-IDX)
        MOVE WS-UNITS-CONSUMED TO WS-H-UNITS(WS-HIGH-IDX)
    ELSE
        DISPLAY 'HIGH CONSUMPTION TABLE FULL - SKIPPING RECORD'
        ADD 1 TO WS-ERROR-CTR
    END-IF.
```
- **Purpose**: Store customer consumption data in table
- **Capacity Check**: Prevents overflow beyond 1000 customers

#### Sorting Logic (Lines 230-280)
```cobol
2300-SORT-HIGH-CONSUMPTION.
    MOVE ZEROS TO WS-SORT-COUNT.
    
    PERFORM VARYING WS-HIGH-IDX FROM 1 BY 1
            UNTIL WS-HIGH-IDX > WS-HIGH-COUNT
        ADD 1 TO WS-SORT-COUNT
        SET WS-SORT-IDX TO WS-SORT-COUNT
        MOVE WS-H-UNITS(WS-HIGH-IDX) TO WS-S-UNITS-CONSUMED(WS-SORT-IDX)
        MOVE WS-HIGH-IDX TO WS-S-INDEX(WS-SORT-IDX)
    END-PERFORM.
    
    PERFORM 2310-BUBBLE-SORT.
```
- **Purpose**: Prepare and execute sorting of consumption data
- **Method**: Bubble sort implementation
- **Viva Tip**: "Bubble sort is simple but inefficient for large datasets"

#### Bubble Sort Implementation (Lines 231-270)
```cobol
2310-BUBBLE-SORT.
    PERFORM VARYING WS-SORT-IDX FROM 1 BY 1
            UNTIL WS-SORT-IDX >= WS-SORT-COUNT
        PERFORM VARYING WS-SORT-IDX2 FROM WS-SORT-COUNT BY -1
                UNTIL WS-SORT-IDX2 <= WS-SORT-IDX
            IF WS-S-UNITS-CONSUMED(WS-SORT-IDX) < 
               WS-S-UNITS-CONSUMED(WS-SORT-IDX2)
                MOVE WS-S-UNITS-CONSUMED(WS-SORT-IDX) TO WS-TEMP-UNITS
                MOVE WS-S-UNITS-CONSUMED(WS-SORT-IDX2) TO WS-S-UNITS-CONSUMED(WS-SORT-IDX)
                MOVE WS-TEMP-UNITS TO WS-S-UNITS-CONSUMED(WS-SORT-IDX2)
                
                MOVE WS-S-INDEX(WS-SORT-IDX) TO WS-TEMP-INDEX
                MOVE WS-S-INDEX(WS-SORT-IDX2) TO WS-S-INDEX(WS-SORT-IDX)
                MOVE WS-TEMP-INDEX TO WS-S-INDEX(WS-SORT-IDX2)
            END-IF
        END-PERFORM
    END-PERFORM.
```
- **Algorithm**: Classic bubble sort (descending order)
- **Purpose**: Sort customers by consumption (highest first)
- **Complexity**: O(n²) - acceptable for 1000 records

#### Report Generation (Lines 240-350)
```cobol
2400-WRITE-HIGH-CONS-REPORT.
    PERFORM 2410-WRITE-REPORT-HEADERS.
    
    COMPUTE WS-TOP-COUNT = WS-SORT-COUNT.
    IF WS-TOP-COUNT > 5
        MOVE 5 TO WS-TOP-COUNT
    END-IF.
    
    PERFORM VARYING WS-SORT-IDX FROM 1 BY 1
            UNTIL WS-SORT-IDX > WS-TOP-COUNT
        SET WS-HIGH-IDX TO WS-S-INDEX(WS-SORT-IDX)
        PERFORM 2420-WRITE-REPORT-DETAIL
    END-PERFORM.
```
- **Purpose**: Generate top-5 high consumption report
- **Logic**: Limit to top 5 customers after sorting
- **Ranking**: Display rank (1-5) with customer details

## Key Programming Concepts

### 1. Sorting Algorithms
- **Bubble Sort**: Simple sorting implementation
- **Descending Order**: Highest consumption first
- **Index Mapping**: Maintain original record positions
- **Viva Tip**: "Bubble sort repeatedly swaps adjacent elements if they're in wrong order"

### 2. Table Processing
- **OCCURS Clause**: Create arrays for data storage
- **Multiple Indexes**: Different access patterns for same table
- **Index Management**: SET statement for index manipulation
- **Capacity Limits**: Handle table overflow gracefully

### 3. Ranking and Reporting
- **Top-N Selection**: Limit report to top 5 customers
- **Ranking Display**: Show rank numbers in report
- **Formatted Output**: Spaced columns for readability
- **Pagination**: Page numbering for long reports

### 4. Data Analysis
- **Consumption Calculation**: Current - Previous readings
- **Data Filtering**: Only include positive consumption
- **Statistical Analysis**: Identify high usage patterns
- **Business Intelligence**: Support decision making

## Viva Questions and Answers

### Q1: What is the purpose of the HIGHCONS program?
**Answer**: "HIGHCONS analyzes electricity consumption data, identifies customers with highest usage, sorts them by consumption, and generates a top-5 high consumption report."

### Q2: How does the sorting algorithm work?
**Answer**: "The program uses bubble sort to sort customers by consumption in descending order. It repeatedly compares adjacent elements and swaps them if they're in wrong order until the list is sorted."

### Q3: Why are two tables used (HIGH-CONS-TABLE and SORT-TABLE)?
**Answer**: "HIGH-CONS-TABLE stores all customer data, while SORT-TABLE is used specifically for sorting operations with consumption values and original indexes. This separation makes sorting more efficient."

### Q4: How is the top-5 selection implemented?
**Answer**: "After sorting all customers by consumption, the program limits the report to the first 5 entries (WS-TOP-COUNT) and displays them with ranks 1 through 5."

### Q5: What is the purpose of the index in the sort table?
**Answer**: "The index maintains the original position of each customer in the main table, allowing us to retrieve complete customer information after sorting by consumption only."

### Q6: How does bubble sort work in this context?
**Answer**: "Bubble sort compares consumption values of adjacent customers and swaps them if the left customer has lower consumption than the right customer. This process repeats until no more swaps are needed."

### Q7: Why is consumption filtered to be > 0?
**Answer**: "Only customers with positive consumption are included in the analysis to exclude invalid readings, new customers, or meters with no usage during the period."

### Q8: What are the limitations of this sorting approach?
**Answer**: "Bubble sort has O(n²) complexity, making it inefficient for very large datasets. For 1000 customers it's acceptable, but more efficient algorithms like quicksort would be better for larger datasets."

## Performance Considerations

1. **Sorting Efficiency**: Bubble sort is O(n²) - acceptable for 1000 records
2. **Memory Usage**: Two tables require additional memory
3. **File Access**: Random customer lookup is efficient
4. **Report Generation**: Limited to top 5 reduces processing time

## Possible Enhancements

1. **Better Sorting**: Use quicksort or mergesort for efficiency
2. **Dynamic Top-N**: Allow configurable top-N selection
3. **Multiple Periods**: Compare consumption across time periods
4. **Threshold Analysis**: Include consumption thresholds
5. **Graphical Reports**: Add visual representation of data

## Summary
HIGHCONS demonstrates data analysis techniques in COBOL including sorting algorithms, table processing, ranking operations, and report generation. It shows how to implement business intelligence functions using standard mainframe programming techniques to identify and report on high consumption patterns.
