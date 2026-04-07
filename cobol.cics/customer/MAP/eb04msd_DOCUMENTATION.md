# eb04msd - Customer Read Screen

## Purpose
Simplified single-map BMS definition for customer read functionality, providing customer ID input and customer data display in a unified interface.

## Line-by-Line Explanation

### Map Set Definition
```cobol
EB04MSD DFHMSD TYPE=&SYSPARM,MODE=INOUT,LANG=COBOL,                    X
               STORAGE=AUTO,CTRL=(FREEKB,FRSET),TIOAPFX=YES
```
- **Lines 1-2**: Map set definition with CICS parameters
- **EB04MSD**: Map set name (used in COPY statement)
- **TYPE=&SYSPARM**: System parameter mode
- **MODE=INOUT**: Supports both input and output operations
- **LANG=COBOL**: COBOL language interface
- **STORAGE=AUTO**: Automatic storage management
- **CTRL=(FREEKB,FRSET)**: Control options
- **TIOAPFX=YES**: Terminal I/O area prefix

### Map Definition
```cobol
EB04MAP DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
```
- **Line 4**: Individual map definition
- **EB04MAP**: Map name (referenced in CICS commands)
- **SIZE=(24,80)**: Screen dimensions (24 lines, 80 columns)
- **LINE=1,COLUMN=1**: Starting position (top-left corner)

### Screen Title
```cobol
*----------------------------------------------------------------*
* TITLE
*----------------------------------------------------------------*
TITLE   DFHMDF POS=(2,25),LENGTH=30,ATTRB=(PROT),                      X
               INITIAL='CUSTOMER READ SCREEN'
```
- **Lines 6-9**: Screen title field
- **TITLE**: Field name (generates TITLEO/TITLEI)
- **POS=(2,25)**: Position at line 2, column 25
- **LENGTH=30**: 30 characters long
- **ATTRB=(PROT)**: Protected field (display only)
- **INITIAL**: Default text "CUSTOMER READ SCREEN"

### Input Field Section Header
```cobol
*----------------------------------------------------------------*
* INPUT FIELD
*----------------------------------------------------------------*
```
- **Lines 11-13**: Comment section for input fields

### Customer ID Field
```cobol
CID-L   DFHMDF POS=(5,10),LENGTH=20,ATTRB=(PROT),                      X
               INITIAL='ENTER CUSTOMER ID :'
CID     DFHMDF POS=(5,35),LENGTH=12,ATTRB=(UNPROT,FSET)
```
- **Lines 15-18**: Customer ID input field group
- **CID-L**: Label field (protected, displays "ENTER CUSTOMER ID :")
  - **POS=(5,10)**: Line 5, column 10
  - **LENGTH=20**: 20 characters for label text
  - **ATTRB=(PROT)**: Protected (display only)
- **CID**: Input field (unprotected for user input)
  - **POS=(5,35)**: Line 5, column 35
  - **LENGTH=12**: 12 characters for customer ID
  - **ATTRB=(UNPROT,FSET)**: User input allowed, cursor can position

### Output Fields Section Header
```cobol
*----------------------------------------------------------------*
* OUTPUT FIELDS
*----------------------------------------------------------------*
```
- **Lines 20-22**: Comment section for output fields

