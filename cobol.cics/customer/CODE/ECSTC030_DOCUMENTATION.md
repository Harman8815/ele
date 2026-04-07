# ECSTC030 - Customer Create Program

## Purpose
Creates new customer records in the KSDS file with comprehensive error handling and user feedback.

## Line-by-Line Explanation

### Identification Division
```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ECSTC030.
```
- **Lines 1-2**: Program identification section
- Defines program name as ECSTC030 for CICS system recognition

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
           COPY EB01MSD.
```
- **Lines 9-11**: Copy required CICS copybooks
- **DFHBMSCA**: Basic map communication area structure
- **DFHAID**: Attention identifier constants (PF keys, ENTER, CLEAR, etc.)
- **EB01MSD**: Map definition for customer create screen

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
- **DFHRESP-NORMAL (0)**: Successful operation
- **DFHRESP-NOTFND (+13)**: Record not found
- **DFHRESP-LENGERR (+16)**: Record length error
- **DFHRESP-IOERR (+18)**: I/O error occurred
- **DFHRESP-NOTOPEN (+19)**: Dataset not open
- **DFHRESP-ENOTFND (+20)**: Entry not found
- **DFHRESP-ILLLOG (+28)**: Illegal logic condition
- **DFHRESP-TERMERR (+32)**: Terminal error
- **DFHRESP-DUPKEY (+33)**: Duplicate key
- **DFHRESP-DUPREC (+34)**: Duplicate record

### Working Storage Variables
```cobol
       01 WS-COMMAREA.
          05 WS-STAGE            PIC X VALUE '1'.  *> '1'=MAP1, '2'=MAP2
```
- **Lines 26-27**: Communication area for program state management
- **WS-STAGE**: Tracks which map/screen is currently active ('1' for initial input)

```cobol
       77 WS-RESP-CODE           PIC S9(08) COMP.
       77 WS-RESP-DISPLAY-CODE  PIC 9(08) DISPLAY.
       01 WS-MSG                 PIC X(40).
       01 WS-CUST-ID             PIC X(12).
```
- **Lines 29-33**: Working storage variables
- **WS-RESP-CODE**: Stores CICS command response codes
- **WS-RESP-DISPLAY-CODE**: For displaying response codes to user
- **WS-MSG**: General message field for user communication
- **WS-CUST-ID**: Customer ID storage (12 characters)

### Customer Record Structure
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
- **Lines 35-43**: Customer record structure (total 83 bytes)
- **CUST-ID**: Customer identifier (12 characters)
- **FIRST-NAME**: First name (10 characters)
- **LAST-NAME**: Last name (10 characters)
- **AREA-CODE**: Area code (6 characters)
- **OUT-SPACE**: Spacer character (1 character)
- **ADDRESS-1**: Street address (29 characters)
- **CITY**: City name (10 characters)
- **UNITS**: Units/consumption (5 characters)
- This structure matches the KSDS file record layout exactly

### Linkage Section
```cobol
       LINKAGE SECTION.
       01 DFHCOMMAREA.
          05 LK-COMM             PIC X.
```
- **Lines 45-48**: Linkage section for CICS communication
- **DFHCOMMAREA**: Standard CICS communication area for passing data between program invocations

### Procedure Division
```cobol
       PROCEDURE DIVISION.
       1000-MAIN-LOGIC.
```
- **Lines 50-52**: Main procedure division entry point

### Main Program Logic
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
- **EIBCALEN = 0**: First time invocation (no commarea), send initial map
- **EIBCALEN > 0**: Return from user input, process data based on stage
- **Two-stage process**: Input → Create
- Uses commarea to maintain state between program invocations

### Send Map Procedure
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
- **LOW-VALUES**: Clear all map fields to spaces/binary zeros
- **-1 to CIDL**: Position cursor on Customer ID field for user input
- **SEND MAP**: Display the input screen to user terminal
- **RESP(WS-RESP-CODE)**: Capture response code for error handling

### Return to CICS
```cobol
           MOVE '1' TO WS-STAGE
           EXEC CICS RETURN
                TRANSID('EB01')
                COMMAREA(WS-COMMAREA)
                LENGTH(1)
           END-EXEC.
```
- **Lines 79-84**: Return control to CICS
- **TRANSID('EB01')**: Transaction identifier for next invocation
- **COMMAREA**: Pass state information to next program invocation
- **LENGTH(1)**: Size of commarea being passed

### Receive Map Procedure
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
- **RECEIVE MAP**: Get data from user screen input
- **Error handling**: Handle map receive failures and redisplay input screen

### Validate Customer ID
```cobol
           MOVE CIDI TO WS-CUST-ID
           IF WS-CUST-ID = SPACES
               MOVE 'ENTER CUSTOMER ID' TO MSGTXTO
               PERFORM 2000-SEND-MAP1
           END-IF.
```
- **Lines 100-104**: Validate customer ID input
- **CIDI**: Customer ID from input map
- **Validation**: Require customer ID to proceed with record creation
- **Error message**: Display message if customer ID is missing

### Process Create Data
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
- **Data transfer**: Move all user input from map fields to record structure
- **Field mapping**: Map input fields to work area fields
- **Call VSAM write**: Execute write routine to store record

### Write VSAM Record
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
- **Lines 117-131**: Write record to KSDS file with comprehensive error handling
- **DATASET('CU01KSDS')**: Target VSAM KSDS file name
- **FROM(WS-WORK-AREA)**: Source data for the record
- **RIDFLD(CUST-ID)**: Key field for the record (customer ID)
- **Error handling**: Specific messages for different error conditions
- **Success**: Customer created successfully
- **Duplicate**: Customer already exists
- **I/O Error**: System I/O problem
- **Other**: Generic error message

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
- **Lines 133-141**: Program termination
- **Exit message**: Send termination message to user
- **SEND TEXT**: Display text message on screen
- **RETURN END-EXEC**: Return to CICS for next transaction

## Program Flow Summary

1. **Initial Invocation**: Send input map for customer data
2. **User Input**: Receive customer details from map
3. **Validation**: Check required fields (customer ID)
4. **Data Processing**: Move map data to record structure
5. **VSAM Write**: Write record to CU01KSDS file
6. **Error Handling**: Handle various VSAM write conditions
7. **Feedback**: Display success/error messages to user
8. **Termination**: Clean exit with user instructions

## Key Features

- **Comprehensive Error Handling**: Covers all major CICS response codes
- **User-Friendly Interface**: Clear error messages and instructions
- **Data Validation**: Ensures required fields are provided
- **State Management**: Uses commarea for multi-stage processing
- **VSAM Integration**: Proper KSDS file operations
- **Robust Design**: Handles edge cases and error conditions
