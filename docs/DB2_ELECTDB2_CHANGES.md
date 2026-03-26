# DB2 Migration: ELECTDB2

## Original Program: elect001.cobol
## DB2 Version: electdb2.cobol

---

## Summary of Changes

### Files Removed
| DD Name | File Type | Description |
|---------|-----------|-------------|
| MO01-CUST-KSDS | VSAM KSDS | Customer master output file |

### Files Retained
| DD Name | File Type | Description |
|---------|-----------|-------------|
| TI01-CUST-FILE | Sequential | Customer input file |
| TO01-CUST-ERR | Sequential | Error output file |

---

## Detailed Code Changes

### 1. ENVIRONMENT DIVISION - FILE-CONTROL

**REMOVE:**
```cobol
       SELECT MO01-CUST-KSDS  ASSIGN TO CUSTKSDS
       ORGANIZATION           IS INDEXED
       ACCESS MODE            IS RANDOM
       RECORD KEY             IS CF-O-CUST-ID
       FILE STATUS            IS WS-KSDS-STATUS.
```

---

### 2. DATA DIVISION - FILE SECTION

**REMOVE FD entry for:**
- MO01-CUST-KSDS (149 bytes)

**REMOVE FILE STATUS code:**
```cobol
       05 WS-KSDS-STATUS        PIC X(02).
          88 KSDS-IO-STATUS     VALUE '00'.
          88 KSDS-ROW-NOTFND    VALUE '23'.
```

---

### 3. DATA DIVISION - WORKING-STORAGE (ADD)

**ADD SQLCA:**
```cobol
       EXEC SQL
           INCLUDE SQLCA
       END-EXEC.
```

**ADD Host Variables:**
```cobol
       01 HV-CUSTOMER-RECORD.
          05 HV-CUST-ID            PIC X(12).
          05 HV-CUST-FNAME         PIC X(15).
          05 HV-CUST-LNAME         PIC X(15).
          05 HV-CUST-AREACODE      PIC X(7).
          05 HV-CUST-ADDRESS1      PIC X(30).
          05 HV-CUST-LOCALITY      PIC X(30).
          05 HV-CUST-CITY          PIC X(20).
          05 HV-CUST-UNITS         PIC X(10).
          05 HV-CUST-STATUS        PIC X(10).

       01 HV-DBNAME               PIC X(8) VALUE 'ELECTDB'.
```

---

### 4. PROCEDURE DIVISION Changes

#### A. 1000-INITIALIZE SECTION

**ADD DB2 connect call:**
```cobol
       1000-INITIALIZE  SECTION.
           DISPLAY '----------------------------------------'
           DISPLAY 'ELECTDB2 EXECUTION BEGINS HERE .........'
           DISPLAY '----------------------------------------'

           ACCEPT WS-DATE FROM DATE YYYYMMDD.

           PERFORM 2150-DB2-CONNECT.        *> ADD THIS
```

#### B. NEW SECTION: 2150-DB2-CONNECT

**ADD:**
```cobol
       2150-DB2-CONNECT SECTION.
      *    ------------------------------------------------------------
      *    CONNECT TO DB2 DATABASE
      *    Replace 'ELECTDB' with your actual database name
      *    ------------------------------------------------------------
           EXEC SQL
               CONNECT TO :HV-DBNAME
           END-EXEC.

           IF SQLCODE NOT = 0
              DISPLAY 'ERROR CONNECTING TO DB2: SQLCODE=' SQLCODE
              STOP RUN
           END-IF.

           DISPLAY 'DB2 CONNECTION ESTABLISHED SUCCESSFULLY'.
```

#### C. 2100-OPEN-FILES SECTION

**REMOVE KSDS open:**
```cobol
       2100-OPEN-FILES  SECTION.
           OPEN INPUT TI01-CUST-FILE.
           IF NOT CUST-IO-STATUS
              ...
           END-IF.

      *    REMOVE THIS BLOCK:
      *    OPEN OUTPUT MO01-CUST-KSDS
      *    IF NOT KSDS-IO-STATUS
      *       DISPLAY 'ERROR OPENING CUSTOMER KSDS MASTER'
      *       ...
      *    END-IF.

           OPEN OUTPUT TO01-CUST-ERR.
           ...
```

**UPDATE display messages:**
```cobol
           DISPLAY '----------------------------------------'
           DISPLAY 'CUSTOMER INPUT FILE OPENED ..............'
      *    CHANGED: Removed 'CUSTOMER MASTER KSDS IS OPENED'
           DISPLAY 'CUSTOMER ERROR FILE IS OPENED ..........'
           DISPLAY '----------------------------------------'.
```

