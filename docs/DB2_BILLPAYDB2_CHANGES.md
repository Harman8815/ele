# DB2 Migration: BILLPAYDB2

## Original Program: billpay.cobol
## DB2 Version: billpaydb2.cobol

---

## Summary of Changes

### Files Removed
| DD Name | File Type | Description |
|---------|-----------|-------------|
| TI01-BILL-KSDS | VSAM KSDS | Bill master file |
| MO01-BILL-UPD | VSAM KSDS | Updated bill output file |

### Files Retained
| DD Name | File Type | Description |
|---------|-----------|-------------|
| TI01-PAYMENT | Sequential | Payment transaction file |
| TO01-PAY-REPORT | Sequential | Payment report output |

---

## Detailed Code Changes

### 1. ENVIRONMENT DIVISION - FILE-CONTROL

**REMOVE:**
```cobol
       SELECT TI01-BILL-KSDS   ASSIGN TO BILLKSDS
       ORGANIZATION           IS INDEXED
       ACCESS MODE            IS SEQUENTIAL
       RECORD KEY             IS BILL-ID
       FILE STATUS            IS WS-BILL-STATUS.

       SELECT MO01-BILL-UPD    ASSIGN TO BILLUPD
       ORGANIZATION           IS INDEXED
       ACCESS MODE            IS RANDOM
       RECORD KEY             IS UPD-BILL-ID
       FILE STATUS            IS WS-UPD-STATUS.
```

---

### 2. DATA DIVISION - FILE SECTION

**REMOVE FD entries for:**
- TI01-BILL-KSDS (85 bytes)
- MO01-BILL-UPD (95 bytes)

**REMOVE FILE STATUS codes:**
```cobol
       05 WS-BILL-STATUS        PIC X(02).
          88 BILL-IO-STATUS     VALUE '00'.
          88 BILL-EOF           VALUE '10'.
       05 WS-UPD-STATUS         PIC X(02).
          88 UPD-IO-STATUS      VALUE '00'.
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
           DECLARE BILL_CURSOR CURSOR FOR
           SELECT BILL_ID, BILL_CUST_ID, BILL_CUST_NAME,
                  BILL_METER_ID, BILL_READ_DATE, BILL_UNITS,
                  BILL_AMOUNT, BILL_STATUS
           FROM BILL
           ORDER BY BILL_ID
       END-EXEC.
```

**ADD Host Variables:**
```cobol
       01 HV-BILL-RECORD.
          05 HV-BILL-ID            PIC X(14).
          05 HV-BILL-CUST-ID       PIC X(12).
          05 HV-BILL-CUST-NAME     PIC X(30).
          05 HV-BILL-METER-ID      PIC X(14).
          05 HV-BILL-READ-DATE     PIC X(10).
          05 HV-BILL-UNITS         PIC 9(7)V99.
          05 HV-BILL-AMOUNT        PIC 9(9)V99.
          05 HV-BILL-STATUS        PIC X(2).

       01 HV-BILL-UPD-RECORD.
          05 HV-UPD-BILL-ID        PIC X(14).
          05 HV-UPD-CUST-ID        PIC X(12).
          05 HV-UPD-CUST-NAME      PIC X(30).
          05 HV-UPD-METER-ID       PIC X(14).
          05 HV-UPD-READ-DATE      PIC X(10).
          05 HV-UPD-UNITS          PIC 9(7)V99.
          05 HV-UPD-AMOUNT         PIC 9(9)V99.
          05 HV-UPD-PAID           PIC 9(9)V99.
          05 HV-UPD-BALANCE        PIC 9(9)V99.
          05 HV-UPD-STATUS         PIC X(2).

       01 HV-DBNAME               PIC X(8) VALUE 'ELECTDB'.
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

**REMOVE Bill KSDS open:**
```cobol
       2100-OPEN-FILES  SECTION.
      *    REMOVE THIS BLOCK:
      *    OPEN INPUT TI01-BILL-KSDS.
      *    IF NOT BILL-IO-STATUS
      *       DISPLAY 'ERROR OPENING BILL KSDS: ' WS-BILL-STATUS
      *       STOP RUN
      *    END-IF.
      *
      *    REMOVE THIS BLOCK:
      *    OPEN OUTPUT MO01-BILL-UPD.
      *    IF NOT UPD-IO-STATUS
      *       DISPLAY 'ERROR OPENING UPDATED BILL KSDS: ' WS-UPD-STATUS
      *       STOP RUN
      *    END-IF.

           OPEN INPUT TI01-PAYMENT.
           ...
           OPEN OUTPUT TO01-PAY-REPORT.
           ...
