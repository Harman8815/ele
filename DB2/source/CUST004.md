# CUST004 - Customer Batch Processing Program

## Overview
CUST004 is a COBOL batch program that processes customer data from sequential files and inserts records into the POMS_CUSTO table in DB2. This program generates unique customer IDs, validates input data, and manages database transactions for customer information management.

## Purpose
- **Customer Data Processing**: Process customer records from input files
- **Database Operations**: Insert customer records into DB2 database
- **ID Generation**: Generate unique customer identifiers
- **Error Handling**: Validate data and handle processing errors
- **Reporting**: Provide processing statistics and error reports

## Program Structure

### Identification Division
```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID.  CUST004.
```

### Environment Division
```cobol
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT TI01-CUSTOMER-FILE  ASSIGN TO CUSTIN
           SELECT TO01-CUSTOMER-ERR   ASSIGN TO CUSTERR
```

#### File Definitions
- **TI01-CUSTOMER-FILE**: Input customer file (sequential)
- **TO01-CUSTOMER-ERR**: Error output file (sequential)

### Data Division

#### File Section
```cobol
       FD TI01-CUSTOMER-FILE
           RECORDING MODE          IS F
           RECORD CONTAINS         71  CHARACTERS.

       01 TI01-CUSTOMER-RECORD.
          05 IN-FIRST-NAME    PIC X(10).
          05 IN-LAST-NAME     PIC X(10).
          05 IN-AREA-CODE     PIC X(6).
          05 IN-ADDRESS       PIC X(30).
          05 IN-CITY          PIC X(10).
          05 IN-UNITS         PIC X(5).
```

#### Input Record Format
| Field | Position | Length | Description |
|-------|----------|--------|-------------|
| IN-FIRST-NAME | 1-10 | 10 | Customer's first name |
| IN-LAST-NAME | 11-20 | 10 | Customer's last name |
| IN-AREA-CODE | 21-26 | 6 | Area code |
| IN-ADDRESS | 27-56 | 30 | Street address |
| IN-CITY | 57-66 | 10 | City name |
| IN-UNITS | 67-71 | 5 | Utility units |

#### Working Storage Section
```cobol
       01 WS-FILE-STATUS-CODES.
          05 WS-CUST-STATUS       PIC X(02).
             88 CUST-IO-STATUS    VALUE '00'.
             88 CUST-EOF          VALUE '10'.

       01 WS-SQL-CODES.
          05 WS-SQL-CODE               PIC S9(3) SIGN LEADING SEPARATE.
            88 SQL-IO-STATUS           VALUE 000.
            88 SQL-DUP-ROW             VALUE -803.
            88 SQL-ERROR               VALUE -999 THRU 1.

       01 WS-COUNTERS.
          05 WS-READ-CTR           PIC 9(04) VALUE ZEROS.
          05 WS-DUP-CTR            PIC 9(04) VALUE ZEROS.
          05 WS-ERROR-CTR          PIC 9(04) VALUE ZEROS.
          05 WS-WRITE-CTR          PIC 9(04) VALUE ZEROS.
```

#### Customer ID Generation
```cobol
       01 WS-CUST-ID-GEN.
          05 WS-CUST-PREFIX        PIC X VALUE 'C'.
          05 WS-CUST-FN-CHARS      PIC X(2).
          05 WS-CUST-LN-CHARS      PIC X(2).
          05 WS-CUST-AREA-4        PIC 9(4).
          05 WS-CUST-RAND-3        PIC 9(3).
```

#### Database Variables
```cobol
       EXEC SQL
           INCLUDE CUSTODCL
       END-EXEC.
       EXEC SQL
           INCLUDE SQLCA
       END-EXEC.
```

## Processing Logic

### Main Program Flow
```cobol
       PROCEDURE DIVISION.
       0000-MAIN-LINE   SECTION.
           PERFORM 1000-INITIALIZE.
           PERFORM 2000-PROCESS.
           PERFORM 9000-TERMINATE.
```

### Initialization Phase
```cobol
       1000-INITIALIZE  SECTION.
           DISPLAY '----------------------------------------'
           DISPLAY 'CUST004 EXECUTION BEGINS HERE ..........'
           DISPLAY '  CUSTOMER GENERATION PROGRAM            '
           DISPLAY '----------------------------------------'.
```

### Processing Phase
```cobol
       2000-PROCESS     SECTION.
           PERFORM 2100-OPEN-FILES.
           PERFORM 2200-READ-CUSTOMER-FILE UNTIL CUST-EOF.
```

### File Operations
```cobol
       2100-OPEN-FILES  SECTION.
           OPEN INPUT TI01-CUSTOMER-FILE.
           OPEN OUTPUT TO01-CUSTOMER-ERR.
```

