# ECSTU050 - Customer Update Program

## Purpose
Updates existing customer records in KSDS file with single-map interface, comprehensive error handling, and field-level update capability.

## Line-by-Line Explanation

### Identification Division
```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ECSTU050.
```
- **Lines 1-2**: Program identification section
- Defines program name as ECSTU050 for CICS system recognition

### Environment Division
```cobol
       ENVIRONMENT DIVISION.
```
- **Line 4**: Environment division (no special configuration needed for CICS)

### Data Division
```cobol
       DATA DIVISION.
       WORKING-STORAGE SECTION.
```
- **Lines 6-7**: Data division with working storage for variables

### Copybooks
```cobol
           COPY DFHBMSCA.
           COPY DFHAID.
           COPY EB05MSD.
```
- **Lines 9-11**: Copy required CICS copybooks
- **DFHBMSCA**: Basic map communication area structure
- **DFHAID**: Attention identifier constants (PF keys, ENTER, CLEAR, etc.)
- **EB05MSD**: Single map definition for customer update screen

### CICS Response Codes
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
- **Lines 13-24**: CICS response code definitions for error handling
- Same response codes as other programs for consistency

### Working Storage Variables
```cobol
       01 WS-COMMAREA.
          05 WS-STAGE            PIC X VALUE '1'.
       01 WS-RESP-CODE           PIC S9(08) COMP.
       01 WS-RESP-DISPLAY-CODE  PIC 9(08) DISPLAY.
       01 WS-MSG                 PIC X(40).
```
- **Lines 26-32**: Working storage variables
- **WS-STAGE**: Tracks program stage ('1' for ID input, '2' for update)
- **WS-RESP-CODE**: Stores CICS command response codes
- **WS-RESP-DISPLAY-CODE**: For displaying response codes
- **WS-MSG**: General message field

### Customer ID Storage
```cobol
       01 WS-CUST-ID             PIC X(12).
```
- **Line 33**: Customer ID storage for VSAM operations

### Customer Record Structure
```cobol
       01 WS-CUST-REC.
          05 CUST-ID             PIC X(12).
          05 FIRST-NAME          PIC X(15).
          05 LAST-NAME           PIC X(15).
          05 AREA-CODE           PIC X(10).
          05 ADDRESS             PIC X(30).
          05 CITY                PIC X(15).
          05 UNITS               PIC 9(05).
```
- **Lines 35-43**: Customer record structure with updated field sizes
- **CUST-ID**: Customer identifier (12 characters)
- **FIRST-NAME**: First name (15 characters - increased from 10)
- **LAST-NAME**: Last name (15 characters - increased from 10)
- **AREA-CODE**: Area code (10 characters - increased from 6)
- **ADDRESS**: Street address (30 characters - increased from 29)
- **CITY**: City name (15 characters - increased from 10)
- **UNITS**: Units/consumption (5 numeric characters)
- Larger field sizes accommodate more comprehensive data

### New Data Storage
```cobol
       01 WS-NEW-DATA.
          05 WS-NFN              PIC X(15).
          05 WS-NLN              PIC X(15).
          05 WS-NAR              PIC X(10).
          05 WS-NAD              PIC X(20).
          05 WS-NCT              PIC X(15).
```
- **Lines 45-51**: Storage for new data values from user input
- **WS-NFN**: New first name
- **WS-NLN**: New last name
- **WS-NAR**: New area code
- **WS-NAD**: New address
- **WS-NCT**: New city
- Used to store user input before updating record

### Procedure Division
```cobol
       PROCEDURE DIVISION.
       1000-MAIN-LOGIC.
```
- **Lines 53-55**: Main procedure division entry point

