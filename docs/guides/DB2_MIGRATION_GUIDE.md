# DB2 Migration Documentation

## Overview

This document explains the changes made to convert VSAM/KSDS-based COBOL programs to DB2 SQL-based programs.

## Program Mapping

| Original VSAM Program | DB2 Version | Purpose |
|----------------------|-------------|---------|
| `arearpt.cobol` | `arearptdb2.cobol` | Area-wise consumption report |
| `billpay.cobol` | `billpaydb2.cobol` | Bill payment processing |
| `elect001.cobol` | `electdb2.cobol` | Customer master creation |
| `highcons.cobol` | `highconsdb2.cobol` | High consumption report |
| `meter001.cobol` | `meterdb2.cobol` | Meter master creation |

---

## Common Changes Across All Programs

### 1. SQL Communication Area

**Add to WORKING-STORAGE SECTION:**

```cobol
       EXEC SQL
           INCLUDE SQLCA
       END-EXEC.
```

This includes the SQL Communication Area for error handling.

### 2. Database Connection

**Add new section:**

```cobol
       2150-DB2-CONNECT SECTION.
           EXEC SQL
               CONNECT TO :HV-DBNAME
           END-EXEC.

           IF SQLCODE NOT = 0
              DISPLAY 'ERROR CONNECTING TO DB2: SQLCODE=' SQLCODE
              STOP RUN
           END-IF.
```

### 3. SQLCODE Handling

Replace VSAM FILE STATUS checks with SQLCODE checks:

| VSAM Status | SQLCODE Meaning |
|-------------|-----------------|
| '00' | 0 (Success) |
| '10' (EOF) | 100 (No row found/End of data) |
| '22' (Duplicate) | -803 (Duplicate key) |
| '23' (Not found) | 100 (Row not found) |

### 4. Termination Changes

**Replace file CLOSE with DB2 disconnect:**

```cobol
       9000-TERMINATE SECTION.
      *    COMMIT WORK AND DISCONNECT FROM DB2
           EXEC SQL
               COMMIT WORK
           END-EXEC.

           EXEC SQL
               DISCONNECT
           END-EXEC.

           CLOSE [sequential files only]...
           STOP RUN.
```

---

## Program-Specific Changes

### 1. AREARPTDB2 (Area-wise Consumption Report)

#### Removed:
- `TI01-CUST-KSDS` (VSAM Customer file)
- `TI01-METER-KSDS` (VSAM Meter file)

#### Added:
- **Cursor for CUSTOMER table:**
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

- **Host variables:**
```cobol
       01 HV-CUSTOMER-RECORD.
          05 HV-CUST-ID            PIC X(12).
          05 HV-CUST-FNAME         PIC X(15).
          05 HV-CUST-LNAME         PIC X(15).
          05 HV-CUST-AREACODE      PIC X(7).
          ...
```

#### Key Changes:
1. **Customer read** changed from `READ KSDS` to `FETCH CUST_CURSOR`
2. **Meter lookup** changed from `READ KSDS KEY` to `SELECT ... FROM METER WHERE METER_CUST_ID = ...`
3. Changed `CUST-ID` length from X(9) to X(12) to match DB2 schema

---

### 2. BILLPAYDB2 (Bill Payment Processing)

#### Removed:
- `TI01-BILL-KSDS` (VSAM Bill file)
- `MO01-BILL-UPD` (VSAM Updated bill file)

#### Added:
- **Cursor for BILL table:**
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

- **INSERT statement for BILL_UPDATE:**
```cobol
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
```

#### Key Changes:
1. **Bill read** changed from `READ KSDS` to `FETCH BILL_CURSOR`
2. **Bill update** changed from `WRITE KSDS` to `INSERT INTO BILL_UPDATE`
3. Uses INSERT instead of WRITE for audit trail

---

### 3. ELECTDB2 (Customer Master Creation)

#### Removed:
- `MO01-CUST-KSDS` (VSAM Customer master file)
- All VSAM OPEN/CLOSE/WRITE operations

#### Added:
- **INSERT statement for CUSTOMER:**
```cobol
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
```

#### Key Changes:
1. **Customer ID generation** logic remains same
2. **Duplicate handling** changed from VSAM STATUS '22' to SQLCODE -803
3. Changed from `WRITE KSDS` to `INSERT INTO CUSTOMER`

#### Error Handling:
```cobol
           EVALUATE SQLCODE
               WHEN 0
                   ADD 1 TO WS-WRITE-CTR
               WHEN -803
                   ADD 1 TO WS-RETRY-CTR
                   IF WS-RETRY-CTR <= 99
                       DISPLAY 'DUPLICATE KEY - RETRYING'
                       GO TO 2410-GENERATE-ID
                   ELSE
                       DISPLAY 'MAX RETRIES EXCEEDED'
               WHEN OTHER
                   DISPLAY 'DB2 INSERT ERROR: SQLCODE=' SQLCODE
           END-EVALUATE.
```

---

### 4. HIGHCONSDB2 (High Consumption Report)

#### Removed:
- `TI01-CUST-KSDS` (VSAM Customer file)
- `TI01-METER-KSDS` (VSAM Meter file)