### Record Processing
```cobol
       2200-READ-CUSTOMER-FILE  SECTION.
           READ TI01-CUSTOMER-FILE
                AT END  SET CUST-EOF TO TRUE
                NOT AT END  ADD 1  TO WS-READ-CTR
                            PERFORM 2300-VALIDATE-CUSTOMER
           END-READ.
```

## Data Validation

### Validation Rules
```cobol
       2300-VALIDATE-CUSTOMER SECTION.
           SET VALID-RECORD-FLAG TO TRUE.
           
           IF IN-FIRST-NAME IS EQUAL TO SPACES OR
              IN-LAST-NAME IS EQUAL TO SPACES
              DISPLAY 'CUSTOMER NAME ERROR - FIRST/LAST NAME REQUIRED'
              SET ERROR-RECORD-FLAG TO TRUE
              MOVE TI01-CUSTOMER-RECORD TO TO01-CUSTOMER-ERR-RECORD
              WRITE TO01-CUSTOMER-ERR-RECORD
              ADD 1 TO WS-ERROR-CTR
           END-IF.
```

### Validation Criteria
- **Required Fields**: First name and last name cannot be spaces
- **Data Format**: All fields must contain valid character data
- **Record Length**: Input record must be 71 characters
- **Error Handling**: Invalid records written to error file

## Customer ID Generation

### ID Generation Algorithm
```cobol
       2400-INS-CUSTOMER-DB2 SECTION.
           MOVE IN-FIRST-NAME(1:2)   TO WS-CUST-FN-CHARS.
           MOVE IN-LAST-NAME(1:2)    TO WS-CUST-LN-CHARS.
           MOVE IN-AREA-CODE(1:4)    TO WS-CUST-AREA-4.
           COMPUTE WS-RAND-SEED = FUNCTION RANDOM * 1000.
           COMPUTE WS-CUST-RAND-3 = FUNCTION MOD(WS-RAND-SEED, 1000).

           STRING WS-CUST-PREFIX WS-CUST-FN-CHARS WS-CUST-LN-CHARS
                  WS-CUST-AREA-4 WS-CUST-RAND-3
                  DELIMITED BY SIZE
                  INTO CT-CUSTOMER-ID
           END-STRING.
```

### ID Format
- **Prefix**: 'C' (Customer)
- **First Name**: First 2 characters of first name
- **Last Name**: First 2 characters of last name
- **Area Code**: First 4 characters of area code
- **Random**: 3-digit random number
- **Example**: CJOHNDOE1234501

## Database Operations

### SQL Insert Operation
```cobol
           EXEC SQL  INSERT INTO POMS_CUSTO
                     VALUES (:CT-CUSTOMER-ID,
                             :CT-FIRST-NAME,
                             :CT-LAST-NAME,
                             :CT-AREA-CODE,
                             :CT-ADDRESS,
                             :CT-CITY,
                             :CT-UNITS
                             )
           END-EXEC.
```

### VARCHAR Field Handling
```cobol
      *     MOVE DATA TO VARCHAR TEXT FIELDS
           MOVE IN-FIRST-NAME        TO CT-FIRST-NAME-TEXT.
           MOVE IN-LAST-NAME         TO CT-LAST-NAME-TEXT.
           MOVE IN-AREA-CODE         TO CT-AREA-CODE-TEXT.
           MOVE IN-ADDRESS           TO CT-ADDRESS-TEXT.
           MOVE IN-CITY              TO CT-CITY-TEXT.
           MOVE IN-UNITS             TO CT-UNITS-TEXT.

      *     SET LENGTHS FOR VARCHAR FIELDS
           MOVE 10                   TO CT-FIRST-NAME-LEN.
           MOVE 10                   TO CT-LAST-NAME-LEN.
           MOVE 6                    TO CT-AREA-CODE-LEN.
           MOVE 30                   TO CT-ADDRESS-LEN.
           MOVE 10                   TO CT-CITY-LEN.
           MOVE 5                    TO CT-UNITS-LEN.
```

### Indicator Variables
```cobol
      *     SET INDICATORS TO NON-NULL VALUES
           MOVE 0                    TO CT-CUSTOMER-ID-IND.
           MOVE 0                    TO CT-FIRST-NAME-IND.
           MOVE 0                    TO CT-LAST-NAME-IND.
           MOVE 0                    TO CT-AREA-CODE-IND.
           MOVE 0                    TO CT-ADDRESS-IND.
           MOVE 0                    TO CT-CITY-IND.
           MOVE 0                    TO CT-UNITS-IND.
```

## Error Handling