#### D. 2400-WRITE-CUST-KSDS → 2400-WRITE-CUST-DB2

**RENAME SECTION** from `2400-WRITE-CUST-KSDS` to `2400-WRITE-CUST-DB2`

**REPLACE VSAM WRITE:**
```cobol
       2400-WRITE-CUST-KSDS SECTION.
           MOVE IN-FNAME                 TO OUT-FNAME.
           MOVE IN-LNAME                 TO OUT-LNAME.
           MOVE IN-AREACODE              TO OUT-AREACODE.
           MOVE IN-ADDRESS1              TO OUT-ADDRESS1.
           MOVE IN-LOCALITY              TO OUT-LOCALITY.
           MOVE IN-CITY                  TO OUT-CITY.
           MOVE IN-UNITS                 TO OUT-UNITS.
           MOVE IN-STATUS                TO OUT-STATUS.

           MOVE ZEROES                   TO WS-RETRY-CTR.

       2410-GENERATE-ID.
           ... (ID generation logic) ...
           DISPLAY 'CUSTOMER ID IS',  ' ', CF-O-CUST-ID.

           WRITE MO01-CUSTOMER-RECORD.        *> VSAM WRITE
           DISPLAY '1:' ' ', WS-KSDS-STATUS

           IF WS-KSDS-STATUS = '22'           *> VSAM duplicate check
              ADD 1 TO WS-RETRY-CTR
              IF WS-RETRY-CTR <= 99
                 DISPLAY 'DUPLICATE KEY - RETRYING WITH NEW ID'
                 GO TO 2410-GENERATE-ID
              ELSE
                 DISPLAY 'MAX RETRIES EXCEEDED FOR RECORD'
                 MOVE TI01-CUST-RECORD TO TO01-CUST-ERR-RECORD
                 WRITE TO01-CUST-ERR-RECORD
              END-IF
           ELSE
              ADD 1 TO WS-WRITE-CTR
           END-IF.
```

**WITH DB2 INSERT:**
```cobol
       2400-WRITE-CUST-DB2 SECTION.
      *    ------------------------------------------------------------
      *    INSERT CUSTOMER INTO DB2 CUSTOMER TABLE
      *    ------------------------------------------------------------
           MOVE IN-FNAME                 TO HV-CUST-FNAME.
           MOVE IN-LNAME                 TO HV-CUST-LNAME.
           MOVE IN-AREACODE              TO HV-CUST-AREACODE.
           MOVE IN-ADDRESS1              TO HV-CUST-ADDRESS1.
           MOVE IN-LOCALITY              TO HV-CUST-LOCALITY.
           MOVE IN-CITY                  TO HV-CUST-CITY.
           MOVE IN-UNITS                 TO HV-CUST-UNITS.
           MOVE IN-STATUS                TO HV-CUST-STATUS.

           MOVE ZEROES                   TO WS-RETRY-CTR.

       2410-GENERATE-ID.
           ... (ID generation logic unchanged) ...
           DISPLAY 'CUSTOMER ID IS',  ' ', HV-CUST-ID.

      *    INSERT INTO DB2 CUSTOMER TABLE (replaces VSAM WRITE)
           EXEC SQL
               INSERT INTO CUSTOMER
               (CUST_ID, CUST_FNAME, CUST_LNAME, CUST_AREACODE,
                CUST_ADDRESS1, CUST_LOCALITY, CUST_CITY,
                CUST_UNITS, CUST_STATUS)
               VALUES
               (:HV-CUST-ID, :HV-CUST-FNAME, :HV-CUST-LNAME,
                :HV-CUST-AREACODE, :HV-CUST-ADDRESS1,
                :HV-CUST-LOCALITY, :HV-CUST-CITY,
                :HV-CUST-UNITS, :HV-CUST-STATUS)
           END-EXEC.

      *    Handle SQLCODE results (replaces VSAM FILE STATUS check)
           EVALUATE SQLCODE
               WHEN 0
                   ADD 1 TO WS-WRITE-CTR
                   DISPLAY 'CUSTOMER INSERTED SUCCESSFULLY'
               WHEN -803
                   ADD 1 TO WS-RETRY-CTR
                   IF WS-RETRY-CTR <= 99
                       DISPLAY 'DUPLICATE KEY - RETRYING WITH NEW ID'
                       GO TO 2410-GENERATE-ID
                   ELSE
                       DISPLAY 'MAX RETRIES EXCEEDED FOR RECORD'
                       MOVE TI01-CUST-RECORD TO TO01-CUST-ERR-RECORD
                       WRITE TO01-CUST-ERR-RECORD
                   END-IF
               WHEN OTHER
                   DISPLAY 'DB2 INSERT ERROR: SQLCODE=' SQLCODE
                   MOVE TI01-CUST-RECORD TO TO01-CUST-ERR-RECORD
                   WRITE TO01-CUST-ERR-RECORD
           END-EVALUATE.
```