### Main Program Logic
```cobol
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
- **Lines 57-68**: Three-stage process flow
- **Stage 1**: Customer ID input → Read existing record
- **Stage 2**: Display existing data → Receive updates → Process
- **Uses commarea**: Maintains state between invocations

### Initial Send Map
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
- **Lines 70-86**: Send initial customer ID input screen
- **LOW-VALUES**: Clear all map fields
- **-1 to CIDL**: Position cursor on Customer ID field
- **SEND MAP**: Display input screen
- **Stage '1'**: Set stage for customer ID input

### Update Screen Send Map
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
- **Lines 88-112**: Send update screen with existing data displayed
- **Display existing data**: Move record fields to map old-value fields
- **FN-OLD, LN-OLD, etc.**: Map fields for existing values
- **-1 to FN-NEWL**: Position cursor on first new value field
- **Stage '2'**: Set stage for update processing
- **Error handling**: Handle map send errors

### Receive Customer ID
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
- **Lines 114-130**: Receive customer ID for lookup
- **RECEIVE MAP**: Get customer ID from user input
- **Error handling**: Handle map receive failures
- **Validation**: Ensure customer ID is provided
- **WS-CUST-ID**: Store customer ID for VSAM read

### Receive Update Data
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
- **Lines 132-148**: Receive updated field values
- **RECEIVE MAP**: Get update data from user input
- **Error handling**: Handle map receive failures
- **Data transfer**: Move new values to work storage
- **FN-NEWI, LN-NEWI, etc.**: Map input fields for new values
- **WS-NFN, WS-NLN, etc.**: Work storage for new values

### Read VSAM Record
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
- **Lines 150-172**: Read existing customer record
- **DATASET('CU01KSDS')**: Target VSAM KSDS file
- **RIDFLD(WS-CUST-ID)**: Key field for read operation
- **INTO(WS-CUST-REC)**: Destination for read record
- **Error handling**: Comprehensive error handling for read conditions
- **Success**: Display update screen with existing data
- **Errors**: Display appropriate error messages

### Process Update
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
- **Lines 174-192**: Update only non-empty fields
- **Field-level updates**: Only update fields that have user input
- **WS-NFN NOT = SPACES**: Check if first name provided
- **Selective updates**: Preserve existing data for empty fields
- **Call rewrite**: Execute VSAM rewrite operation

### Rewrite VSAM Record
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
- **Lines 194-214**: Rewrite updated record to KSDS
- **REWRITE**: Update existing record in VSAM
- **DATASET('CU01KSDS')**: Target VSAM KSDS file
- **FROM(WS-CUST-REC)**: Source data for rewrite
- **Error handling**: Handle rewrite-specific errors
- **Success**: Record updated successfully
- **NOTFND**: Record disappeared between read and rewrite
- **DUPKEY/DUPREC**: Key/record conflicts
- **Other**: Generic rewrite error

### Termination
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
- **Lines 216-224**: Program termination
- **Exit message**: Send termination message to user
- **SEND TEXT**: Display text message on screen
- **RETURN END-EXEC**: Return to CICS

## Program Flow Summary

1. **Stage 1 - Customer ID Input**:
   - Send input map for customer ID
   - Receive customer ID from user
   - Validate customer ID
   - Read existing customer record

2. **Stage 2 - Update Processing**:
   - Display existing data on update screen
   - Receive updated field values from user
   - Update only non-empty fields (field-level updates)
   - Rewrite record to VSAM
   - Display success/error messages

## Key Features

- **Single Map Interface**: Replaces dual-map approach with single unified screen
- **Field-Level Updates**: Only updates fields that contain user input
- **Three-Stage Process**: Customer ID → Read → Update
- **Comprehensive Error Handling**: Covers all CICS response codes
- **User-Friendly Interface**: Side-by-side display of existing vs new values
- **Data Validation**: Validates customer ID and field inputs
- **Robust VSAM Operations**: Proper read and rewrite handling
- **State Management**: Uses commarea for multi-stage processing
- **Enhanced Field Sizes**: Larger fields accommodate more comprehensive data

## Differences from ECSTR040

- **Update Operation**: VSAM REWRITE instead of READ
- **Multi-Stage Processing**: Three stages vs single stage
- **Field-Level Updates**: Selective field updates vs display only
- **Single Map**: Unified interface vs dual-map approach
- **Data Modification**: Can change existing data vs read-only
- **Complex Logic**: More sophisticated program flow
- **Enhanced Error Handling**: Additional rewrite-specific errors