### SQL Error Processing
```cobol
           MOVE SQLCODE                TO WS-SQL-CODE.
           EVALUATE TRUE
               WHEN SQL-IO-STATUS
                    DISPLAY ' -------------------------------------'
                    DISPLAY 'CUSTOMER INSERTED', ' ', CT-CUSTOMER-ID
                    DISPLAY ' -------------------------------------'
                    ADD 1  TO WS-WRITE-CTR
               WHEN SQL-DUP-ROW
                    DISPLAY ' -------------------------------------'
                    DISPLAY 'CUSTOMER EXISTS  ', ' ', CT-CUSTOMER-ID
                    DISPLAY ' -------------------------------------'
                    ADD 1  TO WS-DUP-CTR
               WHEN OTHER
                    DISPLAY ' -------------------------------------'
                    DISPLAY 'ERROR INSERT CUST',  ':', WS-SQL-CODE
                    DISPLAY 'CUSTOMER ID: ', CT-CUSTOMER-ID
                    DISPLAY ' -------------------------------------'
                    CALL 'DSNTIAR' USING SQLCA
                    ADD 1 TO WS-ERROR-CTR
           END-EVALUATE.
```

### Error Categories
- **SQLCODE = 000**: Successful insert
- **SQLCODE = -803**: Duplicate customer ID
- **SQLCODE < 0**: Other database errors
- **File Errors**: Input/output file issues

## Termination Processing

### Cleanup Operations
```cobol
       9000-TERMINATE   SECTION.
           CLOSE  TI01-CUSTOMER-FILE,
                  TO01-CUSTOMER-ERR.

           EXEC SQL
               COMMIT
           END-EXEC.

           EXEC SQL
               CONNECT RESET
           END-EXEC.
```

### Reporting
```cobol
           DISPLAY '----------------------------------------'
           DISPLAY ' PROCESSING SUMMARY '
           DISPLAY '----------------------------------------'
           DISPLAY ' TOTAL RECORDS READ    : ' WS-READ-CTR
           DISPLAY ' TOTAL RECORDS INSERTED: ' WS-WRITE-CTR
           DISPLAY ' DUPLICATE RECORDS      : ' WS-DUP-CTR
           DISPLAY ' ERROR RECORDS         : ' WS-ERROR-CTR
           DISPLAY '----------------------------------------'
```

## Performance Considerations

### Database Optimization
- **Batch Processing**: Processes records in batches
- **Transaction Management**: Commits at program end
- **Error Handling**: Efficient error detection and reporting
- **Memory Management**: Proper variable usage and cleanup

### File Processing
- **Sequential Access**: Efficient sequential file processing
- **Buffer Management**: Appropriate file buffer sizes
- **Error Recovery**: Robust error handling for file issues

## Security Considerations

### Data Protection
- **Input Validation**: Comprehensive data validation
- **SQL Injection Prevention**: Using parameterized queries
- **Error Logging**: Detailed error logging for troubleshooting
- **Transaction Integrity**: Proper transaction management

### Access Control
- **Database Authority**: Required INSERT authority on POMS_CUSTO
- **File Access**: Read access to input files
- **System Resources**: Appropriate system resource usage

## Usage Instructions

### Input File Requirements
- **Format**: Fixed-length sequential file
- **Record Length**: 71 characters
- **Data Validation**: Required fields must be populated
- **File Location**: Specified in JCL (CUSTIN)

### Execution Steps
1. **Prepare Input File**: Create customer input file
2. **Submit Job**: Use CBLDBRUN JCL to execute
3. **Monitor Execution**: Check job progress and output
4. **Review Results**: Analyze processing statistics
5. **Handle Errors**: Review error file for issues

### Output Analysis
- **Success Records**: Count of successfully inserted customers
- **Duplicate Records**: Count of duplicate customer IDs
- **Error Records**: Count of validation errors
- **Error File**: Detailed error information

## Integration with System

### Database Integration
- **Table**: POMS_CUSTO
- **Dependencies**: CUSTODCL DCLGEN member
- **Relationships**: Links to meter data via customer ID

### File System Integration
- **Input**: Customer sequential file
- **Output**: Error file for invalid records
- **Dependencies**: Proper file allocation and permissions

### Application Integration
- **Related Programs**: MTR002 (meter processing)
- **Data Flow**: Customer data used by meter processing
- **Dependencies**: Customer master data for other applications

## Maintenance and Support

### Regular Maintenance
- **Log Review**: Monitor execution logs
- **Performance Analysis**: Track processing performance
- **Error Analysis**: Analyze error patterns
- **File Cleanup**: Archive old output files

### Updates and Changes
- **Schema Changes**: Update DCLGEN when table changes
- **Business Rules**: Modify validation logic as needed
- **Performance Tuning**: Optimize for large data volumes
- **Error Handling**: Enhance error detection and reporting

## Troubleshooting

### Common Issues
1. **File Not Found**: Check input file allocation
2. **Database Connection**: Verify DB2 connectivity
3. **Duplicate IDs**: Review ID generation logic
4. **Validation Errors**: Check input data format
5. **SQL Errors**: Review database permissions and status

### Diagnostic Steps
1. **Check SYSOUT**: Review job execution log
2. **Examine Error File**: Review validation errors
3. **Verify Database**: Check database connectivity
4. **Test Data**: Validate input data format
5. **Monitor Resources**: Check system resource usage
