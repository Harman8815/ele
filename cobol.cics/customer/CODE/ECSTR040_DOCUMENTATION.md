# ECSTR040 - Customer Read Program

## Purpose
Reads and displays existing customer records from KSDS file with comprehensive error handling and user feedback.

## Line-by-Line Explanation

### Identification Division
```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ECSTR040.
```
- **Lines 1-2**: Program identification section
- Defines program name as ECSTR040 for CICS system recognition

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
           COPY EB04MSD.
```
- **Lines 9-11**: Copy required CICS copybooks
- **DFHBMSCA**: Basic map communication area structure
- **DFHAID**: Attention identifier constants (PF keys, ENTER, CLEAR, etc.)
- **EB04MSD**: Map definition for customer read screen

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
- **Lines 10-21**: CICS response code definitions for error handling
- Same response codes as ECSTC030 for consistency

### Working Storage Variables
```cobol
       01 WS-COMMAREA.
          05 WS-STAGE            PIC X VALUE '1'.
       01 WS-RESP-CODE           PIC S9(08) COMP.
       01 WS-RESP-DISPLAY-CODE  PIC 9(08) DISPLAY.
       01 WS-MSG                 PIC X(40).
       01 WS-CUST-ID             PIC X(12).
```
- **Lines 23-29**: Working storage variables
- **WS-STAGE**: Program stage tracking (simplified - only '1' needed)
- **WS-RESP-CODE**: Stores CICS command response codes
- **WS-RESP-DISPLAY-CODE**: For displaying response codes
- **WS-MSG**: General message field
- **WS-CUST-ID**: Customer ID storage

### Customer Record Structure
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
- **Lines 31-39**: Customer record structure (total 83 bytes)
- Same structure as ECSTC030 for consistency
- Used to store record read from VSAM

### Procedure Division
```cobol
       PROCEDURE DIVISION.
       1000-MAIN-LOGIC.
```
- **Lines 41-43**: Main procedure division entry point

### Main Program Logic
```cobol
           IF EIBCALEN = 0
               PERFORM 2000-SEND-MAP
           ELSE
               PERFORM 3000-RECEIVE-MAP
               PERFORM 4000-READ-VSAM
           END-IF.
```
- **Lines 45-50**: Main program logic flow
- **EIBCALEN = 0**: First time invocation, send input map
- **EIBCALEN > 0**: Return from user input, process read operation
- **Single-stage process**: Input → Read → Display
- Simpler than ECSTC030 as no multi-stage processing needed

### Send Map Procedure
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
- **LOW-VALUES**: Clear all map fields
- **-1 to CIDL**: Position cursor on Customer ID field
- **SEND MAP**: Display the input screen
- **RETURN**: Pass control back to CICS with state

### Receive Map Procedure
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
- **RECEIVE MAP**: Get customer ID from user input
- **Error handling**: Handle map receive failures
- **CIDI to WS-CUST-ID**: Store customer ID for VSAM read

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
- **DATASET('CU01KSDS')**: Target VSAM KSDS file
- **RIDFLD(WS-CUST-ID)**: Key field (customer ID) for read operation
- **INTO(WS-CUST-REC)**: Destination for read record
- **Error handling**: Specific messages for different error conditions
- **Success**: Call display routine
- **NOTFND**: Customer not found
- **LENGERR**: Record length mismatch
- **IOERR**: I/O system error
- **NOTOPEN**: Dataset not available
- **Other**: Generic read error

### Display Data Procedure
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
- **Data transfer**: Move record fields to map display fields
- **FN, LN, AREA, ADDR, CITY, UNIT**: Map output fields
- **PERFORM 2000-SEND-MAP**: Redisplay map with customer data

### Termination
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
- **Exit message**: Send termination message to user
- **SEND TEXT**: Display text message on screen
- **RETURN END-EXEC**: Return to CICS

## Program Flow Summary

1. **Initial Invocation**: Send input map for customer ID
2. **User Input**: Receive customer ID from map
3. **VSAM Read**: Read customer record from CU01KSDS file
4. **Error Handling**: Handle various read conditions (not found, I/O errors, etc.)
5. **Data Display**: Display customer data on map if read successful
6. **User Feedback**: Show appropriate messages for all conditions
7. **Termination**: Clean exit with user instructions

## Key Features

- **Simple Interface**: Single-stage process (enter ID → see data)
- **Comprehensive Error Handling**: Covers all major VSAM read conditions
- **User-Friendly Messages**: Clear feedback for all situations
- **Data Validation**: Validates customer ID input
- **Robust Read Operations**: Handles all VSAM read response codes
- **Consistent Structure**: Uses same record layout as other programs
- **Clean Design**: Straightforward logic flow for easy maintenance

## Differences from ECSTC030

- **Single Stage**: No multi-stage processing needed
- **Read Operation**: VSAM READ instead of WRITE
- **Display Focus**: Emphasis on data presentation rather than input
- **Simplified Logic**: More straightforward program flow
- **Error Types**: Read-specific error conditions (NOTFND, etc.)
