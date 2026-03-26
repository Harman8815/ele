# DB2 Migration: METERDB2

## Original Program: meter001.cobol
## DB2 Version: meterdb2.cobol

---

## Summary of Changes

### Files Removed
| DD Name | File Type | Description |
|---------|-----------|-------------|
| MO01-METER-KSDS | VSAM KSDS | Meter master output file |

### Files Retained
| DD Name | File Type | Description |
|---------|-----------|-------------|
| TI01-METER-FILE | Sequential | Meter input file |
| TO01-METER-ERR | Sequential | Error output file |

---

## Detailed Code Changes

### 1. ENVIRONMENT DIVISION - FILE-CONTROL

**REMOVE:**
```cobol
       SELECT MO01-METER-KSDS  ASSIGN TO MTRKSDS
       ORGANIZATION           IS INDEXED
       ACCESS MODE            IS RANDOM
       RECORD KEY             IS METER-ID
       FILE STATUS            IS WS-KSDS-STATUS.
```

---

### 2. DATA DIVISION - FILE SECTION

**REMOVE FD entry for:**
- MO01-METER-KSDS (34 bytes)

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
       01 HV-METER-RECORD.
          05 HV-METER-ID           PIC X(14).
          05 HV-METER-CUST-ID      PIC X(12) VALUE SPACES.
          05 HV-METER-INSTALL-DT   PIC X(10).
          05 HV-METER-STATUS       PIC X(1).

       01 HV-DBNAME               PIC X(8) VALUE 'ELECTDB'.
```

**NOTE:** `HV-METER-CUST-ID` is `X(12)` to match DB2 CUSTOMER table key.

---

### 4. PROCEDURE DIVISION Changes

#### A. 1000-INITIALIZE SECTION

**ADD DB2 connect call:**
```cobol
       1000-INITIALIZE  SECTION.
           DISPLAY '----------------------------------------'
           DISPLAY 'METERDB2 EXECUTION BEGINS HERE .........'
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
           OPEN INPUT TI01-METER-FILE.
           ...

      *    REMOVE THIS BLOCK:
      *    OPEN OUTPUT MO01-METER-KSDS
      *    IF NOT KSDS-IO-STATUS
      *       DISPLAY 'ERROR OPENING METER KSDS MASTER'
      *       ...
      *    END-IF.

           OPEN OUTPUT TO01-METER-ERR.
           ...
```

**UPDATE display messages:**
```cobol
           DISPLAY '----------------------------------------'
           DISPLAY 'METER INPUT FILE OPENED ..............'
      *    CHANGED: Removed 'METER MASTER KSDS IS OPENED'
           DISPLAY 'METER ERROR FILE IS OPENED ..........'
           DISPLAY '----------------------------------------'.
```

#### D. 2400-WRITE-METER-KSDS → 2400-WRITE-METER-DB2

**RENAME SECTION** from `2400-WRITE-METER-KSDS` to `2400-WRITE-METER-DB2`

**REPLACE VSAM WRITE:**
```cobol
       2400-WRITE-METER-KSDS SECTION.
           MOVE IN-METER-ID              TO WS-HARDCODED-METER-ID.
           MOVE IN-INSTALL-DT            TO OUT-INSTALL-DT.
           MOVE IN-STATUS                TO OUT-STATUS.
           MOVE 0                        TO WS-RETRY-CTR.
           MOVE 99                       TO WS-KSDS-STATUS.

           PERFORM 2410-GENERATE-UNIQUE-METER-ID
               UNTIL WS-KSDS-STATUS = '00' OR WS-RETRY-CTR > 100.

           IF WS-KSDS-STATUS = '00'
              ADD 1 TO WS-WRITE-CTR
              DISPLAY 'METER ID WRITTEN: ' METER-ID
              PERFORM 2420-CALCULATE-CONSUMPTION
           ELSE
              ADD 1 TO WS-ERROR-CTR
              DISPLAY 'ERROR: UNABLE TO WRITE RECORD FOR METER:' ...
           END-IF.

       2410-GENERATE-UNIQUE-METER-ID SECTION.
           ... (ID generation logic) ...
           STRING WS-MTR-PREFIX WS-MTR-CUST-CH1 WS-MTR-CUST-CH2
                  WS-MTR-DD WS-MTR-MM WS-MTR-RAND
                  DELIMITED BY SIZE
                  INTO METER-ID
           END-STRING.
           DISPLAY 'ATTEMPTING METER ID : ' METER-ID.

           WRITE MO01-METER-RECORD           *> VSAM WRITE
               INVALID KEY
                   IF WS-KSDS-STATUS = '22'  *> VSAM duplicate
                      DISPLAY 'DUPLICATE KEY DETECTED: ' METER-ID ...
                      ADD 1 TO WS-DUP-CTR
                      ADD 1 TO WS-RETRY-CTR
                   ELSE
                      DISPLAY 'WRITE ERROR - STATUS: ' WS-KSDS-STATUS
                   END-IF
               NOT INVALID KEY
                   MOVE '00' TO WS-KSDS-STATUS
           END-WRITE.
