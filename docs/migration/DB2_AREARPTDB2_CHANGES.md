# DB2 Migration: AREARPTDB2

## Original Program: arearpt.cobol
## DB2 Version: arearptdb2.cobol

---

## Summary of Changes

### Files Removed
| DD Name | File Type | Description |
|---------|-----------|-------------|
| TI01-CUST-KSDS | VSAM KSDS | Customer master file |
| TI01-METER-KSDS | VSAM KSDS | Meter master file |

### Files Retained
| DD Name | File Type | Description |
|---------|-----------|-------------|
| TI01-READ-TXN | Sequential | Reading transaction file |
| TO01-REPORT | Sequential | Report output file |

---

## Detailed Code Changes

### 1. ENVIRONMENT DIVISION - FILE-CONTROL

**REMOVE:**
```cobol
       SELECT TI01-CUST-KSDS   ASSIGN TO CUSTKSDS
       ORGANIZATION           IS INDEXED
       ACCESS MODE            IS SEQUENTIAL
       RECORD KEY             IS CUST-ID
       FILE STATUS            IS WS-CUST-STATUS.

       SELECT TI01-METER-KSDS  ASSIGN TO METERKSDS
       ORGANIZATION           IS INDEXED
       ACCESS MODE            IS RANDOM
       RECORD KEY             IS METER-ID
       FILE STATUS            IS WS-METER-STATUS.
```

---

### 2. DATA DIVISION - FILE SECTION

**REMOVE FD entries for:**
- TI01-CUST-KSDS (146 bytes)
- TI01-METER-KSDS (34 bytes)

**REMOVE FILE STATUS codes:**
```cobol
       05 WS-CUST-STATUS        PIC X(02).
          88 CUST-IO-STATUS     VALUE '00'.
          88 CUST-EOF           VALUE '10'.
       05 WS-METER-STATUS       PIC X(02).
          88 METER-IO-STATUS    VALUE '00'.
          88 METER-NOT-FOUND    VALUE '23'.
```

---

### 3. DATA DIVISION - WORKING-STORAGE (ADD)

**ADD SQLCA:**
```cobol
       EXEC SQL
           INCLUDE SQLCA
       END-EXEC.
```

**ADD Cursor Declaration:**
```cobol
       EXEC SQL
           DECLARE CUST_CURSOR CURSOR FOR
           SELECT CUST_ID, CUST_FNAME, CUST_LNAME,
                  CUST_AREACODE, CUST_ADDRESS1, CUST_LOCALITY,
                  CUST_CITY, CUST_UNITS, CUST_STATUS
           FROM CUSTOMER
           ORDER BY CUST_AREACODE, CUST_ID
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

       01 HV-METER-RECORD.
          05 HV-METER-ID           PIC X(14).
          05 HV-METER-CUST-ID      PIC X(12).
          05 HV-METER-INSTALL-DT   PIC X(10).
          05 HV-METER-STATUS       PIC X(1).

       01 HV-DBNAME               PIC X(8) VALUE 'ELECTDB'.
```

**MODIFY Detail Line (CUST-ID length changed):**
```cobol
       01 WS-DETAIL-LINE.
          05 WS-D-AREACODE         PIC X(7).
          05 FILLER                PIC X(4) VALUE SPACES.
          05 WS-D-CUSTID           PIC X(12).        *> Changed from X(9)
          ...
```

---

### 4. PROCEDURE DIVISION Changes

#### A. 1000-INITIALIZE SECTION

**ADD after date formatting:**
```cobol
       1000-INITIALIZE  SECTION.
           ACCEPT WS-DATE FROM DATE YYYYMMDD.
           MOVE WS-CC TO WS-DATE-FMT(1:2).
           MOVE WS-YY TO WS-DATE-FMT(4:2).
           MOVE WS-MM TO WS-DATE-FMT(7:2).
           MOVE WS-DD TO WS-DATE-FMT(10:2).

           PERFORM 2100-OPEN-FILES.

           PERFORM 2150-DB2-CONNECT.        *> ADD THIS
```

#### B. NEW SECTION: 2150-DB2-CONNECT