```

#### D. 2000-PROCESS SECTION

**REPLACE bill read loop:**

**FROM:**
```cobol
       2000-PROCESS     SECTION.
           PERFORM 3000-PRINT-HEADERS.
           PERFORM 2200-READ-PAYMENT.
           PERFORM 2300-READ-BILL.
           PERFORM UNTIL BILL-EOF
               ...
               PERFORM 2300-READ-BILL
           END-PERFORM.
```

**TO:**
```cobol
       2000-PROCESS     SECTION.
           PERFORM 3000-PRINT-HEADERS.
           PERFORM 2200-READ-PAYMENT.

      *    OPEN BILL CURSOR
           EXEC SQL
               OPEN BILL_CURSOR
           END-EXEC.

           IF SQLCODE NOT = 0
              DISPLAY 'ERROR OPENING BILL CURSOR: SQLCODE=' SQLCODE
              STOP RUN
           END-IF.

           PERFORM 2300-READ-BILL.

           PERFORM UNTIL SQLCODE = 100        *> CHANGED from BILL-EOF
               ...
               PERFORM 2600-WRITE-UPDATED-BILL  *> CHANGED (now INSERT)
               ...
               PERFORM 2300-READ-BILL
           END-PERFORM.
```

#### E. 2300-READ-BILL SECTION

**REPLACE:**
```cobol
       2300-READ-BILL  SECTION.
           READ TI01-BILL-KSDS
                AT END  SET BILL-EOF TO TRUE
                NOT AT END  CONTINUE
           END-READ.
```

**WITH:**
```cobol
       2300-READ-BILL  SECTION.
           EXEC SQL
               FETCH BILL_CURSOR
               INTO :HV-BILL-ID,
                    :HV-BILL-CUST-ID,
                    :HV-BILL-CUST-NAME,
                    :HV-BILL-METER-ID,
                    :HV-BILL-READ-DATE,
                    :HV-BILL-UNITS,
                    :HV-BILL-AMOUNT,
                    :HV-BILL-STATUS
           END-EXEC.

           IF SQLCODE NOT = 0 AND SQLCODE NOT = 100
              DISPLAY 'ERROR FETCHING BILL: SQLCODE=' SQLCODE
           END-IF.
```

#### F. 2600-WRITE-UPDATED-BILL SECTION (MAJOR CHANGE)

**REPLACE:**
```cobol
       2600-WRITE-UPDATED-BILL  SECTION.
           MOVE BILL-ID TO UPD-BILL-ID
           MOVE BILL-CUST-ID TO UPD-CUST-ID
           MOVE BILL-CUST-NAME TO UPD-CUST-NAME
           MOVE BILL-METER-ID TO UPD-METER-ID
           MOVE BILL-READ-DATE TO UPD-READ-DATE
           MOVE BILL-UNITS TO UPD-UNITS
           MOVE BILL-AMOUNT TO UPD-AMOUNT
           MOVE WS-TOTAL-PAID TO UPD-PAID
           MOVE WS-BALANCE TO UPD-BALANCE

           WRITE MO01-BILL-UPD-RECORD.        *> VSAM WRITE

           ADD BILL-AMOUNT TO WS-TOTAL-AMOUNT
           ADD WS-TOTAL-PAID TO WS-TOTAL-PAID-ALL
           ADD WS-BALANCE TO WS-TOTAL-BALANCE.
```

**WITH:**
```cobol
       2600-WRITE-UPDATED-BILL  SECTION.
      *    ------------------------------------------------------------
      *    INSERT UPDATED BILL INTO BILL_UPDATE TABLE (was VSAM WRITE)
      *    ------------------------------------------------------------
           MOVE HV-BILL-ID TO HV-UPD-BILL-ID
           MOVE HV-BILL-CUST-ID TO HV-UPD-CUST-ID
           MOVE HV-BILL-CUST-NAME TO HV-UPD-CUST-NAME
           MOVE HV-BILL-METER-ID TO HV-UPD-METER-ID
           MOVE HV-BILL-READ-DATE TO HV-UPD-READ-DATE
           MOVE HV-BILL-UNITS TO HV-UPD-UNITS
           MOVE HV-BILL-AMOUNT TO HV-UPD-AMOUNT
           MOVE WS-TOTAL-PAID TO HV-UPD-PAID
           MOVE WS-BALANCE TO HV-UPD-BALANCE

           EXEC SQL
               INSERT INTO BILL_UPDATE
               (BILL_ID, CUST_ID, CUST_NAME, METER_ID,
                READ_DATE, UNITS, AMOUNT, PAID, BALANCE, STATUS)
               VALUES
               (:HV-UPD-BILL-ID, :HV-UPD-CUST-ID, :HV-UPD-CUST-NAME,
                :HV-UPD-METER-ID, :HV-UPD-READ-DATE, :HV-UPD-UNITS,
                :HV-UPD-AMOUNT, :HV-UPD-PAID, :HV-UPD-BALANCE,
                :HV-UPD-STATUS)
           END-EXEC.

           IF SQLCODE NOT = 0
              DISPLAY 'ERROR INSERTING BILL_UPDATE: SQLCODE=' SQLCODE
           END-IF.

           ADD HV-BILL-AMOUNT TO WS-TOTAL-AMOUNT
           ADD WS-TOTAL-PAID TO WS-TOTAL-PAID-ALL
           ADD WS-BALANCE TO WS-TOTAL-BALANCE.