```

**WITH DB2 INSERT:**
```cobol
       2400-WRITE-METER-DB2 SECTION.
      *    ------------------------------------------------------------
      *    INSERT METER INTO DB2 METER TABLE
      *    ------------------------------------------------------------
           MOVE IN-METER-ID              TO WS-HARDCODED-METER-ID.
           MOVE IN-INSTALL-DT            TO HV-METER-INSTALL-DT.
           MOVE IN-STATUS                TO HV-METER-STATUS.
           MOVE 0                        TO WS-RETRY-CTR.

           PERFORM 2410-GENERATE-UNIQUE-METER-ID
               UNTIL SQLCODE = 0 OR WS-RETRY-CTR > 100.

           IF SQLCODE = 0
              ADD 1 TO WS-WRITE-CTR
              DISPLAY 'METER INSERTED SUCCESSFULLY: ' HV-METER-ID
              PERFORM 2420-CALCULATE-CONSUMPTION
           ELSE
              ADD 1 TO WS-ERROR-CTR
              DISPLAY 'ERROR: UNABLE TO INSERT METER FOR: '
                       IN-METER-ID ' SQLCODE: ' SQLCODE
              DISPLAY 'MAX RETRIES EXCEEDED FOR THIS RECORD'
           END-IF.

       2410-GENERATE-UNIQUE-METER-ID SECTION.
           ... (ID generation logic unchanged) ...
           STRING WS-MTR-PREFIX WS-MTR-CUST-CH1 WS-MTR-CUST-CH2
                  WS-MTR-DD WS-MTR-MM WS-MTR-RAND
                  DELIMITED BY SIZE
                  INTO HV-METER-ID          *> CHANGED: now host variable
           END-STRING.
           DISPLAY 'ATTEMPTING METER ID : ' HV-METER-ID.

      *    INSERT INTO DB2 METER TABLE (replaces VSAM WRITE)
           EXEC SQL
               INSERT INTO METER
               (METER_ID, METER_CUST_ID, METER_INSTALL_DT, METER_STATUS)
               VALUES
               (:HV-METER-ID, :HV-METER-CUST-ID,
                :HV-METER-INSTALL-DT, :HV-METER-STATUS)
           END-EXEC.

      *    Handle SQLCODE results (replaces VSAM FILE STATUS check)
           EVALUATE SQLCODE
               WHEN 0
                   CONTINUE
               WHEN -803
                   DISPLAY 'DUPLICATE KEY DETECTED: ' HV-METER-ID
                           ' - RETRYING...'
                   ADD 1 TO WS-DUP-CTR
                   ADD 1 TO WS-RETRY-CTR
               WHEN OTHER
                   DISPLAY 'DB2 INSERT ERROR: SQLCODE=' SQLCODE
                   ADD 1 TO WS-RETRY-CTR
           END-EVALUATE.