**ADD:**
```cobol
       2150-DB2-CONNECT SECTION.
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

**REMOVE:**
```cobol
       2100-OPEN-FILES  SECTION.
           OPEN INPUT TI01-CUST-KSDS.         *> REMOVE
           IF NOT CUST-IO-STATUS               *> REMOVE
              DISPLAY 'ERROR OPENING CUSTOMER KSDS: ' WS-CUST-STATUS
              STOP RUN
           END-IF.

           OPEN INPUT TI01-METER-KSDS.        *> REMOVE
           IF NOT METER-IO-STATUS              *> REMOVE
              DISPLAY 'ERROR OPENING METER KSDS: ' WS-METER-STATUS
              STOP RUN
           END-IF.
           ...
```

#### D. 2000-PROCESS SECTION

**REPLACE customer read logic:**

**FROM:**
```cobol
       2000-PROCESS     SECTION.
           PERFORM 2200-READ-CUSTOMER.
           PERFORM UNTIL CUST-EOF
               ...
               PERFORM 2200-READ-CUSTOMER
           END-PERFORM.
```

**TO:**
```cobol
       2000-PROCESS     SECTION.
           EXEC SQL                                   *> ADD
               OPEN CUST_CURSOR
           END-EXEC.

           IF SQLCODE NOT = 0
              DISPLAY 'ERROR OPENING CUSTOMER CURSOR: SQLCODE=' SQLCODE
              STOP RUN
           END-IF.

           PERFORM 2200-FETCH-CUSTOMER.               *> CHANGED

           PERFORM UNTIL SQLCODE = 100                *> CHANGED from CUST-EOF
               IF WS-FIRST-RECORD = 'Y'
                  MOVE HV-CUST-AREACODE TO WS-CURR-AREACODE  *> CHANGED
                  ...
               END-IF

               IF HV-CUST-AREACODE NOT = WS-CURR-AREACODE   *> CHANGED
                  ...
               END-IF

               PERFORM 2300-PROCESS-CUSTOMER
               PERFORM 2200-FETCH-CUSTOMER              *> CHANGED
           END-PERFORM.
```

#### E. 2200-READ-CUSTOMER → 2200-FETCH-CUSTOMER

**REPLACE:**
```cobol
       2200-READ-CUSTOMER  SECTION.
           READ TI01-CUST-KSDS
                AT END  SET CUST-EOF TO TRUE
                NOT AT END  ADD 1  TO WS-READ-CTR
           END-READ.
```

**WITH:**
```cobol
       2200-FETCH-CUSTOMER  SECTION.
           EXEC SQL
               FETCH CUST_CURSOR
               INTO :HV-CUST-ID,
                    :HV-CUST-FNAME,
                    :HV-CUST-LNAME,
                    :HV-CUST-AREACODE,
                    :HV-CUST-ADDRESS1,
                    :HV-CUST-LOCALITY,
                    :HV-CUST-CITY,
                    :HV-CUST-UNITS,
                    :HV-CUST-STATUS
           END-EXEC.

           IF SQLCODE = 0
              ADD 1 TO WS-READ-CTR
           ELSE IF SQLCODE NOT = 100
              DISPLAY 'ERROR FETCHING CUSTOMER: SQLCODE=' SQLCODE
           END-IF.
```

#### F. 2300-PROCESS-CUSTOMER SECTION

**REPLACE meter read:**

**FROM:**
```cobol
       2300-PROCESS-CUSTOMER  SECTION.
           MOVE CUST-AREACODE TO METER-ID.
           READ TI01-METER-KSDS
                KEY IS METER-ID
                INVALID KEY
                    MOVE 'NO METER ' TO WS-D-STATUS
                NOT INVALID KEY
                    PERFORM 2400-PROCESS-METER
           END-READ.
```

**TO:**
```cobol
       2300-PROCESS-CUSTOMER  SECTION.
           EXEC SQL
               SELECT METER_ID, METER_CUST_ID,
                      METER_INSTALL_DT, METER_STATUS
               INTO :HV-METER-ID,
                    :HV-METER-CUST-ID,
                    :HV-METER-INSTALL-DT,
                    :HV-METER-STATUS
               FROM METER
               WHERE METER_CUST_ID = :HV-CUST-ID
           END-EXEC.

           EVALUATE SQLCODE
               WHEN 0
                   PERFORM 2400-PROCESS-METER
               WHEN 100
                   MOVE 'NO METER ' TO WS-D-STATUS
               WHEN OTHER
                   MOVE 'DB2 ERROR' TO WS-D-STATUS
                   DISPLAY 'METER SELECT ERROR: SQLCODE=' SQLCODE
           END-EVALUATE.