#### E. 9000-TERMINATE SECTION

**REPLACE:**
```cobol
       9000-TERMINATE   SECTION.
           DISPLAY '----------------------------------------'
           DISPLAY ' INPUT RECORDS PROCESSED  ',  WS-READ-CTR
           DISPLAY ' OUTPUT RECORDS PROCESSED ',  WS-WRITE-CTR
           DISPLAY '----------------------------------------'

           CLOSE  TI01-CUST-FILE,
                  TO01-CUST-ERR,
                  MO01-CUST-KSDS.              *> REMOVE THIS

           DISPLAY '----------------------------------------'
           DISPLAY 'CUSTOMER FILE        IS CLOSED          '
           DISPLAY 'CUSTOMER MASTER KSDS IS CLOSED          '  *> REMOVE
           DISPLAY 'CUSTOMER ERROR FILE  IS CLOSED          '
           DISPLAY '----------------------------------------'

           STOP RUN.
```

**WITH:**
```cobol
       9000-TERMINATE   SECTION.
           DISPLAY '----------------------------------------'
           DISPLAY ' INPUT RECORDS PROCESSED  ',  WS-READ-CTR
           DISPLAY ' OUTPUT RECORDS PROCESSED ',  WS-WRITE-CTR
           DISPLAY '----------------------------------------'

      *    COMMIT WORK AND DISCONNECT FROM DB2
           EXEC SQL
               COMMIT WORK
           END-EXEC.

           EXEC SQL
               DISCONNECT
           END-EXEC.

           CLOSE  TI01-CUST-FILE,
                  TO01-CUST-ERR.

           DISPLAY '----------------------------------------'
           DISPLAY 'CUSTOMER FILE        IS CLOSED          '
           DISPLAY 'CUSTOMER ERROR FILE  IS CLOSED          '
           DISPLAY '----------------------------------------'

           STOP RUN.
```

---

## SQL Code Mapping

| VSAM Operation | DB2 SQL Equivalent |
|----------------|-------------------|
| `OPEN OUTPUT KSDS` | `CONNECT TO database` |
| `WRITE KSDS` | `INSERT INTO CUSTOMER` |
| `FILE STATUS = '00'` | `SQLCODE = 0` |
| `FILE STATUS = '22'` (duplicate) | `SQLCODE = -803` |
| `CLOSE KSDS` | `COMMIT WORK` + `DISCONNECT` |

---

## Required DB2 Table

### CUSTOMER Table
```sql
CREATE TABLE CUSTOMER (
    CUST_ID         CHAR(12) PRIMARY KEY,
    CUST_FNAME      CHAR(15),
    CUST_LNAME      CHAR(15),
    CUST_AREACODE   CHAR(7),
    CUST_ADDRESS1   CHAR(30),
    CUST_LOCALITY   CHAR(30),
    CUST_CITY       CHAR(20),
    CUST_UNITS      CHAR(10),
    CUST_STATUS     CHAR(10)
);
```

---

## JCL for ELECTDB2

### Bind Package
```jcl
//BIND     EXEC PGM=IKJEFT01
//DBRMLIB  DD DSN=YOUR.DBRMLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSIN    DD *
    DSN SYSTEM(DBCG)
    BIND PACKAGE(ELECTDB) MEMBER(ELECTDB2) -
         ACTION(REPLACE) ISOLATION(CS)
    END
/*
```

### Run
```jcl
//RUN      EXEC PGM=IKJEFT01
//STEPLIB  DD DSN=YOUR.LOADLIB,DISP=SHR
//          DD DSN=DSN.V12R1.SDSNLOAD,DISP=SHR
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSTSIN  DD *
    DSN SYSTEM(DBCG)
    RUN PROGRAM(ELECTDB2) PLAN(ELECTPLAN) -
        LIB('YOUR.LOADLIB')
    END
/*
```

---

## Testing Checklist

- [ ] CUSTOMER table created with correct schema
- [ ] DB2 connection successful
- [ ] Input file has valid customer records
- [ ] ID generation creates unique 12-byte IDs
- [ ] SQLCODE -803 triggers retry logic
- [ ] Error records written to error file
- [ ] COMMIT successful at end
- [ ] Record count matches input