```

#### E. 9000-TERMINATE SECTION

**REPLACE:**
```cobol
       9000-TERMINATE   SECTION.
           DISPLAY '----------------------------------------'
           DISPLAY ' INPUT RECORDS PROCESSED  ',  WS-READ-CTR
           DISPLAY ' OUTPUT RECORDS WRITTEN   ',  WS-WRITE-CTR
           DISPLAY ' DUPLICATE KEY RETRIES    ',  WS-DUP-CTR
           DISPLAY ' ERROR RECORDS            ',  WS-ERROR-CTR
           DISPLAY '----------------------------------------'

           CLOSE  TI01-METER-FILE,
                  TO01-METER-ERR,
                  MO01-METER-KSDS.              *> REMOVE THIS

           DISPLAY '----------------------------------------'
           DISPLAY 'METER FILE        IS CLOSED          '
           DISPLAY 'METER MASTER KSDS IS CLOSED          '  *> REMOVE
           DISPLAY 'METER ERROR FILE  IS CLOSED          '
           DISPLAY '----------------------------------------'

           STOP RUN.
```

**WITH:**
```cobol
       9000-TERMINATE   SECTION.
           DISPLAY '----------------------------------------'
           DISPLAY ' INPUT RECORDS PROCESSED  ',  WS-READ-CTR
           DISPLAY ' OUTPUT RECORDS WRITTEN   ',  WS-WRITE-CTR
           DISPLAY ' DUPLICATE KEY RETRIES    ',  WS-DUP-CTR
           DISPLAY ' ERROR RECORDS            ',  WS-ERROR-CTR
           DISPLAY '----------------------------------------'

      *    COMMIT WORK AND DISCONNECT FROM DB2
           EXEC SQL
               COMMIT WORK
           END-EXEC.

           EXEC SQL
               DISCONNECT
           END-EXEC.

           CLOSE  TI01-METER-FILE,
                  TO01-METER-ERR.

           DISPLAY '----------------------------------------'
           DISPLAY 'METER FILE        IS CLOSED          '
           DISPLAY 'METER ERROR FILE  IS CLOSED          '
           DISPLAY '----------------------------------------'

           STOP RUN.
```

---

## SQL Code Mapping

| VSAM Operation | DB2 SQL Equivalent |
|----------------|-------------------|
| `OPEN OUTPUT KSDS` | `CONNECT TO database` |
| `WRITE KSDS` | `INSERT INTO METER` |
| `FILE STATUS = '00'` | `SQLCODE = 0` |
| `FILE STATUS = '22'` (duplicate) | `SQLCODE = -803` |
| `INVALID KEY` | `SQLCODE NOT = 0` |
| `CLOSE KSDS` | `COMMIT WORK` + `DISCONNECT` |

---

## Required DB2 Table

### METER Table
```sql
CREATE TABLE METER (
    METER_ID            CHAR(14) PRIMARY KEY,
    METER_CUST_ID       CHAR(12),
    METER_INSTALL_DT    CHAR(10),
    METER_STATUS        CHAR(1)
);
```

---

## JCL for METERDB2

### Bind Package
```jcl
//BIND     EXEC PGM=IKJEFT01
//DBRMLIB  DD DSN=YOUR.DBRMLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSIN    DD *
    DSN SYSTEM(DBCG)
    BIND PACKAGE(ELECTDB) MEMBER(METERDB2) -
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
    RUN PROGRAM(METERDB2) PLAN(ELECTPLAN) -
        LIB('YOUR.LOADLIB')
    END
/*
```

---

## Testing Checklist

- [ ] METER table created with correct schema
- [ ] DB2 connection successful
- [ ] Input file has valid meter records
- [ ] Meter ID generation creates unique 14-byte IDs
- [ ] SQLCODE -803 triggers retry logic
- [ ] Error records written to error file
- [ ] COMMIT successful at end
- [ ] Record count matches input

---

## Notes

1. **METER_CUST_ID** is left as spaces since the input file doesn't provide customer linkage. In a real system, you would populate this from a customer assignment process.

2. The ID generation algorithm remains unchanged - it creates 14-character meter IDs with format: `MTR-<CH1><CH2><DD><MM><RAND>`

3. Duplicate key handling uses SQLCODE -803 instead of VSAM status '22'.