```

#### G. 2700-PRINT-DETAIL SECTION

**UPDATE references:**

**FROM:**
```cobol
       2700-PRINT-DETAIL  SECTION.
           MOVE BILL-ID TO WS-D-BILLID
           MOVE BILL-CUST-ID TO WS-D-CUSTID
           MOVE BILL-AMOUNT TO WS-D-BILL-AMT
           ...
```

**TO:**
```cobol
       2700-PRINT-DETAIL  SECTION.
           MOVE HV-BILL-ID TO WS-D-BILLID
           MOVE HV-BILL-CUST-ID TO WS-D-CUSTID
           MOVE HV-BILL-AMOUNT TO WS-D-BILL-AMT
           ...
```

#### H. 9000-TERMINATE SECTION

**REPLACE:**
```cobol
       9000-TERMINATE   SECTION.
           CLOSE TI01-BILL-KSDS,          *> REMOVE
                 MO01-BILL-UPD,            *> REMOVE
                 TI01-PAYMENT,
                 TO01-PAY-REPORT.
           ...
           STOP RUN.
```

**WITH:**
```cobol
       9000-TERMINATE   SECTION.
      *    CLOSE DB2 CURSOR
           EXEC SQL
               CLOSE BILL_CURSOR
           END-EXEC.

      *    COMMIT WORK AND DISCONNECT FROM DB2
           EXEC SQL
               COMMIT WORK
           END-EXEC.

           EXEC SQL
               DISCONNECT
           END-EXEC.

           CLOSE TI01-PAYMENT,
                 TO01-PAY-REPORT.
           ...
           STOP RUN.
```

---

## SQL Code Mapping

| VSAM Operation | DB2 SQL Equivalent |
|----------------|-------------------|
| `OPEN INPUT BILL-KSDS` | `DECLARE CURSOR...OPEN BILL_CURSOR` |
| `READ BILL-KSDS` | `FETCH BILL_CURSOR` |
| `WRITE BILL-UPD` | `INSERT INTO BILL_UPDATE` |
| `CLOSE BILL-KSDS` | `CLOSE BILL_CURSOR` |
| `FILE STATUS = '00'` | `SQLCODE = 0` |
| `FILE STATUS = '10'` (EOF) | `SQLCODE = 100` |

---

## Required DB2 Tables

### BILL Table (Source)
```sql
CREATE TABLE BILL (
    BILL_ID         CHAR(14) PRIMARY KEY,
    BILL_CUST_ID    CHAR(12),
    BILL_CUST_NAME  CHAR(30),
    BILL_METER_ID   CHAR(14),
    BILL_READ_DATE  CHAR(10),
    BILL_UNITS      DECIMAL(9,2),
    BILL_AMOUNT     DECIMAL(11,2),
    BILL_STATUS     CHAR(2)
);
```

### BILL_UPDATE Table (Target)
```sql
CREATE TABLE BILL_UPDATE (
    BILL_ID         CHAR(14),
    CUST_ID         CHAR(12),
    CUST_NAME       CHAR(30),
    METER_ID        CHAR(14),
    READ_DATE       CHAR(10),
    UNITS           DECIMAL(9,2),
    AMOUNT          DECIMAL(11,2),
    PAID            DECIMAL(11,2),
    BALANCE         DECIMAL(11,2),
    STATUS          CHAR(2),
    UPDATE_TS       TIMESTAMP DEFAULT CURRENT TIMESTAMP
);
```

---

## JCL for BILLPAYDB2

### Bind Package
```jcl
//BIND     EXEC PGM=IKJEFT01
//DBRMLIB  DD DSN=YOUR.DBRMLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSIN    DD *
    DSN SYSTEM(DBCG)
    BIND PACKAGE(ELECTDB) MEMBER(BILLPAYDB2) -
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
    RUN PROGRAM(BILLPAYDB2) PLAN(ELECTPLAN) -
        LIB('YOUR.LOADLIB')
    END
/*
```

---

## Testing Checklist

- [ ] BILL table populated with test data
- [ ] Payment file has matching BILL_ID values
- [ ] Cursor opens successfully
- [ ] FETCH returns correct bill records
- [ ] INSERT into BILL_UPDATE works
- [ ] Payment aggregation logic correct
- [ ] Report formatting correct
- [ ] COMMIT successful at end
