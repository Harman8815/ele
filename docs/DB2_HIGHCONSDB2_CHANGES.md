# DB2 Migration: HIGHCONSDB2

## Original Program: highcons.cobol
## DB2 Version: highconsdb2.cobol

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
| TO01-REPORT | Sequential | High consumption report output |

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
          05 WS-D-RANK             PIC Z9.
          05 FILLER                PIC X(4) VALUE SPACES.
          05 WS-D-CUSTID           PIC X(12).        *> Changed from X(9)
          ...
```

---

### 4. PROCEDURE DIVISION Changes

#### A. 1000-INITIALIZE SECTION

**ADD DB2 connect call:**
```cobol
       1000-INITIALIZE  SECTION.
           ACCEPT WS-DATE FROM DATE YYYYMMDD.
           MOVE WS-CC TO WS-DATE-FMT(1:2).
           MOVE WS-YY TO WS-DATE-FMT(4:2).
           MOVE WS-MM TO WS-DATE-FMT(7:2).
           MOVE WS-DD TO WS-DATE-FMT(10:2).

           PERFORM 2100-OPEN-FILES.
           PERFORM 2150-DB2-CONNECT.        *> ADD THIS
           PERFORM 2200-INIT-TOP5.
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

**REMOVE KSDS opens:**
```cobol
       2100-OPEN-FILES  SECTION.
      *    REMOVE THIS BLOCK:
      *    OPEN INPUT TI01-CUST-KSDS.
      *    IF NOT CUST-IO-STATUS
      *       DISPLAY 'ERROR OPENING CUSTOMER KSDS: ' WS-CUST-STATUS
      *       STOP RUN
      *    END-IF.
      *
      *    REMOVE THIS BLOCK:
      *    OPEN INPUT TI01-METER-KSDS.
      *    IF NOT METER-IO-STATUS
      *       DISPLAY 'ERROR OPENING METER KSDS: ' WS-METER-STATUS
      *       STOP RUN
      *    END-IF.

           OPEN INPUT TI01-READ-TXN.
           ...
           OPEN OUTPUT TO01-REPORT.
           ...
```

#### D. 2300-READ-ALL-TXNS → REPLACE VSAM reads with SQL

**REPLACE meter read:**

**FROM:**
```cobol
       2300-READ-ALL-TXNS  SECTION.
           PERFORM 2400-READ-TXN.
           PERFORM UNTIL TXN-EOF
               ADD 1 TO WS-PROCESSED-CNT
               MOVE TXN-METER-ID TO METER-ID
               READ TI01-METER-KSDS
                    KEY IS METER-ID
                    INVALID KEY
                        CONTINUE
                    NOT INVALID KEY
                        PERFORM 2500-PROCESS-METER
               END-READ
               PERFORM 2400-READ-TXN
           END-PERFORM.
```

**TO:**
```cobol
       2300-READ-ALL-TXNS  SECTION.
           PERFORM 2400-READ-TXN.
           PERFORM UNTIL TXN-EOF
               ADD 1 TO WS-PROCESSED-CNT

      *        FETCH METER FROM DB2 METER TABLE USING METER_ID
               EXEC SQL
                   SELECT METER_ID, METER_CUST_ID,
                          METER_INSTALL_DT, METER_STATUS
                   INTO :HV-METER-ID,
                        :HV-METER-CUST-ID,
                        :HV-METER-INSTALL-DT,
                        :HV-METER-STATUS
                   FROM METER
                   WHERE METER_ID = :TXN-METER-ID
               END-EXEC.

               IF SQLCODE = 0
                   PERFORM 2500-PROCESS-METER
               END-IF

               PERFORM 2400-READ-TXN
           END-PERFORM.
```

#### E. 2500-PROCESS-METER → REPLACE VSAM customer read

**REPLACE customer read:**

**FROM:**
```cobol
       2500-PROCESS-METER  SECTION.
           MOVE METER-CUST-ID TO CUST-ID.
           READ TI01-CUST-KSDS
                KEY IS CUST-ID
                INVALID KEY
                    CONTINUE
                NOT INVALID KEY
                    PERFORM 2600-CALCULATE-AND-INSERT
           END-READ.
```

**TO:**
```cobol
       2500-PROCESS-METER  SECTION.
      *    ------------------------------------------------------------
      *    FETCH CUSTOMER FROM DB2 CUSTOMER TABLE USING METER_CUST_ID
      *    ------------------------------------------------------------
           EXEC SQL
               SELECT CUST_ID, CUST_FNAME, CUST_LNAME,
                      CUST_AREACODE, CUST_ADDRESS1, CUST_LOCALITY,
                      CUST_CITY, CUST_UNITS, CUST_STATUS
               INTO :HV-CUST-ID,
                    :HV-CUST-FNAME,
                    :HV-CUST-LNAME,
                    :HV-CUST-AREACODE,
                    :HV-CUST-ADDRESS1,
                    :HV-CUST-LOCALITY,
                    :HV-CUST-CITY,
                    :HV-CUST-UNITS,
                    :HV-CUST-STATUS
               FROM CUSTOMER
               WHERE CUST_ID = :HV-METER-CUST-ID
           END-EXEC.

           IF SQLCODE = 0
               PERFORM 2600-CALCULATE-AND-INSERT
           END-IF.
```

