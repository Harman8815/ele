# DB2 Customer ID Generation Example

## Overview
Convert `elect001.cobol` from KSDS file I/O to DB2 SQL operations.

---

## Step 1: Add DB2 Declarations

```cobol
       WORKING-STORAGE SECTION.

      *    SQL Communication Area
           EXEC SQL INCLUDE SQLCA END-EXEC.

      *    DCLGEN for CUSTOMER table
           EXEC SQL INCLUDE DCLGEN1 END-EXEC.

      *    SQL variables for customer ID generation
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
           01 WS-DB2-CUST-ID       PIC X(12).
           01 WS-DB2-FNAME         PIC X(15).
           01 WS-DB2-LNAME         PIC X(15).
           01 WS-DB2-AREACODE      PIC X(7).
           01 WS-DB2-COUNT         PIC S9(9) COMP.
           EXEC SQL END DECLARE SECTION END-EXEC.
```

---

## Step 2: Create Customer Table DDL

```sql
CREATE TABLE CUSTOMER (
    CUST_ID          CHAR(12) PRIMARY KEY,
    FNAME            CHAR(15),
    LNAME            CHAR(15),
    AREACODE         CHAR(7),
    ADDRESS1         CHAR(30),
    LOCALITY         CHAR(30),
    CITY             CHAR(20),
    UNITS            CHAR(10),
    STATUS           CHAR(10),
    CREATE_DATE      TIMESTAMP
);

CREATE UNIQUE INDEX IDX_CUST_ID ON CUSTOMER(CUST_ID);
```

---

## Step 3: Replace File Open/Close with DB2 Connect

```cobol
       2100-OPEN-FILES  SECTION.

      *    CONNECT TO DB2
           EXEC SQL
               CONNECT TO DB2PROD
           END-EXEC.

           IF SQLCODE NOT = 0
              DISPLAY 'DB2 CONNECT FAILED: ' SQLCODE
              STOP RUN
           END-IF.

           DISPLAY 'DB2 CONNECTED SUCCESSFULLY'.
```

---

## Step 4: Generate Customer ID with Uniqueness Check

```cobol
       2410-GENERATE-ID.

      *    Generate random number
           COMPUTE WS-RAND-SEED =
               FUNCTION MOD(
                  (WS-RAND-SEED * 1103515245 + 1345 + WS-RETRY-CTR)
                  ,2147483647)

           COMPUTE WS-RAND-RESULT =
               FUNCTION MOD((WS-RAND-SEED * 1664525 + 1013904223), 10000)

           MOVE WS-RAND-RESULT TO WS-RAND-SEED
           MOVE WS-RAND-RESULT TO WS-RAND-4DIGIT
           MOVE WS-RAND-DISPLAY(1:4) TO WS-RAND-4CH.

      *    Build 12-byte customer ID
           MOVE IN-FNAME(1:2)    TO WS-FN-PREFIX.
           MOVE IN-LNAME(1:2)    TO WS-LN-PREFIX.
           MOVE IN-AREACODE(4:4) TO WS-AREA-PREFIX.

           MOVE WS-FN-PREFIX     TO CF-O-CUST-ID(1:2).
           MOVE WS-LN-PREFIX     TO CF-O-CUST-ID(3:2).
           MOVE WS-AREA-PREFIX   TO CF-O-CUST-ID(5:4).
           MOVE WS-RAND-4CH      TO CF-O-CUST-ID(9:4).

      *    Check if ID already exists in DB2
           MOVE CF-O-CUST-ID TO WS-DB2-CUST-ID

           EXEC SQL
               SELECT COUNT(*) INTO :WS-DB2-COUNT
               FROM CUSTOMER
               WHERE CUST_ID = :WS-DB2-CUST-ID
           END-EXEC.

           IF SQLCODE = 0 AND WS-DB2-COUNT > 0
              ADD 1 TO WS-RETRY-CTR
              IF WS-RETRY-CTR <= 99
                 DISPLAY 'DUPLICATE ID - RETRYING: ' CF-O-CUST-ID
                 GO TO 2410-GENERATE-ID
              ELSE
                 DISPLAY 'MAX RETRIES EXCEEDED'
                 MOVE 'ERR999999999' TO CF-O-CUST-ID
              END-IF
           END-IF.

           DISPLAY 'CUSTOMER ID GENERATED: ' CF-O-CUST-ID.
```

---

## Step 5: Insert Customer Record

