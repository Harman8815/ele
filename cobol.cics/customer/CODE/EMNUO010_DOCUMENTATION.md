# EMNUO010 - Main Menu Program

## Purpose
Provides the main menu interface for the CICS Customer System, allowing users to navigate to different customer management functions.

## Line-by-Line Explanation

### Identification Division
```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMNUO010.
```
- **Lines 1-2**: Program identification section
- Defines program name as EMNUO010 for CICS system recognition
- Menu program with transaction ID 'EMNU'

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
```
- **Lines 9-10**: Copy required CICS copybooks
- **DFHBMSCA**: Basic map communication area structure
- **DFHAID**: Attention identifier constants (PF keys, ENTER, CLEAR, etc.)
- No map copybook needed - uses SEND TEXT for menu display

### Menu Options Definition
```cobol
       01 WS-OPTIONS.
          05 WS-OPT-1            PIC X(40) VALUE '1 - CREATE CUSTOMER'.
          05 WS-OPT-2            PIC X(40) VALUE '2 - READ CUSTOMER'.
          05 WS-OPT-3            PIC X(40) VALUE '3 - UPDATE CUSTOMER'.
          05 WS-OPT-4            PIC X(40) VALUE '4 - EXIT'.
```
- **Lines 12-16**: Menu options display text
- **WS-OPT-1**: Create customer option
- **WS-OPT-2**: Read customer option
- **WS-OPT-3**: Update customer option
- **WS-OPT-4**: Exit system option
- Each option is 40 characters long for consistent display

### Working Storage Variables
```cobol
       01 WS-RESP-CODE           PIC S9(08) COMP.
       01 WS-MSG                 PIC X(40).
       01 WS-OPTION              PIC X.
```
- **Lines 18-20**: Working storage variables
- **WS-RESP-CODE**: Stores CICS command response codes
- **WS-MSG**: General message field for user communication
- **WS-OPTION**: Stores user's menu selection (single character)

### Procedure Division
```cobol
       PROCEDURE DIVISION.
       1000-MAIN-LOGIC.
```
- **Lines 22-24**: Main procedure division entry point

### Main Program Logic
```cobol
           IF EIBCALEN = 0
               PERFORM 2000-DISPLAY-MENU
           ELSE
               PERFORM 3000-PROCESS-OPTION
           END-IF.
```
- **Lines 26-30**: Main program logic flow
- **EIBCALEN = 0**: First time invocation, display menu
- **EIBCALEN > 0**: Return from user input, process selection
- **Two-stage process**: Display menu → Process selection

### Display Menu Procedure
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
- **Lines 32-46**: Display menu options to user
- **LOW-VALUES TO DFHCOMMAREA**: Clear communication area
- **Menu layout**: Position menu options in commarea
  - Option 1: Positions 1-40
  - Option 2: Positions 41-80
  - Option 3: Positions 81-120
  - Option 4: Positions 121-160
- **SEND TEXT**: Display menu text on user screen
- **LENGTH(160)**: Total length of menu display
- **RETURN**: Pass control back to CICS with state '1'

### Process Menu Option
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
- **Lines 48-66**: Process user's menu selection
- **DFHCOMMAREA(1:1) TO WS-OPTION**: Get user's single character selection
- **EVALUATE WS-OPTION**: Process different menu options
- **Option '1'**: Launch customer create program (EB01)
- **Option '2'**: Launch customer read program (EB04)
- **Option '3'**: Launch customer update program (EB05)
- **Option '4'**: Terminate session
- **Invalid option**: Display error message and redisplay menu

### Termination
```cobol
       9000-TERMINATE.
           MOVE 'SESSION TERMINATED' TO WS-MSG.
           EXEC CICS SEND TEXT
                           FROM(WS-MSG)
                           RESP(WS-RESP-CODE)
           END-EXEC.
           EXEC CICS RETURN END-EXEC.
```
- **Lines 68-73**: Program termination
- **Session message**: Inform user of session termination
- **SEND TEXT**: Display termination message
- **RETURN END-EXEC**: Return to CICS without further transactions

## Program Flow Summary

1. **Initial Invocation**: Display menu with four options
2. **User Selection**: User enters option number (1-4)
3. **Option Processing**: 
   - Option 1: Launch ECSTC030 (Create Customer)
   - Option 2: Launch ECSTR040 (Read Customer)
   - Option 3: Launch ECSTU050 (Update Customer)
   - Option 4: Terminate session
4. **Error Handling**: Handle invalid menu selections
5. **Navigation**: Provide seamless navigation between programs

## Key Features

- **Simple Interface**: Text-based menu using SEND TEXT
- **Clear Navigation**: Direct access to all customer functions
- **Error Handling**: Validates user input and provides feedback
- **Session Management**: Proper termination and cleanup
- **Transaction Routing**: Routes to appropriate programs based on selection
- **User-Friendly**: Clear option descriptions and error messages

## Transaction IDs

- **EMNU**: Main menu transaction (this program)
- **EB01**: Customer create program (ECSTC030)
- **EB04**: Customer read program (ECSTR040)
- **EB05**: Customer update program (ECSTU050)

## Menu Layout

When displayed, the menu appears as:
```
1 - CREATE CUSTOMER
2 - READ CUSTOMER
3 - UPDATE CUSTOMER
4 - EXIT
```

## Integration with System

- **Entry Point**: Serves as main entry point for customer system
- **Central Hub**: Provides access to all customer management functions
- **Stateless**: Each menu selection launches independent program
- **Return Flow**: User returns to menu after completing other functions

## Error Scenarios Handled

- **Invalid Option**: Non-numeric or out-of-range selections
- **Communication Errors**: SEND TEXT failures
- **Transaction Failures**: Issues launching other programs

## Design Considerations

- **Simplicity**: Uses SEND TEXT instead of BMS maps for flexibility
- **Efficiency**: Minimal overhead for menu display
- **Maintainability**: Easy to add/remove menu options
- **User Experience**: Clear, concise menu descriptions
- **System Integration**: Seamless integration with CICS transaction processing