#### Added:
- **SELECT statements for CUSTOMER and METER tables:**
```cobol
      *    FETCH METER FROM DB2 METER TABLE USING METER_ID
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

      *    FETCH CUSTOMER FROM DB2 CUSTOMER TABLE
           EXEC SQL
               SELECT CUST_ID, CUST_FNAME, CUST_LNAME, ...
               INTO :HV-CUST-ID, ...
               FROM CUSTOMER
               WHERE CUST_ID = :HV-METER-CUST-ID
           END-EXEC.
```

#### Key Changes:
1. **Random meter lookup** changed from `READ KSDS KEY` to singleton SELECT
2. **Customer lookup** changed from `READ KSDS KEY` to singleton SELECT
3. Maintains in-memory TOP5 table logic unchanged

---

### 5. METERDB2 (Meter Master Creation)

#### Removed:
- `MO01-METER-KSDS` (VSAM Meter master file)
- All VSAM OPEN/CLOSE/WRITE operations

#### Added:
- **INSERT statement for METER:**
```cobol
           EXEC SQL
               INSERT INTO METER
               (METER_ID, METER_CUST_ID, METER_INSTALL_DT, METER_STATUS)
               VALUES
               (:HV-METER-ID, :HV-METER-CUST-ID,
                :HV-METER-INSTALL-DT, :HV-METER-STATUS)
           END-EXEC.
```

#### Key Changes:
1. **Meter ID generation** logic remains same
2. **Duplicate handling** changed from VSAM STATUS '22' to SQLCODE -803
3. Changed from `WRITE KSDS` to `INSERT INTO METER`
4. `METER-CUST-ID` changed from X(9) to X(12) to match DB2 schema

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

### BILL Table
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

### BILL_UPDATE Table
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

## Compilation JCL Changes

### Original VSAM Compile Step:
```jcl
//COBOL EXEC PGM=IGYCRCTL,
//       PARM='OBJECT,NODYNAM,RENT,LIST'
```

### DB2 Compile Step (Add precompiler):
```jcl
//PC    EXEC PGM=DSNHPC,
//      PARM='HOST(COB2),APOSTSQL,SOURCE'
//DBRMLIB DD DSN=YOUR.DBRMLIB(AREARPTDB2),DISP=SHR
//SYSCIN  DD DSN=&&PRECOMP,DISP=(NEW,PASS),UNIT=SYSDA
//SYSLIB  DD DSN=YOUR.COBOL.SOURCE,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSTERM  DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSUT2   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSIN    DD DSN=YOUR.COBOL.SOURCE(AREARPTDB2),DISP=SHR
```

### Link Edit (Add DB2 Library):
```jcl
//LKED  EXEC PGM=IEWL,
//      PARM='LIST,LET,XREF,RENT'
//SYSLIB   DD DSN=CEE.SCEELKED,DISP=SHR
//          DD DSN=DSN.V12R1.SDSNLOAD,DISP=SHR  <-- ADD DB2 LIB
//SYSLMOD  DD DSN=YOUR.LOADLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(TRK,(10,10))
//SYSLIN   DD DSN=&&PRECOMP,DISP=(OLD,DELETE)
//          DD DDNAME=SYSIN
```

---

## Execution JCL Changes

### Add DB2 Plan/Package Binding:
```jcl
//BIND    EXEC PGM=IKJEFT01
//STEPLIB  DD DSN=DSN.V12R1.SDSNLOAD,DISP=SHR
//DBRMLIB  DD DSN=YOUR.DBRMLIB,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSIN    DD *
    DSN SYSTEM(DBCG)
    BIND PACKAGE(ELECTDB) -
         MEMBER(AREARPTDB2) -
         ACTION(REPLACE) -
         ISOLATION(CS) -
         VALIDATE(BIND)
    BIND PLAN(ELECTPLAN) -
         PKLIST(ELECTDB.*) -
         ACTION(REPLACE) -
         ISOLATION(CS) -
         VALIDATE(BIND)
    END
/*
```

### Run Step:
```jcl
//RUN     EXEC PGM=IKJEFT01
//STEPLIB  DD DSN=YOUR.LOADLIB,DISP=SHR
//          DD DSN=DSN.V12R1.SDSNLOAD,DISP=SHR
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

## Testing Checklist

- [ ] All DB2 tables created with correct schema
- [ ] DB2 connection successful
- [ ] Cursor operations work (OPEN, FETCH, CLOSE)
- [ ] Singleton SELECT statements return correct data
- [ ] INSERT statements execute without errors
- [ ] SQLCODE -803 (duplicate) handling works
- [ ] SQLCODE 100 (EOF) handling works
- [ ] COMMIT/ROLLBACK work correctly
- [ ] Program terminates cleanly with DISCONNECT
- [ ] Report outputs match VSAM version

---

## Troubleshooting

### SQLCODE -805 (Program not found)
- Bind the DBRM to create package and plan
- Ensure plan name matches in RUN JCL

### SQLCODE -305 (Null value retrieved)
- Check for NULLable columns in DB2
- Use indicator variables in COBOL

### SQLCODE -501 (Cursor not open)
- Ensure cursor is opened before FETCH
- Check for premature CLOSE

### SQLCODE -805 (Timestamp mismatch)
- Recompile and rebind after source changes
- Ensure DBRMLIB matches load module