```cobol
       2400-WRITE-CUST-KSDS SECTION.

           MOVE ZEROES TO WS-RETRY-CTR.

           PERFORM 2410-GENERATE-ID.

      *    Move input data to host variables
           MOVE IN-FNAME    TO WS-DB2-FNAME.
           MOVE IN-LNAME    TO WS-DB2-LNAME.
           MOVE IN-AREACODE TO WS-DB2-AREACODE.

      *    Insert into CUSTOMER table
           EXEC SQL
               INSERT INTO CUSTOMER (
                   CUST_ID,
                   FNAME,
                   LNAME,
                   AREACODE,
                   ADDRESS1,
                   LOCALITY,
                   CITY,
                   UNITS,
                   STATUS,
                   CREATE_DATE
               ) VALUES (
                   :CF-O-CUST-ID,
                   :WS-DB2-FNAME,
                   :WS-DB2-LNAME,
                   :WS-DB2-AREACODE,
                   :IN-ADDRESS1,
                   :IN-LOCALITY,
                   :IN-CITY,
                   :IN-UNITS,
                   :IN-STATUS,
                   CURRENT TIMESTAMP
               )
           END-EXEC.

           EVALUATE SQLCODE
               WHEN 0
                   ADD 1 TO WS-WRITE-CTR
                   DISPLAY 'INSERT SUCCESS: ' CF-O-CUST-ID
               WHEN -803
                   DISPLAY 'DUPLICATE KEY ERROR: ' CF-O-CUST-ID
                   ADD 1 TO WS-ERR-CTR
               WHEN OTHER
                   DISPLAY 'INSERT FAILED: ' SQLCODE
                   ADD 1 TO WS-ERR-CTR
           END-EVALUATE.
```

---

## Step 6: Mainframe Job Steps

### Step 6A: Precompile COBOL
```jcl
//PRECOMP  EXEC PGM=DSNHPC,PARM='HOST(IBMCOB)'
//DBRMLIB  DD DSN=OZA265.TRGA5.DBRM(LIB),DISP=SHR
//SYSCIN   DD DSN=&&SYSCIN,DISP=(NEW,PASS),
//             SPACE=(800,(500,500)),UNIT=VIO
//SYSLIB   DD DSN=OZA265.TRGA5.COBOL.SOURCE,DISP=SHR
//SYSIN    DD DSN=OZA265.TRGA5.COBOL.SOURCE(ELECT001),DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSTERM  DD SYSOUT=*
```

### Step 6B: Compile/Link
```jcl
//COBOL    EXEC PGM=IGYCRCTL,REGION=4M
//SYSLIB   DD DSN=CEE.SCEESAMP,DISP=SHR
//         DD DSN=DSN810.SDSNSAMP,DISP=SHR
//SYSIN    DD DSN=&&SYSCIN,DISP=(OLD,PASS)
//SYSLIN   DD DSN=&&SYSLIN,DISP=(NEW,PASS),
//             SPACE=(800,(500,500)),UNIT=VIO
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
```

### Step 6C: Bind Package
```jcl
//BINDPKG  EXEC PGM=IKJEFT01
//DBRMLIB  DD DSN=OZA265.TRGA5.DBRM,DISP=SHR
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
    DSN SYSTEM(DB2PROD)
    BIND PACKAGE(COLLECTION) -
         MEMBER(ELECT001) -
         ACTION(REPLACE) -
         ISOLATION(CS)
    END
/*
```

### Step 6D: Run Program
```jcl
//RUNPGM   EXEC PGM=IKJEFT01
//STEPLIB  DD DSN=OZA265.TRGA5.COBOL.LOADLIB,DISP=SHR
//         DD DSN=DSN810.SDSNLOAD,DISP=SHR
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
    DSN SYSTEM(DB2PROD)
    RUN PROGRAM(ELECT001) PLAN(PLANNAME) -
        LIB('OZA265.TRGA5.COBOL.LOADLIB')
/*
```

---

## Key Calculations

### Customer ID Format (12 bytes)
```
Positions 1-2:  First 2 chars of First Name (IN-FNAME(1:2))
Positions 3-4:  First 2 chars of Last Name (IN-LNAME(1:2))
Positions 5-8:  Last 4 digits of Area Code (IN-AREACODE(4:4))
Positions 9-12: 4-digit Random Number (WS-RAND-4CH)

Example: Krishna + Mehta + 270829 + 1234 = KrMe08291234
```

### Random Number Generation
```cobol
COMPUTE WS-RAND-SEED =
    FUNCTION MOD((WS-RAND-SEED * 1103515245 + 1345 + WS-RETRY-CTR), 2147483647)

COMPUTE WS-RAND-RESULT =
    FUNCTION MOD((WS-RAND-SEED * 1664525 + 1013904223), 10000)
```

### Duplicate Check Logic
1. Generate ID using formula
2. Execute SELECT COUNT(*) query
3. If count > 0, retry with new random
4. Max 99 retries, then error

---

## Error Handling

| SQLCODE | Meaning | Action |
|---------|---------|--------|
| 0 | Success | Continue |
| -803 | Duplicate key | Retry ID generation |
| -501 | Cursor already closed | Reopen cursor |
| -911 | Deadlock | Rollback and retry |
| -904 | Resource unavailable | Wait and retry |
