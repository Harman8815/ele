# CICS Customer System - Line-by-Line Documentation

## Table of Contents
1. [COBOL Programs](#cobol-programs)
   - [ECSTC030 - Customer Create](#ecstc030---customer-create)
   - [ECSTR040 - Customer Read](#ecstr040---customer-read)
   - [ECSTU050 - Customer Update](#ecstu050---customer-update)
   - [EMNUO010 - Main Menu](#emnuo010---main-menu)
   - [EMNUO020 - Sub Menu](#emnuo020---sub-menu)
2. [Map Definitions](#map-definitions)
   - [eb01msd - Customer Create Map](#eb01msd---customer-create-map)
   - [eb02msd - Customer Read Map](#eb02msd---customer-read-map)
   - [eb03msd - Customer Update Map](#eb03msd---customer-update-map)
   - [eb04msd - Customer Read Screen](#eb04msd---customer-read-screen)
   - [eb05msd - Customer Update Screen](#eb05msd---customer-update-screen)
3. [System Files](#system-files)
   - [CBLSCMP - Compilation JCL](#cblscmp---compilation-jcl)
   - [CICSMAP - Map Assembly](#cicsmap---map-assembly)
   - [struct - Directory Structure](#struct---directory-structure)

---

## COBOL Programs

### ECSTC030 - Customer Create

**Purpose**: Creates new customer records in the KSDS file

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ECSTC030.
```
- **Lines 1-2**: Program identification section
- Defines program name as ECSTC030 for CICS system

```cobol
       ENVIRONMENT DIVISION.
```
- **Line 4**: Environment division (no special configuration needed)

```cobol
       DATA DIVISION.
       WORKING-STORAGE SECTION.
```
- **Lines 6-7**: Data division with working storage for variables

```cobol
           COPY DFHBMSCA.
           COPY DFHAID.
           COPY EB01MSD.
```
- **Lines 9-11**: Copy required CICS copybooks
- DFHBMSCA: Basic map communication area
- DFHAID: Attention identifier constants (PF keys, etc.)
- EB01MSD: Map definition for customer create screen

```cobol
       01 WS-CICS-RESPONSE-CODES.
          05 DFHRESP-NORMAL        PIC S9(08) COMP VALUE 0.
          05 DFHRESP-NOTFND        PIC S9(08) COMP VALUE +13.
          05 DFHRESP-LENGERR       PIC S9(08) COMP VALUE +16.
          05 DFHRESP-IOERR         PIC S9(08) COMP VALUE +18.
          05 DFHRESP-NOTOPEN       PIC S9(08) COMP VALUE +19.
          05 DFHRESP-ENOTFND       PIC S9(08) COMP VALUE +20.
          05 DFHRESP-ILLLOG        PIC S9(08) COMP VALUE +28.
          05 DFHRESP-TERMERR       PIC S9(08) COMP VALUE +32.
          05 DFHRESP-DUPKEY        PIC S9(08) COMP VALUE +33.
          05 DFHRESP-DUPREC        PIC S9(08) COMP VALUE +34.
```
- **Lines 13-24**: CICS response code definitions
- Defines all possible response codes for error handling
- Each has specific numeric values for CICS system responses

```cobol
       01 WS-COMMAREA.
          05 WS-STAGE            PIC X VALUE '1'.  *> '1'=MAP1, '2'=MAP2
```
- **Lines 26-27**: Communication area for program state
- WS-STAGE tracks which map/screen is currently active

```cobol
       77 WS-RESP-CODE           PIC S9(08) COMP.
       77 WS-RESP-DISPLAY-CODE  PIC 9(08) DISPLAY.
       01 WS-MSG                 PIC X(40).
       01 WS-CUST-ID             PIC X(12).
```
- **Lines 29-33**: Working storage variables
- WS-RESP-CODE: Stores CICS command response
- WS-RESP-DISPLAY-CODE: For displaying response codes
- WS-MSG: General message field
- WS-CUST-ID: Customer ID storage

```cobol
       01 WS-WORK-AREA.
          05 CUST-ID               PIC X(12).
          05 FIRST-NAME            PIC X(10).
          05 LAST-NAME             PIC X(10).
          05 AREA-CODE             PIC X(6).
          05 OUT-SPACE             PIC X.
          05 ADDRESS-1         PIC X(29).
          05 CITY                  PIC X(10).
          05 UNITS                 PIC X(5).
```
- **Lines 35-43**: Customer record structure (83 bytes total)
- Matches KSDS file record layout exactly
- Each field sized according to business requirements

```cobol
       LINKAGE SECTION.
       01 DFHCOMMAREA.
          05 LK-COMM             PIC X.
```
- **Lines 45-48**: Linkage section for CICS communication
- DFHCOMMAREA: Standard CICS communication area

```cobol
       PROCEDURE DIVISION.
       1000-MAIN-LOGIC.
```
- **Lines 50-52**: Main procedure division entry point

```cobol
           IF EIBCALEN = 0
               MOVE '1' TO WS-STAGE
               PERFORM 2000-SEND-MAP1
           ELSE
               MOVE DFHCOMMAREA(1:1) TO WS-STAGE
               IF WS-STAGE = '1'
                   PERFORM 3000-RECEIVE-MAP1
                   PERFORM 4000-PROCESS-CREATE
               END-IF
           END-IF.
```
- **Lines 54-65**: Main program logic flow
- EIBCALEN = 0: First time invocation, send initial map
- EIBCALEN > 0: Return from user input, process data
- Two-stage process: Input → Create

```cobol
       2000-SEND-MAP1.
           MOVE LOW-VALUES TO EB01MAPO
           MOVE -1 TO CIDL
           EXEC CICS SEND MAP('EB01MAP')
                MAPSET('EB01MSD')
                FROM(EB01MAPO)
                RESP(WS-RESP-CODE)
                ERASE CURSOR
           END-EXEC
```
- **Lines 67-77**: Send initial map to user
- LOW-VALUES: Clear all map fields
- -1 to CIDL: Position cursor on Customer ID field
- SEND MAP: Display the input screen

```cobol
           MOVE '1' TO WS-STAGE
           EXEC CICS RETURN
                TRANSID('EB01')
                COMMAREA(WS-COMMAREA)
                LENGTH(1)
           END-EXEC.
```
- **Lines 79-84**: Return control to CICS
- TRANSID('EB01'): Transaction identifier
- COMMAREA: Pass state information to next invocation

```cobol
       3000-RECEIVE-MAP1.
           EXEC CICS RECEIVE MAP('EB01MAP')
                MAPSET('EB01MSD')
                INTO(EB01MAPI)
                RESP(WS-RESP-CODE)
           END-EXEC
           EVALUATE WS-RESP-CODE
               WHEN DFHRESP-NORMAL
                   CONTINUE
               WHEN OTHER
                   MOVE 'RECEIVE MAP ERROR' TO MSGTXTO
                   PERFORM 2000-SEND-MAP1
           END-EVALUATE.
```
- **Lines 86-98**: Receive user input from map
- RECEIVE MAP: Get data from user screen
- Error handling for map receive failures

```cobol
           MOVE CIDI TO WS-CUST-ID
           IF WS-CUST-ID = SPACES
               MOVE 'ENTER CUSTOMER ID' TO MSGTXTO
               PERFORM 2000-SEND-MAP1
           END-IF.
```
- **Lines 100-104**: Validate customer ID input
- Require customer ID to proceed
- Display error message if missing

```cobol
       4000-PROCESS-CREATE.
           MOVE CIDI TO CUST-ID
           MOVE FN-I TO FIRST-NAME
           MOVE LN-I TO LAST-NAME
           MOVE AREA-I TO AREA-CODE
           MOVE ADDR-I TO ADDRESS-1
           MOVE CITY-I TO CITY
           MOVE UNITS-I TO UNITS
           PERFORM 5000-WRITE-VSAM.
```
- **Lines 106-115**: Move map data to work area
- Transfer all user input to record structure
- Call VSAM write routine

```cobol
       5000-WRITE-VSAM.
           EXEC CICS WRITE
                DATASET('CU01KSDS')
                FROM(WS-WORK-AREA)
                RIDFLD(CUST-ID)
                RESP(WS-RESP-CODE)
           END-EXEC
           EVALUATE WS-RESP-CODE
               WHEN DFHRESP-NORMAL
                   MOVE 'CUSTOMER CREATED SUCCESSFULLY' TO MSGTXTO
               WHEN DFHRESP-DUPREC
                   MOVE 'CUSTOMER ALREADY EXISTS' TO MSGTXTO
               WHEN DFHRESP-IOERR
                   MOVE 'I/O ERROR - TRY AGAIN' TO MSGTXTO
               WHEN OTHER
                   MOVE 'ERROR CREATING CUSTOMER' TO MSGTXTO
           END-EVALUATE
           PERFORM 2000-SEND-MAP1.
```
- **Lines 117-131**: Write record to KSDS file
- DATASET('CU01KSDS'): Target VSAM file
- RIDFLD(CUST-ID): Key field for the record
- Comprehensive error handling for write operations

```cobol
       9000-TERMINATE.
           MOVE 'PRESS CTRL + BREAK TO EXIT' TO WS-MSG.
           EXEC CICS SEND TEXT
                           FROM(WS-MSG)
                           LENGTH(LENGTH OF WS-MSG)
                           RESP(WS-RESP-CODE)
                           ERASE
           END-EXEC.
           EXEC CICS RETURN END-EXEC.
```
- **Lines 133-141**: Program termination
- Send exit message to user
- Return to CICS for next transaction

---

### ECSTR040 - Customer Read

**Purpose**: Reads and displays existing customer records from KSDS file

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ECSTR040.
```
- **Lines 1-2**: Program identification

```cobol
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY DFHBMSCA.
           COPY DFHAID.
           COPY EB04MSD.
```
- **Lines 4-8**: Data division with copybooks
- EB04MSD: Map definition for customer read screen

```cobol
       01 WS-CICS-RESPONSE-CODES.
          05 DFHRESP-NORMAL        PIC S9(08) COMP VALUE 0.
          05 DFHRESP-NOTFND        PIC S9(08) COMP VALUE +13.
          05 DFHRESP-LENGERR       PIC S9(08) COMP VALUE +16.
          05 DFHRESP-IOERR         PIC S9(08) COMP VALUE +18.
          05 DFHRESP-NOTOPEN       PIC S9(08) COMP VALUE +19.
          05 DFHRESP-ENOTFND       PIC S9(08) COMP VALUE +20.
          05 DFHRESP-ILLLOG        PIC S9(08) COMP VALUE +28.
          05 DFHRESP-TERMERR       PIC S9(08) COMP VALUE +32.
          05 DFHRESP-DUPKEY        PIC S9(08) COMP VALUE +33.
          05 DFHRESP-DUPREC        PIC S9(08) COMP VALUE +34.
```
- **Lines 10-21**: CICS response code definitions

```cobol
       01 WS-COMMAREA.
          05 WS-STAGE            PIC X VALUE '1'.
       01 WS-RESP-CODE           PIC S9(08) COMP.
       01 WS-RESP-DISPLAY-CODE  PIC 9(08) DISPLAY.
       01 WS-MSG                 PIC X(40).
       01 WS-CUST-ID             PIC X(12).
```
- **Lines 23-29**: Working storage variables

```cobol
       01 WS-CUST-REC.
          05 CUST-ID             PIC X(12).
          05 FIRST-NAME          PIC X(10).
          05 LAST-NAME           PIC X(10).
          05 AREA-CODE           PIC X(6).
          05 OUT-SPACE           PIC X.
          05 ADDRESS             PIC X(29).
          05 CITY                PIC X(10).
          05 UNITS               PIC X(5).
```
- **Lines 31-39**: Customer record structure (83 bytes)

```cobol
       PROCEDURE DIVISION.
       1000-MAIN-LOGIC.
           IF EIBCALEN = 0
               PERFORM 2000-SEND-MAP
           ELSE
               PERFORM 3000-RECEIVE-MAP
               PERFORM 4000-READ-VSAM
           END-IF.
```
- **Lines 41-50**: Main program logic
- Single-stage process: Input → Read → Display

```cobol
       2000-SEND-MAP.
           MOVE LOW-VALUES TO EB04MAPO
           MOVE -1 TO CIDL
           EXEC CICS SEND MAP('EB04MAP')
                MAPSET('EB04MSD')
                FROM(EB04MAPO)
                RESP(WS-RESP-CODE)
                ERASE CURSOR
           END-EXEC
           EXEC CICS RETURN
                TRANSID('EB04')
                COMMAREA(WS-COMMAREA)
                LENGTH(1)
           END-EXEC.
```
- **Lines 52-67**: Send input map to user

```cobol
       3000-RECEIVE-MAP.
           EXEC CICS RECEIVE MAP('EB04MAP')
                MAPSET('EB04MSD')
                INTO(EB04MAPI)
                RESP(WS-RESP-CODE)
           END-EXEC
           EVALUATE WS-RESP-CODE
               WHEN DFHRESP-NORMAL
                   CONTINUE
               WHEN OTHER
                   MOVE 'RECEIVE MAP ERROR' TO MSGTXT
                   PERFORM 2000-SEND-MAP
           END-EVALUATE.
           MOVE CIDI TO WS-CUST-ID.
```
- **Lines 69-84**: Receive and validate customer ID

```cobol
       4000-READ-VSAM.
           EXEC CICS READ
                DATASET('CU01KSDS')
                RIDFLD(WS-CUST-ID)
                INTO(WS-CUST-REC)
                RESP(WS-RESP-CODE)
           END-EXEC
           EVALUATE WS-RESP-CODE
               WHEN DFHRESP-NORMAL
                   PERFORM 5000-DISPLAY-DATA
               WHEN DFHRESP-NOTFND
                   MOVE 'CUSTOMER NOT FOUND' TO MSGTXT
                   PERFORM 2000-SEND-MAP
               WHEN DFHRESP-LENGERR
                   MOVE 'RECORD LENGTH ERROR' TO MSGTXT
                   PERFORM 2000-SEND-MAP
               WHEN DFHRESP-IOERR
                   MOVE 'I/O ERROR - TRY AGAIN' TO MSGTXT
                   PERFORM 2000-SEND-MAP
               WHEN DFHRESP-NOTOPEN
                   MOVE 'DATASET NOT OPEN' TO MSGTXT
                   PERFORM 2000-SEND-MAP
               WHEN OTHER
                   MOVE 'ERROR READING RECORD' TO MSGTXT
                   PERFORM 2000-SEND-MAP
           END-EVALUATE.
```
- **Lines 86-108**: Read customer record with comprehensive error handling

```cobol
       5000-DISPLAY-DATA.
           MOVE FIRST-NAME TO FN
           MOVE LAST-NAME  TO LN
           MOVE AREA-CODE  TO AREA
           MOVE ADDRESS    TO ADDR
           MOVE CITY       TO CITY
           MOVE UNITS      TO UNIT
           PERFORM 2000-SEND-MAP.
```
- **Lines 110-117**: Display customer data on map

```cobol
       9000-TERMINATE.
           MOVE 'PRESS CTRL + BREAK TO EXIT' TO WS-MSG.
           EXEC CICS SEND TEXT
                           FROM(WS-MSG)
                           RESP(WS-RESP-CODE)
                           ERASE
           END-EXEC.
           EXEC CICS RETURN END-EXEC.
```
- **Lines 119-126**: Program termination

---

### ECSTU050 - Customer Update

**Purpose**: Updates existing customer records in KSDS file

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ECSTU050.
```
- **Lines 1-2**: Program identification

```cobol
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY DFHBMSCA.
           COPY DFHAID.
           COPY EB05MSD.
```
- **Lines 4-8**: Data division with copybooks
- EB05MSD: Single map definition for update screen

```cobol
       01 WS-CICS-RESPONSE-CODES.
          05 DFHRESP-NORMAL        PIC S9(08) COMP VALUE 0.
          05 DFHRESP-NOTFND        PIC S9(08) COMP VALUE +13.
          05 DFHRESP-LENGERR       PIC S9(08) COMP VALUE +16.
          05 DFHRESP-IOERR         PIC S9(08) COMP VALUE +18.
          05 DFHRESP-NOTOPEN       PIC S9(08) COMP VALUE +19.
          05 DFHRESP-ENOTFND       PIC S9(08) COMP VALUE +20.
          05 DFHRESP-ILLLOG        PIC S9(08) COMP VALUE +28.
          05 DFHRESP-TERMERR       PIC S9(08) COMP VALUE +32.
          05 DFHRESP-DUPKEY        PIC S9(08) COMP VALUE +33.
          05 DFHRESP-DUPREC        PIC S9(08) COMP VALUE +34.
```
- **Lines 10-21**: CICS response code definitions

```cobol
       01 WS-COMMAREA.
          05 WS-STAGE            PIC X VALUE '1'.
       01 WS-RESP-CODE           PIC S9(08) COMP.
       01 WS-RESP-DISPLAY-CODE  PIC 9(08) DISPLAY.
       01 WS-MSG                 PIC X(40).
```
- **Lines 23-29**: Working storage variables

```cobol
       01 WS-CUST-ID             PIC X(12).
       01 WS-CUST-REC.
          05 CUST-ID             PIC X(12).
          05 FIRST-NAME          PIC X(15).
          05 LAST-NAME           PIC X(15).
          05 AREA-CODE           PIC X(10).
          05 ADDRESS             PIC X(30).
          05 CITY                PIC X(15).
          05 UNITS               PIC 9(05).
```
- **Lines 31-41**: Customer record structure with updated field sizes

```cobol
       01 WS-NEW-DATA.
          05 WS-NFN              PIC X(15).
          05 WS-NLN              PIC X(15).
          05 WS-NAR              PIC X(10).
          05 WS-NAD              PIC X(20).
          05 WS-NCT              PIC X(15).
```
- **Lines 43-48**: Storage for new data values

```cobol
       PROCEDURE DIVISION.
       1000-MAIN-LOGIC.
           IF EIBCALEN = 0
               MOVE '1' TO WS-STAGE
               PERFORM 2000-SEND-MAP
           ELSE
               MOVE DFHCOMMAREA(1:1) TO WS-STAGE
               IF WS-STAGE = '1'
                   PERFORM 3000-RECEIVE-MAP
                   PERFORM 4000-READ-VSAM
               ELSE
                   PERFORM 3100-RECEIVE-MAP
                   PERFORM 5000-PROCESS-UPDATE
               END-IF
           END-IF.
```
- **Lines 50-66**: Three-stage process: Customer ID → Read → Update

```cobol
       2000-SEND-MAP.
           MOVE LOW-VALUES TO EB05MAPO
           MOVE -1 TO CIDL
           EXEC CICS SEND MAP('EB05MAP')
                MAPSET('EB05MSD')
                FROM(EB05MAPO)
                RESP(WS-RESP-CODE)
                ERASE CURSOR
           END-EXEC
           MOVE '1' TO WS-STAGE
           EXEC CICS RETURN
                TRANSID('EB05')
                COMMAREA(WS-COMMAREA)
                LENGTH(1)
           END-EXEC.
```
- **Lines 68-84**: Send initial customer ID input screen

```cobol
       2100-SEND-MAP.
           MOVE LOW-VALUES TO EB05MAPO
           MOVE FIRST-NAME TO FN-OLD
           MOVE LAST-NAME  TO LN-OLD
           MOVE AREA-CODE  TO AREA-OLD
           MOVE ADDRESS    TO ADDR-OLD
           MOVE CITY       TO CITY-OLD
           MOVE UNITS      TO UNIT-OLD
           MOVE -1 TO FN-NEWL
           EXEC CICS SEND MAP('EB05MAP')
                MAPSET('EB05MSD')
                FROM(EB05MAPO)
                RESP(WS-RESP-CODE)
                ERASE CURSOR
           END-EXEC
           EVALUATE WS-RESP-CODE
               WHEN DFHRESP-NORMAL
                   CONTINUE
               WHEN OTHER
                   MOVE 'SEND MAP ERROR' TO MSGTXT
           END-EVALUATE.
           MOVE '2' TO WS-STAGE
           EXEC CICS RETURN
                TRANSID('EB05')
                COMMAREA(WS-COMMAREA)
                LENGTH(1)
           END-EXEC.
```
- **Lines 86-109**: Send update screen with existing data displayed

```cobol
       3000-RECEIVE-MAP.
           EXEC CICS RECEIVE MAP('EB05MAP')
                MAPSET('EB05MSD')
                INTO(EB05MAPI)
                RESP(WS-RESP-CODE)
           END-EXEC
           EVALUATE WS-RESP-CODE
               WHEN DFHRESP-NORMAL
                   CONTINUE
               WHEN OTHER
                   MOVE 'RECEIVE MAP ERROR' TO MSGTXT
                   PERFORM 2000-SEND-MAP
           END-EVALUATE.
           MOVE CIDI TO WS-CUST-ID
           IF WS-CUST-ID = SPACES
               MOVE 'ENTER CUSTOMER ID' TO MSGTXT
               PERFORM 2000-SEND-MAP
           END-IF.
```
- **Lines 111-126**: Receive customer ID for lookup

```cobol
       3100-RECEIVE-MAP.
           EXEC CICS RECEIVE MAP('EB05MAP')
                MAPSET('EB05MSD')
                INTO(EB05MAPI)
                RESP(WS-RESP-CODE)
           END-EXEC
           EVALUATE WS-RESP-CODE
               WHEN DFHRESP-NORMAL
                   CONTINUE
               WHEN OTHER
                   MOVE 'RECEIVE MAP ERROR' TO MSGTXT
           END-EVALUATE.
           MOVE FN-NEWI TO WS-NFN
           MOVE LN-NEWI TO WS-NLN
           MOVE AREA-NEWI TO WS-NAR
           MOVE ADDR-NEWI TO WS-NAD
           MOVE CITY-NEWI TO WS-NCT.
```
- **Lines 128-142**: Receive updated field values

```cobol
       4000-READ-VSAM.
           EXEC CICS READ
                DATASET('CU01KSDS')
                RIDFLD(WS-CUST-ID)
                INTO(WS-CUST-REC)
                RESP(WS-RESP-CODE)
           END-EXEC
           EVALUATE WS-RESP-CODE
               WHEN DFHRESP-NORMAL
                   PERFORM 2100-SEND-MAP
               WHEN DFHRESP-NOTFND
                   MOVE 'CUSTOMER NOT FOUND' TO MSGTXT
                   PERFORM 2000-SEND-MAP
               WHEN DFHRESP-LENGERR
                   MOVE 'RECORD LENGTH ERROR' TO MSGTXT
                   PERFORM 2000-SEND-MAP
               WHEN DFHRESP-IOERR
                   MOVE 'I/O ERROR - TRY AGAIN' TO MSGTXT
                   PERFORM 2000-SEND-MAP
               WHEN DFHRESP-NOTOPEN
                   MOVE 'DATASET NOT OPEN' TO MSGTXT
                   PERFORM 2000-SEND-MAP
               WHEN OTHER
                   MOVE 'ERROR READING RECORD' TO MSGTXT
                   PERFORM 2000-SEND-MAP
           END-EVALUATE.
```
- **Lines 144-166**: Read existing customer record

```cobol
       5000-PROCESS-UPDATE.
           IF WS-NFN NOT = SPACES
               MOVE WS-NFN TO FIRST-NAME
           END-IF
           IF WS-NLN NOT = SPACES
               MOVE WS-NLN TO LAST-NAME
           END-IF
           IF WS-NAR NOT = SPACES
               MOVE WS-NAR TO AREA-CODE
           END-IF
           IF WS-NAD NOT = SPACES
               MOVE WS-NAD TO ADDRESS
           END-IF
           IF WS-NCT NOT = SPACES
               MOVE WS-NCT TO CITY
           END-IF
           PERFORM 6000-REWRITE-VSAM.
```
- **Lines 168-186**: Update only non-empty fields

```cobol
       6000-REWRITE-VSAM.
           EXEC CICS REWRITE
                DATASET('CU01KSDS')
                FROM(WS-CUST-REC)
                RESP(WS-RESP-CODE)
           END-EXEC
           EVALUATE WS-RESP-CODE
               WHEN DFHRESP-NORMAL
                   MOVE 'RECORD UPDATED SUCCESSFULLY' TO MSGTXT
               WHEN DFHRESP-NOTFND
                   MOVE 'RECORD NOT FOUND FOR UPDATE' TO MSGTXT
               WHEN DFHRESP-LENGERR
                   MOVE 'RECORD LENGTH ERROR' TO MSGTXT
               WHEN DFHRESP-IOERR
                   MOVE 'I/O ERROR - TRY AGAIN' TO MSGTXT
               WHEN DFHRESP-DUPKEY
                   MOVE 'DUPLICATE KEY ERROR' TO MSGTXT
               WHEN DFHRESP-DUPREC
                   MOVE 'DUPLICATE RECORD ERROR' TO MSGTXT
               WHEN OTHER
                   MOVE 'ERROR UPDATING RECORD' TO MSGTXT
           END-EVALUATE
           PERFORM 2100-SEND-MAP.
```
- **Lines 188-208**: Rewrite updated record to KSDS

```cobol
       9000-TERMINATE.
           MOVE 'PRESS CTRL + BREAK TO EXIT' TO WS-MSG.
           EXEC CICS SEND TEXT
                           FROM(WS-MSG)
                           LENGTH(LENGTH OF WS-MSG)
                           RESP(WS-RESP-CODE)
                           ERASE
           END-EXEC.
           EXEC CICS RETURN END-EXEC.
```
- **Lines 210-218**: Program termination

---

### EMNUO010 - Main Menu

**Purpose**: Main menu system for customer application

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMNUO010.
```
- **Lines 1-2**: Program identification

```cobol
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY DFHBMSCA.
           COPY DFHAID.
       01 WS-OPTIONS.
          05 WS-OPT-1            PIC X(40) VALUE '1 - CREATE CUSTOMER'.
          05 WS-OPT-2            PIC X(40) VALUE '2 - READ CUSTOMER'.
          05 WS-OPT-3            PIC X(40) VALUE '3 - UPDATE CUSTOMER'.
          05 WS-OPT-4            PIC X(40) VALUE '4 - EXIT'.
```
- **Lines 4-12**: Menu options display

```cobol
       01 WS-RESP-CODE           PIC S9(08) COMP.
       01 WS-MSG                 PIC X(40).
```
- **Lines 14-15**: Working storage variables

```cobol
       PROCEDURE DIVISION.
       1000-MAIN-LOGIC.
           IF EIBCALEN = 0
               PERFORM 2000-DISPLAY-MENU
           ELSE
               PERFORM 3000-PROCESS-OPTION
           END-IF.
```
- **Lines 17-23**: Main menu logic

```cobol
       2000-DISPLAY-MENU.
           MOVE LOW-VALUES TO DFHCOMMAREA
           MOVE WS-OPT-1 TO DFHCOMMAREA(1:40)
           MOVE WS-OPT-2 TO DFHCOMMAREA(41:40)
           MOVE WS-OPT-3 TO DFHCOMMAREA(81:40)
           MOVE WS-OPT-4 TO DFHCOMMAREA(121:40)
           EXEC CICS SEND TEXT
                           FROM(DFHCOMMAREA)
                           LENGTH(160)
                           RESP(WS-RESP-CODE)
           END-EXEC
           EXEC CICS RETURN
                TRANSID('EMNU')
                COMMAREA('1')
                LENGTH(1)
           END-EXEC.
```
- **Lines 25-40**: Display menu options

```cobol
       3000-PROCESS-OPTION.
           MOVE DFHCOMMAREA(1:1) TO WS-OPTION
           EVALUATE WS-OPTION
               WHEN '1'
                   EXEC CICS RETURN
                        TRANSID('EB01')
                   END-EXEC
               WHEN '2'
                   EXEC CICS RETURN
                        TRANSID('EB04')
                   END-EXEC
               WHEN '3'
                   EXEC CICS RETURN
                        TRANSID('EB05')
                   END-EXEC
               WHEN '4'
                   PERFORM 9000-TERMINATE
               WHEN OTHER
                   MOVE 'INVALID OPTION - TRY AGAIN' TO WS-MSG
                   PERFORM 2000-DISPLAY-MENU
           END-EVALUATE.
```
- **Lines 42-60**: Process menu selection

```cobol
       9000-TERMINATE.
           MOVE 'SESSION TERMINATED' TO WS-MSG.
           EXEC CICS SEND TEXT
                           FROM(WS-MSG)
                           RESP(WS-RESP-CODE)
           END-EXEC.
           EXEC CICS RETURN END-EXEC.
```
- **Lines 62-68**: Program termination

---

### EMNUO020 - Sub Menu

**Purpose**: Sub menu for additional options

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMNUO020.
```
- **Lines 1-2**: Program identification

```cobol
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY DFHBMSCA.
           COPY DFHAID.
       01 WS-OPTIONS.
          05 WS-OPT-1            PIC X(40) VALUE '1 - REPORTS'.
          05 WS-OPT-2            PIC X(40) VALUE '2 - UTILITIES'.
          05 WS-OPT-3            PIC X(40) VALUE '3 - RETURN TO MAIN MENU'.
```
- **Lines 4-11**: Sub menu options

```cobol
       01 WS-RESP-CODE           PIC S9(08) COMP.
       01 WS-OPTION              PIC X.
       01 WS-MSG                 PIC X(40).
```
- **Lines 13-16**: Working storage variables

```cobol
       PROCEDURE DIVISION.
       1000-MAIN-LOGIC.
           IF EIBCALEN = 0
               PERFORM 2000-DISPLAY-MENU
           ELSE
               PERFORM 3000-PROCESS-OPTION
           END-IF.
```
- **Lines 18-24**: Main logic flow

```cobol
       2000-DISPLAY-MENU.
           MOVE LOW-VALUES TO DFHCOMMAREA
           MOVE WS-OPT-1 TO DFHCOMMAREA(1:40)
           MOVE WS-OPT-2 TO DFHCOMMAREA(41:40)
           MOVE WS-OPT-3 TO DFHCOMMAREA(81:40)
           EXEC CICS SEND TEXT
                           FROM(DFHCOMMAREA)
                           LENGTH(120)
                           RESP(WS-RESP-CODE)
           END-EXEC
           EXEC CICS RETURN
                TRANSID('EMNU2')
                COMMAREA('1')
                LENGTH(1)
           END-EXEC.
```
- **Lines 26-40**: Display sub menu

```cobol
       3000-PROCESS-OPTION.
           MOVE DFHCOMMAREA(1:1) TO WS-OPTION
           EVALUATE WS-OPTION
               WHEN '1'
                   MOVE 'REPORTS UNDER DEVELOPMENT' TO WS-MSG
                   PERFORM 2000-DISPLAY-MENU
               WHEN '2'
                   MOVE 'UTILITIES UNDER DEVELOPMENT' TO WS-MSG
                   PERFORM 2000-DISPLAY-MENU
               WHEN '3'
                   EXEC CICS RETURN
                        TRANSID('EMNU')
                   END-EXEC
               WHEN OTHER
                   MOVE 'INVALID OPTION - TRY AGAIN' TO WS-MSG
                   PERFORM 2000-DISPLAY-MENU
           END-EVALUATE.
```
- **Lines 42-58**: Process sub menu selection

```cobol
       9000-TERMINATE.
           MOVE 'RETURNING TO MAIN MENU' TO WS-MSG.
           EXEC CICS SEND TEXT
                           FROM(WS-MSG)
                           RESP(WS-RESP-CODE)
           END-EXEC.
           EXEC CICS RETURN END-EXEC.
```
- **Lines 60-66**: Program termination

---

## Map Definitions

### eb01msd - Customer Create Map

**Purpose**: BMS map definition for customer creation screen

```cobol
EB01MSD DFHMSD TYPE=&SYSPARM,MODE=INOUT,LANG=COBOL,                   X
               STORAGE=AUTO,CTRL=(FREEKB,FRSET),TIOAPFX=YES
```
- **Lines 1-2**: Map set definition
- TYPE=&SYSPARM: System parameter mode
- MODE=INOUT: Input and output capability
- LANG=COBOL: COBOL language interface
- STORAGE=AUTO: Automatic storage management
- CTRL=(FREEKB,FRSET): Free keyboard, field reset
- TIOAPFX=YES: Terminal I/O area prefix

```cobol
EB01MAP DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
```
- **Line 4**: Map definition
- SIZE=(24,80): 24 lines, 80 columns screen size
- LINE=1,COLUMN=1: Starting position

```cobol
*----------------------------------------------------------------*
* TITLE
*----------------------------------------------------------------*
TITLE   DFHMDF POS=(2,25),LENGTH=30,ATTRB=(PROT),                      X
               INITIAL='CUSTOMER CREATE SCREEN'
```
- **Lines 6-9**: Screen title
- POS=(2,25): Line 2, column 25
- LENGTH=30: 30 characters long
- ATTRB=(PROT): Protected field (no input)
- INITIAL: Default text

```cobol
*----------------------------------------------------------------*
* INPUT FIELDS
*----------------------------------------------------------------*
CID-L   DFHMDF POS=(5,10),LENGTH=20,ATTRB=(PROT),                      X
               INITIAL='ENTER CUSTOMER ID :'
CID     DFHMDF POS=(5,35),LENGTH=12,ATTRB=(UNPROT,FSET)
```
- **Lines 11-14**: Customer ID field
- CID-L: Label (protected)
- CID: Input field (unprotected, field set)

```cobol
FN-L    DFHMDF POS=(7,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='FIRST NAME  :'
FN      DFHMDF POS=(7,30),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 16-19**: First name field

```cobol
LN-L    DFHMDF POS=(8,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='LAST NAME   :'
LN      DFHMDF POS=(8,30),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 21-24**: Last name field

```cobol
AREA-L  DFHMDF POS=(9,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='AREA CODE   :'
AREA    DFHMDF POS=(9,30),LENGTH=10,ATTRB=(UNPROT,FSET)
```
- **Lines 26-29**: Area code field

```cobol
ADDR-L  DFHMDF POS=(10,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='ADDRESS     :'
ADDR    DFHMDF POS=(10,30),LENGTH=30,ATTRB=(UNPROT,FSET)
```
- **Lines 31-34**: Address field

```cobol
CITY-L  DFHMDF POS=(11,10),LENGTH=15,ATTRB=(PROT),                     X
                INITIAL='CITY        :'
CITY    DFHMDF POS=(11,30),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 36-39**: City field

```cobol
UNIT-L  DFHMDF POS=(12,10),LENGTH=15,ATTRB=(PROT),                     X
                INITIAL='UNITS       :'
UNIT    DFHMDF POS=(12,30),LENGTH=6,ATTRB=(UNPROT,FSET)
```
- **Lines 41-44**: Units field

```cobol
*----------------------------------------------------------------*
* MESSAGE FIELD
*----------------------------------------------------------------*
MSG-L   DFHMDF POS=(15,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='MESSAGE     :'
MSGTXT  DFHMDF POS=(15,30),LENGTH=45,ATTRB=(PROT)
```
- **Lines 46-49**: Message display field

```cobol
        DFHMDF POS=(18,10),LENGTH=25,ATTRB=(PROT),                     X
               INITIAL='PF3->EXIT | PF6->CLR SCR '
        DFHMSD TYPE=FINAL
       END
```
- **Lines 51-54**: Function key instructions and map end

---

### eb02msd - Customer Read Map

**Purpose**: BMS map definition for customer read screen

```cobol
EB02MSD DFHMSD TYPE=&SYSPARM,MODE=INOUT,LANG=COBOL,                   X
               STORAGE=AUTO,CTRL=(FREEKB,FRSET),TIOAPFX=YES

EB02MAP DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
```
- **Lines 1-4**: Map set and map definition

```cobol
*----------------------------------------------------------------*
* TITLE
*----------------------------------------------------------------*
TITLE   DFHMDF POS=(2,25),LENGTH=30,ATTRB=(PROT),                      X
               INITIAL='CUSTOMER READ SCREEN'
```
- **Lines 6-9**: Screen title

```cobol
*----------------------------------------------------------------*
* INPUT FIELD
*----------------------------------------------------------------*
CID-L   DFHMDF POS=(5,10),LENGTH=20,ATTRB=(PROT),                      X
               INITIAL='ENTER CUSTOMER ID :'
CID     DFHMDF POS=(5,35),LENGTH=12,ATTRB=(UNPROT,FSET)
```
- **Lines 11-14**: Customer ID input field

```cobol
*----------------------------------------------------------------*
* OUTPUT FIELDS
*----------------------------------------------------------------*
FN-L    DFHMDF POS=(7,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='FIRST NAME  :'
FN      DFHMDF POS=(7,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 16-19**: First name display (protected)

```cobol
LN-L    DFHMDF POS=(8,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='LAST NAME   :'
LN      DFHMDF POS=(8,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 21-24**: Last name display

```cobol
AREA-L  DFHMDF POS=(9,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='AREA CODE   :'
AREA    DFHMDF POS=(9,30),LENGTH=10,ATTRB=(PROT)
```
- **Lines 26-29**: Area code display

```cobol
ADDR-L  DFHMDF POS=(10,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='ADDRESS     :'
ADDR    DFHMDF POS=(10,30),LENGTH=30,ATTRB=(PROT)
```
- **Lines 31-34**: Address display

```cobol
CITY-L  DFHMDF POS=(11,10),LENGTH=15,ATTRB=(PROT),                     X
                INITIAL='CITY        :'
CITY    DFHMDF POS=(11,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 36-39**: City display

```cobol
UNIT-L  DFHMDF POS=(12,10),LENGTH=15,ATTRB=(PROT),                     X
                INITIAL='UNITS       :'
UNIT    DFHMDF POS=(12,30),LENGTH=6,ATTRB=(PROT)
```
- **Lines 41-44**: Units display

```cobol
*----------------------------------------------------------------*
* MESSAGE FIELD
*----------------------------------------------------------------*
MSG-L   DFHMDF POS=(15,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='MESSAGE     :'
MSGTXT  DFHMDF POS=(15,30),LENGTH=45,ATTRB=(PROT)
```
- **Lines 46-49**: Message field

```cobol
        DFHMDF POS=(18,10),LENGTH=25,ATTRB=(PROT),                     X
               INITIAL='PF3->EXIT | PF6->CLR SCR '
        DFHMSD TYPE=FINAL
       END
```
- **Lines 51-54**: Function keys and map end

---

### eb03msd - Customer Update Map (Old Dual Map Version)

**Purpose**: Original dual-map definition for customer update

```cobol
EB03MSD DFHMSD TYPE=&SYSPARM,MODE=INOUT,LANG=COBOL,                   X
               STORAGE=AUTO,CTRL=(FREEKB,FRSET),TIOAPFX=YES
```
- **Lines 1-2**: Map set definition

```cobol
*----------------------------------------------------------------*
* MAP1 : CUSTOMER ID INPUT
*----------------------------------------------------------------*
EB03MAP1 DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
```
- **Lines 4-6**: First map for customer ID input

```cobol
TITLE1   DFHMDF POS=(2,25),LENGTH=25,ATTRB=(PROT),              X
                     INITIAL='CUSTOMER UPDATE'

CID-L    DFHMDF POS=(6,10),LENGTH=20,ATTRB=(PROT),              X
                     INITIAL='ENTER CUSTOMER ID :'
CID      DFHMDF POS=(6,35),LENGTH=12,ATTRB=(UNPROT,FSET)        X

MSG1-L   DFHMDF POS=(10,10),LENGTH=10,ATTRB=(PROT),                    X
               INITIAL='MESSAGE:'
MSG1     DFHMDF POS=(10,25),LENGTH=45,ATTRB=(PROT)
```
- **Lines 8-17**: Customer ID input screen fields

```cobol
*----------------------------------------------------------------*
* MAP2 : UPDATE SCREEN
*----------------------------------------------------------------*
EB03MAP2 DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
```
- **Lines 19-21**: Second map for update screen

```cobol
TITLE2   DFHMDF POS=(2,20),LENGTH=35,ATTRB=(PROT),                     X
               INITIAL='CUSTOMER UPDATE SCREEN'

HDR1     DFHMDF POS=(4,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='FIELD'
HDR2     DFHMDF POS=(4,30),LENGTH=20,ATTRB=(PROT),                     X
               INITIAL='EXISTING VALUE'
HDR3     DFHMDF POS=(4,55),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='NEW VALUE'
```
- **Lines 23-31**: Update screen headers

```cobol
*----------------------------------------------------------------*
* FIELD DEFINITIONS
*----------------------------------------------------------------*
FN-L     DFHMDF POS=(6,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='FIRST NAME :'
FN-OLD   DFHMDF POS=(6,30),LENGTH=15,ATTRB=(PROT)
FN-NEW   DFHMDF POS=(6,55),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 33-37**: First name fields (old and new)

```cobol
LN-L     DFHMDF POS=(7,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='LAST NAME  :'
LN-OLD   DFHMDF POS=(7,30),LENGTH=15,ATTRB=(PROT)
LN-NEW   DFHMDF POS=(7,55),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 39-43**: Last name fields

```cobol
AR-L     DFHMDF POS=(8,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='AREA CODE  :'
AR-OLD   DFHMDF POS=(8,30),LENGTH=10,ATTRB=(PROT)
AR-NEW   DFHMDF POS=(8,55),LENGTH=10,ATTRB=(UNPROT,FSET)
```
- **Lines 45-49**: Area code fields

```cobol
AD-L     DFHMDF POS=(9,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='ADDRESS    :'
AD-OLD   DFHMDF POS=(9,30),LENGTH=20,ATTRB=(PROT)
AD-NEW   DFHMDF POS=(9,55),LENGTH=20,ATTRB=(UNPROT,FSET)
```
- **Lines 51-55**: Address fields

```cobol
CT-L     DFHMDF POS=(10,10),LENGTH=15,ATTRB=(PROT),                    X
                INITIAL='CITY       :'
CT-OLD   DFHMDF POS=(10,30),LENGTH=15,ATTRB=(PROT)
CT-NEW   DFHMDF POS=(10,55),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 57-61**: City fields

```cobol
UN-L     DFHMDF POS=(11,10),LENGTH=15,ATTRB=(PROT),                    X
                INITIAL='UNITS      :'
UN-OLD   DFHMDF POS=(11,30),LENGTH=6,ATTRB=(PROT)
```
- **Lines 63-66**: Units field (existing only)

```cobol
MSG2-L   DFHMDF POS=(14,10),LENGTH=10,ATTRB=(PROT),                    X
               INITIAL='MESSAGE:'
MSG2     DFHMDF POS=(14,25),LENGTH=45,ATTRB=(PROT)
        DFHMDF POS=(18,10),LENGTH=25,ATTRB=(PROT),                     X
               INITIAL='PF3->EXIT | PF6->CLR SCR '
         DFHMSD TYPE=FINAL
       END
```
- **Lines 68-73**: Message field and map end

---

### eb04msd - Customer Read Screen

**Purpose**: Simplified single-map customer read screen

```cobol
EB04MSD DFHMSD TYPE=&SYSPARM,MODE=INOUT,LANG=COBOL,                    X
               STORAGE=AUTO,CTRL=(FREEKB,FRSET),TIOAPFX=YES

EB04MAP DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
```
- **Lines 1-4**: Map set and map definition

```cobol
*----------------------------------------------------------------*
* TITLE
*----------------------------------------------------------------*
TITLE   DFHMDF POS=(2,25),LENGTH=30,ATTRB=(PROT),                      X
               INITIAL='CUSTOMER READ SCREEN'
```
- **Lines 6-9**: Screen title

```cobol
*----------------------------------------------------------------*
* INPUT FIELD
*----------------------------------------------------------------*
CID-L   DFHMDF POS=(5,10),LENGTH=20,ATTRB=(PROT),                      X
               INITIAL='ENTER CUSTOMER ID :'
CID     DFHMDF POS=(5,35),LENGTH=12,ATTRB=(UNPROT,FSET)
```
- **Lines 11-14**: Customer ID input

```cobol
*----------------------------------------------------------------*
* OUTPUT FIELDS
*----------------------------------------------------------------*
FN-L    DFHMDF POS=(7,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='FIRST NAME  :'
FN      DFHMDF POS=(7,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 16-19**: First name display

```cobol
LN-L    DFHMDF POS=(8,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='LAST NAME   :'
LN      DFHMDF POS=(8,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 21-24**: Last name display

```cobol
AREA-L  DFHMDF POS=(9,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='AREA CODE   :'
AREA    DFHMDF POS=(9,30),LENGTH=10,ATTRB=(PROT)
```
- **Lines 26-29**: Area code display

```cobol
ADDR-L  DFHMDF POS=(10,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='ADDRESS     :'
ADDR    DFHMDF POS=(10,30),LENGTH=30,ATTRB=(PROT)
```
- **Lines 31-34**: Address display

```cobol
CITY-L  DFHMDF POS=(11,10),LENGTH=15,ATTRB=(PROT),                     X
                INITIAL='CITY        :'
CITY    DFHMDF POS=(11,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 36-39**: City display

```cobol
UNIT-L  DFHMDF POS=(12,10),LENGTH=15,ATTRB=(PROT),                     X
                INITIAL='UNITS       :'
UNIT    DFHMDF POS=(12,30),LENGTH=6,ATTRB=(PROT)
```
- **Lines 41-44**: Units display

```cobol
*----------------------------------------------------------------*
* MESSAGE FIELD
*----------------------------------------------------------------*
MSG-L   DFHMDF POS=(15,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='MESSAGE     :'
MSGTXT  DFHMDF POS=(15,30),LENGTH=45,ATTRB=(PROT)
```
- **Lines 46-49**: Message field

```cobol
        DFHMDF POS=(18,10),LENGTH=25,ATTRB=(PROT),                     X
               INITIAL='PF3->EXIT | PF6->CLR SCR '
        DFHMSD TYPE=FINAL
       END
```
- **Lines 51-54**: Function keys and map end

---

### eb05msd - Customer Update Screen

**Purpose**: Single-map customer update screen (replaces dual-map approach)

```cobol
EB05MSD DFHMSD TYPE=&SYSPARM,MODE=INOUT,LANG=COBOL,                   X
               STORAGE=AUTO,CTRL=(FREEKB,FRSET),TIOAPFX=YES

EB05MAP DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
```
- **Lines 1-4**: Map set and map definition

```cobol
*----------------------------------------------------------------*
* TITLE
*----------------------------------------------------------------*
TITLE   DFHMDF POS=(2,25),LENGTH=30,ATTRB=(PROT),                      X
               INITIAL='CUSTOMER UPDATE SCREEN'
```
- **Lines 6-9**: Screen title

```cobol
*----------------------------------------------------------------*
* INPUT FIELD - CUSTOMER ID
*----------------------------------------------------------------*
CID-L   DFHMDF POS=(5,10),LENGTH=20,ATTRB=(PROT),                      X
               INITIAL='ENTER CUSTOMER ID :'
CID     DFHMDF POS=(5,35),LENGTH=12,ATTRB=(UNPROT,FSET)
```
- **Lines 11-14**: Customer ID input field

```cobol
*----------------------------------------------------------------*
* OUTPUT FIELDS - EXISTING VALUES
*----------------------------------------------------------------*
FN-OLDL DFHMDF POS=(7,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='FIRST NAME  :'
FN-OLD  DFHMDF POS=(7,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 16-19**: First name existing value

```cobol
LN-OLDL DFHMDF POS=(8,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='LAST NAME   :'
LN-OLD  DFHMDF POS=(8,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 21-24**: Last name existing value

```cobol
AREA-OLDL DFHMDF POS=(9,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='AREA CODE   :'
AREA-OLD DFHMDF POS=(9,30),LENGTH=10,ATTRB=(PROT)
```
- **Lines 26-29**: Area code existing value

```cobol
ADDR-OLDL DFHMDF POS=(10,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='ADDRESS     :'
ADDR-OLD DFHMDF POS=(10,30),LENGTH=30,ATTRB=(PROT)
```
- **Lines 31-34**: Address existing value

```cobol
CITY-OLDL DFHMDF POS=(11,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='CITY        :'
CITY-OLD DFHMDF POS=(11,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 36-39**: City existing value

```cobol
UNIT-OLDL DFHMDF POS=(12,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='UNITS       :'
UNIT-OLD DFHMDF POS=(12,30),LENGTH=6,ATTRB=(PROT)
```
- **Lines 41-44**: Units existing value

```cobol
*----------------------------------------------------------------*
* INPUT FIELDS - NEW VALUES
*----------------------------------------------------------------*
FN-NEWL  DFHMDF POS=(7,50),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='NEW VALUE:'
FN-NEW   DFHMDF POS=(7,65),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 46-49**: First name new value input

```cobol
LN-NEWL  DFHMDF POS=(8,50),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='NEW VALUE:'
LN-NEW   DFHMDF POS=(8,65),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 51-54**: Last name new value input

```cobol
AREA-NEWL DFHMDF POS=(9,50),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='NEW VALUE:'
AREA-NEW DFHMDF POS=(9,65),LENGTH=10,ATTRB=(UNPROT,FSET)
```
- **Lines 56-59**: Area code new value input

```cobol
ADDR-NEWL DFHMDF POS=(10,50),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='NEW VALUE:'
ADDR-NEW DFHMDF POS=(10,65),LENGTH=30,ATTRB=(UNPROT,FSET)
```
- **Lines 61-64**: Address new value input

```cobol
CITY-NEWL DFHMDF POS=(11,50),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='NEW VALUE:'
CITY-NEW DFHMDF Pos=(11,65),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 66-69**: City new value input

```cobol
*----------------------------------------------------------------*
* MESSAGE FIELD
*----------------------------------------------------------------*
MSG-L   DFHMDF POS=(15,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='MESSAGE     :'
MSGTXT  DFHMDF POS=(15,30),LENGTH=45,ATTRB=(PROT)
```
- **Lines 71-74**: Message field

```cobol
        DFHMDF POS=(18,10),LENGTH=25,ATTRB=(PROT),                     X
               INITIAL='PF3->EXIT | PF6->CLR SCR '
        DFHMSD TYPE=FINAL
       END
```
- **Lines 76-79**: Function keys and map end

---

## System Files

### CBLSCMP - Compilation JCL

**Purpose**: JCL to compile COBOL CICS programs

```jcl
//OZA266C1 JOB OZA,OZA,MSGLEVEL=(1,1),
//            CLASS=A,MSGCLASS=A,NOTIFY=&SYSUID,REGION=0M
```
- **Lines 1-2**: Job statement
- OZA266C1: Job name
- MSGLEVEL=(1,1): Print all messages
- CLASS=A: Job class
- MSGCLASS=A: Message class
- NOTIFY=&SYSUID: Notify user
- REGION=0M: Unlimited region size

```jcl
//   SET CICSPGM=ECSTC030
//**********************************************************************
//***     SAMPLE JCL TO COMPILE COBOL + CICS PROGRAM                 ***
//***     KEEP USERID IN PLACE OF OZAGSB                             ***
//***     DO NOT CHANGE LOADLIB=OZAADM.CICS.LOADLIB                  ***
//**********************************************************************
```
- **Lines 4-8**: Setup and comments
- SET CICSPGM: Program to compile
- Important notes about load library

```jcl
//JOBPROC  JCLLIB ORDER=OZAGSB.USER.PROCLIB
//CICSCOB  EXEC PRCCCSCB,
//             COPYLIB=OZA266.ELE.CPYBK,
//             LOADLIB=OZAADM.CICS.LOADLIB
```
- **Lines 9-11**: Procedure execution
- JCLLIB: Procedure library
- PRCCCSCB: CICS COBOL compile procedure
- COPYLIB: Copybook library
- LOADLIB: Load library

```jcl
//TRN.SYSIN  DD DSN=OZA266.ELE.SOURCE.CICS.NEW(&CICSPGM),DISP=SHR
//LKED.SYSIN DD  *
  NAME ECSTC030(R)
/*
//
```
- **Lines 13-17**: Input and linkage editor
- TRN.SYSIN: Source code input
- LKED.SYSIN: Linkage editor commands
- NAME: Program name specification

---

### CICSMAP - Map Assembly

**Purpose**: JCL to assemble BMS maps

```jcl
//OZA266M1 JOB OZA,OZA,MSGLEVEL=(1,1),
//            CLASS=A,MSGCLASS=A,NOTIFY=&SYSUID
```
- **Lines 1-2**: Job statement

```jcl
//MAPPROC  JCLLIB ORDER=OZAGSB.USER.PROCLIB
//CICSMAP  EXEC PRCMAPCB,
//             COPYLIB=OZA266.ELE.CPYBK,
//             LOADLIB=OZAADM.CICS.LOADLIB
```
- **Lines 4-6**: Map assembly procedure

```jcl
//ASM.SYSIN  DD DSN=OZA266.ELE.SOURCE.MAP(&MAPNAME),DISP=SHR
//LKED.SYSIN DD  *
  NAME &MAPNAME(R)
/*
//
```
- **Lines 8-13**: Map source and linkage editor

---

### struct - Directory Structure

**Purpose**: Documentation of directory organization

```
cobol.cics/customer/
├── CODE/                    # COBOL program source files
│   ├── ECSTC030            # Customer Create program
│   ├── ECSTR040            # Customer Read program
│   ├── ECSTU050            # Customer Update program
│   ├── EMNUO010            # Main Menu program
│   ├── EMNUO020            # Sub Menu program
│   ├── CBLSCMP             # Compilation JCL
│   └── CICSOZA             # Additional CICS utilities
├── MAP/                     # BMS map definitions
│   ├── eb01msd             # Customer Create map
│   ├── eb02msd             # Customer Read map
│   ├── eb03msd             # Customer Update map (old)
│   ├── eb04msd             # Customer Read screen
│   ├── eb05msd             # Customer Update screen
│   └── CICSMAP             # Map assembly JCL
├── CICS_SYSTEM_DOCUMENTATION.md  # System documentation
└── struct                  # Directory structure info
```

---

## Summary

This CICS Customer System provides a complete CRUD (Create, Read, Update) functionality for customer management with the following key features:

1. **Modular Design**: Separate programs for each function
2. **Consistent Error Handling**: Comprehensive CICS response code management
3. **User-Friendly Interfaces**: Well-designed BMS maps with clear navigation
4. **Robust Data Management**: Proper VSAM KSDS file operations
5. **Menu System**: Organized navigation through main and sub-menus
6. **Single Map Approach**: Modernized from dual-map to single-map design for better user experience

The system follows mainframe CICS programming best practices with proper error handling, user feedback, and data integrity measures.
