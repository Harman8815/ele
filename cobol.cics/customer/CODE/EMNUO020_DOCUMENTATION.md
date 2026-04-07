# EMNUO020 - Sub Menu Program

## Purpose
Provides a secondary menu interface for additional system options, serving as an extension to the main menu system.

## Line-by-Line Explanation

### Identification Division
```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMNUO020.
```
- **Lines 1-2**: Program identification section
- Defines program name as EMNUO020 for CICS system recognition
- Sub-menu program with transaction ID 'EMNU2'

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

### Sub Menu Options Definition
```cobol
       01 WS-OPTIONS.
          05 WS-OPT-1            PIC X(40) VALUE '1 - REPORTS'.
          05 WS-OPT-2            PIC X(40) VALUE '2 - UTILITIES'.
          05 WS-OPT-3            PIC X(40) VALUE '3 - RETURN TO MAIN MENU'.
```
- **Lines 12-15**: Sub-menu options display text
- **WS-OPT-1**: Reports option (placeholder for future development)
- **WS-OPT-2**: Utilities option (placeholder for future development)
- **WS-OPT-3**: Return to main menu option
- Each option is 40 characters long for consistent display

### Working Storage Variables
```cobol
       01 WS-RESP-CODE           PIC S9(08) COMP.
       01 WS-OPTION              PIC X.
       01 WS-MSG                 PIC X(40).
```
- **Lines 17-20**: Working storage variables
- **WS-RESP-CODE**: Stores CICS command response codes
- **WS-OPTION**: Stores user's menu selection (single character)
- **WS-MSG**: General message field for user communication

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
- **EIBCALEN = 0**: First time invocation, display sub-menu
- **EIBCALEN > 0**: Return from user input, process selection
- **Two-stage process**: Display sub-menu → Process selection

### Display Sub Menu Procedure
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
- **Lines 32-46**: Display sub-menu options to user
- **LOW-VALUES TO DFHCOMMAREA**: Clear communication area
- **Menu layout**: Position sub-menu options in commarea
  - Option 1: Positions 1-40
  - Option 2: Positions 41-80
  - Option 3: Positions 81-120
- **SEND TEXT**: Display sub-menu text on user screen
- **LENGTH(120)**: Total length of sub-menu display (3 options × 40 chars)
- **RETURN**: Pass control back to CICS with state '1'

### Process Sub Menu Option
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
- **Lines 48-66**: Process user's sub-menu selection
- **DFHCOMMAREA(1:1) TO WS-OPTION**: Get user's single character selection
- **EVALUATE WS-OPTION**: Process different sub-menu options
- **Option '1'**: Reports - placeholder, shows "under development" message
- **Option '2'**: Utilities - placeholder, shows "under development" message
- **Option '3'**: Return to main menu (launch EMNUO010)
- **Invalid option**: Display error message and redisplay sub-menu

### Termination
```cobol
       9000-TERMINATE.
           MOVE 'RETURNING TO MAIN MENU' TO WS-MSG.
           EXEC CICS SEND TEXT
                           FROM(WS-MSG)
                           RESP(WS-RESP-CODE)
           END-EXEC.
           EXEC CICS RETURN END-EXEC.
```
- **Lines 68-73**: Program termination
- **Return message**: Inform user of return to main menu
- **SEND TEXT**: Display return message
- **RETURN END-EXEC**: Return to CICS for next transaction

## Program Flow Summary

1. **Initial Invocation**: Display sub-menu with three options
2. **User Selection**: User enters option number (1-3)
3. **Option Processing**: 
   - Option 1: Show "reports under development" message
   - Option 2: Show "utilities under development" message
   - Option 3: Return to main menu (EMNUO010)
4. **Error Handling**: Handle invalid menu selections
5. **Navigation**: Provide return path to main menu system

## Key Features

- **Extension Menu**: Provides access to additional system functions
- **Future-Ready**: Placeholder options for reports and utilities
- **Navigation Hub**: Clear path back to main menu
- **Error Handling**: Validates user input and provides feedback
- **Consistent Design**: Follows same pattern as main menu
- **User-Friendly**: Clear option descriptions and status messages

## Transaction IDs

- **EMNU2**: Sub-menu transaction (this program)
- **EMNU**: Main menu transaction (EMNUO010)

## Sub Menu Layout

When displayed, the sub-menu appears as:
```
1 - REPORTS
2 - UTILITIES
3 - RETURN TO MAIN MENU
```

## Integration with System

- **Extension**: Extends main menu functionality
- **Return Path**: Always returns to main menu (EMNUO010)
- **Placeholder Options**: Ready for future development
- **Consistent UX**: Maintains same user experience as main menu

## Future Development Areas

### Reports (Option 1)
Potential reports could include:
- Customer listing reports
- Activity summaries
- Statistical analysis
- Export functions

### Utilities (Option 2)
Potential utilities could include:
- Data maintenance tools
- System diagnostics
- Configuration management
- Batch processing functions

## Error Scenarios Handled

- **Invalid Option**: Non-numeric or out-of-range selections
- **Communication Errors**: SEND TEXT failures
- **Navigation Issues**: Problems returning to main menu

## Design Considerations

- **Scalability**: Easy to add new options as system grows
- **Maintainability**: Clear structure for future enhancements
- **User Experience**: Consistent with main menu design
- **Future-Proof**: Placeholder options for planned features
- **Navigation**: Clear return path to main system

## Relationship to Main Menu

- **Called From**: Typically invoked from main menu (EMNUO010)
- **Returns To**: Always returns to main menu
- **Purpose**: Extends functionality beyond basic CRUD operations
- **Design**: Complements rather than replaces main menu

## Development Status

- **Current**: Placeholder implementation with basic navigation
- **Planned**: Full implementation of reports and utilities
- **Architecture**: Ready for enhancement without breaking changes
- **Integration**: Seamlessly integrated with existing menu system