```

#### G. 3100-PRINT-DETAIL SECTION

**UPDATE field references:**

**FROM:**
```cobol
       3100-PRINT-DETAIL  SECTION.
           MOVE CUST-AREACODE TO WS-D-AREACODE.
           MOVE CUST-ID TO WS-D-CUSTID.
           STRING CUST-FNAME ... CUST-LNAME ...
```

**TO:**
```cobol
       3100-PRINT-DETAIL  SECTION.
           MOVE HV-CUST-AREACODE TO WS-D-AREACODE.
           MOVE HV-CUST-ID TO WS-D-CUSTID.
           STRING HV-CUST-FNAME ... HV-CUST-LNAME ...
```

#### H. 9000-TERMINATE SECTION

**REPLACE:**
```cobol
       9000-TERMINATE   SECTION.
           CLOSE TI01-CUST-KSDS,          *> REMOVE
                 TI01-METER-KSDS,         *> REMOVE
                 TI01-READ-TXN,
                 TO01-REPORT.
           ...
           STOP RUN.
```

**WITH:**
```cobol
       9000-TERMINATE   SECTION.
           EXEC SQL
               CLOSE CUST_CURSOR
           END-EXEC.

           EXEC SQL
               COMMIT WORK
           END-EXEC.

           EXEC SQL
               DISCONNECT
           END-EXEC.

           CLOSE TI01-READ-TXN,
                 TO01-REPORT.
           ...
           STOP RUN.
```

---

## SQL Code Mapping

| VSAM Operation | DB2 SQL Equivalent |
|----------------|-------------------|
| `OPEN INPUT KSDS` | `CONNECT TO database` |
| `READ KSDS` (sequential) | `DECLARE CURSOR...OPEN...FETCH` |
| `READ KSDS KEY IS` (random) | `SELECT...INTO...WHERE` |
| `CLOSE KSDS` | `CLOSE cursor` / `DISCONNECT` |
| `FILE STATUS = '00'` | `SQLCODE = 0` |
| `FILE STATUS = '10'` (EOF) | `SQLCODE = 100` |
| `FILE STATUS = '23'` (not found) | `SQLCODE = 100` |
| `FILE STATUS = '22'` (duplicate) | `SQLCODE = -803` |

---

## JCL Changes for AREARPTDB2

### Precompile Step (NEW)
```jcl
//PC      EXEC PGM=DSNHPC,
//        PARM='HOST(COB2),APOSTSQL,SOURCE'
//DBRMLIB  DD DSN=YOUR.DBRMLIB(AREARPTDB2),DISP=SHR
//SYSCIN   DD DSN=&&PRECOMP,DISP=(NEW,PASS),UNIT=SYSDA
//SYSLIB   DD DSN=YOUR.COBOL.SOURCE,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSTERM  DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSUT2   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSIN    DD DSN=YOUR.COBOL.SOURCE(AREARPTDB2),DISP=SHR
```

### Bind Step (NEW)
```jcl
//BIND     EXEC PGM=IKJEFT01
//DBRMLIB  DD DSN=YOUR.DBRMLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSIN    DD *
    DSN SYSTEM(DBCG)
    BIND PACKAGE(ELECTDB) MEMBER(AREARPTDB2) -
         ACTION(REPLACE) ISOLATION(CS)
    END
/*
```

### Run Step (MODIFIED)
```jcl
//RUN      EXEC PGM=IKJEFT01
//STEPLIB  DD DSN=YOUR.LOADLIB,DISP=SHR
//          DD DSN=DSN.V12R1.SDSNLOAD,DISP=SHR  <-- ADD DB2 LIBRARY
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSTSIN  DD *
    DSN SYSTEM(DBCG)
    RUN PROGRAM(AREARPTDB2) PLAN(ELECTPLAN) -
        LIB('YOUR.LOADLIB')
    END
/*
```

---

## Testing Notes

1. Ensure CUSTOMER table is populated with data
2. Ensure METER table has corresponding METER_CUST_ID foreign keys
3. Verify cursor returns rows in correct order (by AREACODE, CUST_ID)
4. Check that singleton SELECT on METER handles SQLCODE 100 (no meter found)
5. Verify report output format matches original

---

## Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| SQLCODE -805 | Package not bound | Run BIND PACKAGE step |
| SQLCODE -501 | Cursor not open | Check OPEN cursor before FETCH |
| SQLCODE -305 | NULL value returned | Add indicator variables |
| SQLCODE -204 | Table not found | Check table name, ensure created |
| SQLCODE -551 | No privileges | Grant SELECT on tables |