#### F. 2800-SHIFT-AND-INSERT → UPDATE field references

**UPDATE references:**

**FROM:**
```cobol
       2800-SHIFT-AND-INSERT  SECTION.
           MOVE CUST-ID TO WS-TOP5-CUST-ID(WS-INSERT-POS).
           STRING CUST-FNAME ... CUST-LNAME ...
           MOVE CUST-AREACODE TO WS-TOP5-AREACODE(WS-INSERT-POS).
           MOVE METER-ID TO WS-TOP5-METER-ID(WS-INSERT-POS).
```

**TO:**
```cobol
       2800-SHIFT-AND-INSERT  SECTION.
           MOVE HV-CUST-ID TO WS-TOP5-CUST-ID(WS-INSERT-POS).
           STRING HV-CUST-FNAME ... HV-CUST-LNAME ...
           MOVE HV-CUST-AREACODE TO WS-TOP5-AREACODE(WS-INSERT-POS).
           MOVE HV-METER-ID TO WS-TOP5-METER-ID(WS-INSERT-POS).
```

#### G. 4000-PRINT-TOP5 → UPDATE field references

**FROM:**
```cobol
       4000-PRINT-TOP5  SECTION.
           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 5
               IF WS-TOP5-CONSUMP(WS-IDX) > ZERO
                   MOVE WS-IDX TO WS-D-RANK
                   MOVE WS-TOP5-CUST-ID(WS-IDX) TO WS-D-CUSTID
                   ...
```

**TO:**
```cobol
       4000-PRINT-TOP5  SECTION.
           PERFORM VARYING WS-IDX FROM 1 BY 1 UNTIL WS-IDX > 5
               IF WS-TOP5-CONSUMP(WS-IDX) > ZERO
                   IF WS-LINE-CNT >= WS-LINES-PER-PAGE
                      PERFORM 3000-PRINT-HEADERS
                   END-IF
                   MOVE WS-IDX TO WS-D-RANK
                   MOVE WS-TOP5-CUST-ID(WS-IDX) TO WS-D-CUSTID
                   ...
```

#### H. 9000-TERMINATE SECTION

**REPLACE:**
```cobol
       9000-TERMINATE   SECTION.
           PERFORM 5000-PRINT-SUMMARY.

           CLOSE TI01-CUST-KSDS,          *> REMOVE
                 TI01-METER-KSDS,        *> REMOVE
                 TI01-READ-TXN,
                 TO01-REPORT.
           ...
           STOP RUN.
```

**WITH:**
```cobol
       9000-TERMINATE   SECTION.
           PERFORM 5000-PRINT-SUMMARY.

      *    COMMIT WORK AND DISCONNECT FROM DB2
           EXEC SQL
               COMMIT WORK
           END-EXEC.

           EXEC SQL
               DISCONNECT
           END-EXEC.

           CLOSE TI01-READ-TXN,
                 TO01-REPORT.

           DISPLAY 'TOP 5 HIGHEST CONSUMING CUSTOMERS REPORT COMPLETE'.
           ...
           STOP RUN.
```

---

## SQL Code Mapping

| VSAM Operation | DB2 SQL Equivalent |
|----------------|-------------------|
| `OPEN INPUT KSDS` | `CONNECT TO database` |
| `READ METER-KSDS KEY` (random) | `SELECT...INTO...FROM METER WHERE METER_ID = ...` |
| `READ CUST-KSDS KEY` (random) | `SELECT...INTO...FROM CUSTOMER WHERE CUST_ID = ...` |
| `FILE STATUS = '00'` | `SQLCODE = 0` |
| `INVALID KEY` | `SQLCODE = 100` (row not found) |
| `CLOSE KSDS` | `DISCONNECT` |

---

## Required DB2 Tables

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

## JCL for HIGHCONSDB2

### Bind Package
```jcl
//BIND     EXEC PGM=IKJEFT01
//DBRMLIB  DD DSN=YOUR.DBRMLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSIN    DD *
    DSN SYSTEM(DBCG)
    BIND PACKAGE(ELECTDB) MEMBER(HIGHCONSDB2) -
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
    RUN PROGRAM(HIGHCONSDB2) PLAN(ELECTPLAN) -
        LIB('YOUR.LOADLIB')
    END
/*
```

---

## Testing Checklist

- [ ] CUSTOMER table populated with test data
- [ ] METER table has corresponding records
- [ ] METER_CUST_ID foreign key relationship correct
- [ ] Singleton SELECT on METER returns SQLCODE 0
- [ ] Singleton SELECT on CUSTOMER returns SQLCODE 0
- [ ] Top 5 in-memory table logic works correctly
- [ ] Report output format matches original
- [ ] Threshold calculations (>500 units) correct