### First Name Display Field
```cobol
FN-L    DFHMDF POS=(7,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='FIRST NAME  :'
FN      DFHMDF POS=(7,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 24-27**: First name display field group
- **FN-L**: Label field ("FIRST NAME  :")
  - **POS=(7,10)**: Line 7, column 10
  - **LENGTH=15**: 15 characters for label
  - **ATTRB=(PROT)**: Protected display only
- **FN**: Display field for first name (protected)
  - **POS=(7,30)**: Line 7, column 30
  - **LENGTH=15**: 15 characters for first name
  - **ATTRB=(PROT)**: Protected (program writes, user reads)

### Last Name Display Field
```cobol
LN-L    DFHMDF POS=(8,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='LAST NAME   :'
LN      DFHMDF POS=(8,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 29-32**: Last name display field group
- **LN-L**: Label field ("LAST NAME   :")
  - **POS=(8,10)**: Line 8, column 10
- **LN**: Display field for last name (protected)
  - **POS=(8,30)**: Line 8, column 30
  - **LENGTH=15**: 15 characters for last name

### Area Code Display Field
```cobol
AREA-L  DFHMDF POS=(9,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='AREA CODE   :'
AREA    DFHMDF POS=(9,30),LENGTH=10,ATTRB=(PROT)
```
- **Lines 34-37**: Area code display field group
- **AREA-L**: Label field ("AREA CODE   :")
  - **POS=(9,10)**: Line 9, column 10
- **AREA**: Display field for area code (protected)
  - **POS=(9,30)**: Line 9, column 30
  - **LENGTH=10**: 10 characters for area code

### Address Display Field
```cobol
ADDR-L  DFHMDF POS=(10,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='ADDRESS     :'
ADDR    DFHMDF POS=(10,30),LENGTH=30,ATTRB=(PROT)
```
- **Lines 39-42**: Address display field group
- **ADDR-L**: Label field ("ADDRESS     :")
  - **POS=(10,10)**: Line 10, column 10
- **ADDR**: Display field for address (protected)
  - **POS=(10,30)**: Line 10, column 30
  - **LENGTH=30**: 30 characters for address

### City Display Field
```cobol
CITY-L  DFHMDF POS=(11,10),LENGTH=15,ATTRB=(PROT),                     X
                INITIAL='CITY        :'
CITY    DFHMDF POS=(11,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 44-47**: City display field group
- **CITY-L**: Label field ("CITY        :")
  - **POS=(11,10)**: Line 11, column 10
- **CITY**: Display field for city (protected)
  - **POS=(11,30)**: Line 11, column 30
  - **LENGTH=15**: 15 characters for city

### Units Display Field
```cobol
UNIT-L  DFHMDF POS=(12,10),LENGTH=15,ATTRB=(PROT),                     X
                INITIAL='UNITS       :'
UNIT    DFHMDF POS=(12,30),LENGTH=6,ATTRB=(PROT)
```
- **Lines 49-52**: Units display field group
- **UNIT-L**: Label field ("UNITS       :")
  - **POS=(12,10)**: Line 12, column 10
- **UNIT**: Display field for units (protected)
  - **POS=(12,30)**: Line 12, column 30
  - **LENGTH=6**: 6 characters for units

### Message Field Section Header
```cobol
*----------------------------------------------------------------*
* MESSAGE FIELD
*----------------------------------------------------------------*
```
- **Lines 54-56**: Comment section for message field

### Message Display Field
```cobol
MSG-L   DFHMDF POS=(15,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='MESSAGE     :'
MSGTXT  DFHMDF POS=(15,30),LENGTH=45,ATTRB=(PROT)
```
- **Lines 58-61**: Message display field group
- **MSG-L**: Label field ("MESSAGE     :")
  - **POS=(15,10)**: Line 15, column 10
  - **LENGTH=15**: 15 characters for label
- **MSGTXT**: Message display field
  - **POS=(15,30)**: Line 15, column 30
  - **LENGTH=45**: 45 characters for messages
  - **ATTRB=(PROT)**: Protected (program writes, user reads)

### Function Key Instructions
```cobol
        DFHMDF POS=(18,10),LENGTH=25,ATTRB=(PROT),                     X
               INITIAL='PF3->EXIT | PF6->CLR SCR '
        DFHMSD TYPE=FINAL
       END
```
- **Lines 63-66**: Function key instructions and map end
- **POS=(18,10)**: Line 18, column 10
- **LENGTH=25**: 25 characters for instructions
- **INITIAL**: Function key help text
- **ATTRB=(PROT)**: Protected display only
- **DFHMSD TYPE=FINAL**: End of map set definition

## Generated Field Names

### Output Fields (for SEND MAP)
- **TITLEO**: Title field output
- **CID-L**: Customer ID label output
- **CID**: Customer ID field output
- **FN-L**: First name label output
- **FN**: First name display field output
- **LN-L**: Last name label output
- **LN**: Last name display field output
- **AREA-L**: Area code label output
- **AREA**: Area code display field output
- **ADDR-L**: Address label output
- **ADDR**: Address display field output
- **CITY-L**: City label output
- **CITY**: City display field output
- **UNIT-L**: Units label output
- **UNIT**: Units display field output
- **MSG-L**: Message label output
- **MSGTXT**: Message text output

### Input Fields (for RECEIVE MAP)
- **TITLEI**: Title field input
- **CID-LI**: Customer ID label input
- **CIDI**: Customer ID field input
- **FN-LI**: First name label input
- **FNI**: First name field input (protected - no user input)
- **LN-LI**: Last name label input
- **LNI**: Last name field input (protected - no user input)
- **AREA-LI**: Area code label input
- **AREAI**: Area code field input (protected - no user input)
- **ADDR-LI**: Address label input
- **ADDRI**: Address field input (protected - no user input)
- **CITY-LI**: City label input
- **CITYI**: City field input (protected - no user input)
- **UNIT-LI**: Units label input
- **UNITI**: Units field input (protected - no user input)
- **MSG-LI**: Message label input
- **MSGTXTI**: Message text input (protected - no user input)

## Screen Layout

```
                    CUSTOMER READ SCREEN
                    
     ENTER CUSTOMER ID : [____________]
     FIRST NAME  :       [____________]
     LAST NAME   :       [____________]
     AREA CODE   :       [__________]
     ADDRESS     :       [__________________________]
     CITY        :       [____________]
     UNITS       :       [______]
     
     MESSAGE     :       [_____________________________________]
     
          PF3->EXIT | PF6->CLR SCR
```

## Key Features

- **Single Map Design**: Unified interface for input and display
- **Input/Output Separation**: Clear distinction between input and display areas
- **Read-Only Data**: All customer data fields are protected
- **Consistent Layout**: Same field arrangement as other maps
- **Error Display**: Dedicated message area for feedback
- **User Guidance**: Function key instructions provided

## Usage in Programs

This map is used by:
- **ECSTR040**: Customer Read program
- **SEND MAP('EB04MAP')**: Display the screen
- **RECEIVE MAP('EB04MAP')**: Get customer ID input
- **Data Display**: Program moves data to FN, LN, AREA, etc. for display

## Program Flow

1. **Initial Display**: Show screen with empty data fields
2. **User Input**: User enters customer ID in CID field
3. **VSAM Read**: Program reads customer record from CU01KSDS
4. **Data Display**: Program populates display fields with customer data
5. **Screen Update**: Map sent back with customer data visible
6. **User Review**: User can view customer information

## Differences from eb02msd

- **Identical Functionality**: Essentially the same as eb02msd
- **Naming Convention**: Uses EB04 prefix instead of EB02
- **Program Association**: Used by ECSTR040 instead of ECSTR020
- **Field Names**: Same field names and layout
- **Purpose**: Same read-only customer display functionality

## Advantages Over Dual-Map Approach

- **Simplified Navigation**: Single screen instead of multiple
- **Better UX**: More intuitive user interface
- **Reduced Complexity**: Simpler program logic
- **Consistent Experience**: Same pattern as other single-map designs

## Design Considerations

- **Read-Only Safety**: Protected fields prevent accidental modification
- **Visual Consistency**: Matches layout of other customer maps
- **Clear Purpose**: Obviously a read/display screen
- **Error Handling**: Message area for read errors and feedback
- **Efficient Display**: All customer data visible on single screen
- **User Experience**: Simple, straightforward interface

## Field Length Consistency

All field lengths match the VSAM record structure:
- **Customer ID**: 12 characters
- **First Name**: 15 characters
- **Last Name**: 15 characters
- **Area Code**: 10 characters
- **Address**: 30 characters
- **City**: 15 characters
- **Units**: 6 characters

## Integration with System

- **Transaction ID**: EB04 (for ECSTR040 program)
- **VSAM Integration**: Works with CU01KSDS file
- **Error Handling**: Integrates with CICS response codes
- **Menu System**: Accessible from main menu (EMNUO010)
