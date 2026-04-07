# eb01msd - Customer Create Map

## Purpose
BMS (Basic Mapping Support) map definition for the customer creation screen, providing input fields for all customer data.

## Line-by-Line Explanation

### Map Set Definition
```cobol
EB01MSD DFHMSD TYPE=&SYSPARM,MODE=INOUT,LANG=COBOL,                   X
               STORAGE=AUTO,CTRL=(FREEKB,FRSET),TIOAPFX=YES
```
- **Lines 1-2**: Map set definition with CICS parameters
- **EB01MSD**: Map set name (used in COPY statement)
- **TYPE=&SYSPARM**: System parameter mode (uses system defaults)
- **MODE=INOUT**: Map supports both input and output operations
- **LANG=COBOL**: COBOL language interface for field generation
- **STORAGE=AUTO**: Automatic storage management for map data
- **CTRL=(FREEKB,FRSET)**: Control options
  - **FREEKB**: Free keyboard after field entry
  - **FRSET**: Field reset on next map send
- **TIOAPFX=YES**: Terminal I/O area prefix for map fields
- **X**: Continuation character (column 72)

### Map Definition
```cobol
EB01MAP DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
```
- **Line 4**: Individual map definition
- **EB01MAP**: Map name (referenced in CICS commands)
- **SIZE=(24,80)**: Screen dimensions (24 lines, 80 columns)
- **LINE=1,COLUMN=1**: Starting position on screen (top-left corner)

### Screen Title
```cobol
*----------------------------------------------------------------*
* TITLE
*----------------------------------------------------------------*
TITLE   DFHMDF POS=(2,25),LENGTH=30,ATTRB=(PROT),                      X
               INITIAL='CUSTOMER CREATE SCREEN'
```
- **Lines 6-9**: Screen title field
- **TITLE**: Field name (generates TITLEO/TITLEI)
- **POS=(2,25)**: Position at line 2, column 25
- **LENGTH=30**: 30 characters long
- **ATTRB=(PROT)**: Protected field (no user input allowed)
- **INITIAL**: Default text displayed on screen
- **X**: Continuation character

### Input Fields Section Header
```cobol
*----------------------------------------------------------------*
* INPUT FIELDS
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
  - **POS=(5,35)**: Line 5, column 35 (after label)
  - **LENGTH=12**: 12 characters for customer ID
  - **ATTRB=(UNPROT,FSET)**: 
    - **UNPROT**: User can input data
    - **FSET**: Field set (cursor can position here)

### First Name Field
```cobol
FN-L    DFHMDF POS=(7,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='FIRST NAME  :'
FN      DFHMDF POS=(7,30),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 20-23**: First name input field group
- **FN-L**: Label field ("FIRST NAME  :")
  - **POS=(7,10)**: Line 7, column 10
  - **LENGTH=15**: 15 characters for label
- **FN**: Input field for first name
  - **POS=(7,30)**: Line 7, column 30
  - **LENGTH=15**: 15 characters for first name

### Last Name Field
```cobol
LN-L    DFHMDF POS=(8,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='LAST NAME   :'
LN      DFHMDF POS=(8,30),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 25-28**: Last name input field group
- **LN-L**: Label field ("LAST NAME   :")
  - **POS=(8,10)**: Line 8, column 10
- **LN**: Input field for last name
  - **POS=(8,30)**: Line 8, column 30
  - **LENGTH=15**: 15 characters for last name

### Area Code Field
```cobol
AREA-L  DFHMDF POS=(9,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='AREA CODE   :'
AREA    DFHMDF POS=(9,30),LENGTH=10,ATTRB=(UNPROT,FSET)
```
- **Lines 30-33**: Area code input field group
- **AREA-L**: Label field ("AREA CODE   :")
  - **POS=(9,10)**: Line 9, column 10
- **AREA**: Input field for area code
  - **POS=(9,30)**: Line 9, column 30
  - **LENGTH=10**: 10 characters for area code

### Address Field
```cobol
ADDR-L  DFHMDF POS=(10,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='ADDRESS     :'
ADDR    DFHMDF POS=(10,30),LENGTH=30,ATTRB=(UNPROT,FSET)
```
- **Lines 35-38**: Address input field group
- **ADDR-L**: Label field ("ADDRESS     :")
  - **POS=(10,10)**: Line 10, column 10
- **ADDR**: Input field for address
  - **POS=(10,30)**: Line 10, column 30
  - **LENGTH=30**: 30 characters for address

### City Field
```cobol
CITY-L  DFHMDF POS=(11,10),LENGTH=15,ATTRB=(PROT),                     X
                INITIAL='CITY        :'
CITY    DFHMDF POS=(11,30),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 40-43**: City input field group
- **CITY-L**: Label field ("CITY        :")
  - **POS=(11,10)**: Line 11, column 10
- **CITY**: Input field for city
  - **POS=(11,30)**: Line 11, column 30
  - **LENGTH=15**: 15 characters for city

### Units Field
```cobol
UNIT-L  DFHMDF POS=(12,10),LENGTH=15,ATTRB=(PROT),                     X
                INITIAL='UNITS       :'
UNIT    DFHMDF POS=(12,30),LENGTH=6,ATTRB=(UNPROT,FSET)
```
- **Lines 45-48**: Units input field group
- **UNIT-L**: Label field ("UNITS       :")
  - **POS=(12,10)**: Line 12, column 10
- **UNIT**: Input field for units
  - **POS=(12,30)**: Line 12, column 30
  - **LENGTH=6**: 6 characters for units

### Message Field Section Header
```cobol
*----------------------------------------------------------------*
* MESSAGE FIELD
*----------------------------------------------------------------*
```
- **Lines 50-52**: Comment section for message field

### Message Display Field
```cobol
MSG-L   DFHMDF POS=(15,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='MESSAGE     :'
MSGTXT  DFHMDF POS=(15,30),LENGTH=45,ATTRB=(PROT)
```
- **Lines 54-57**: Message display field group
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
```
- **Lines 59-60**: Function key instructions
- **POS=(18,10)**: Line 18, column 10
- **LENGTH=25**: 25 characters for instructions
- **INITIAL**: Function key help text
- **ATTRB=(PROT)**: Protected display only

### Map End
```cobol
        DFHMSD TYPE=FINAL
       END
```
- **Lines 62-63**: Map set termination
- **DFHMSD TYPE=FINAL**: End of map set definition
- **END**: End of map definition

## Generated Field Names

When assembled, CICS generates the following field names:

### Output Fields (for SEND MAP)
- **TITLEO**: Title field output
- **CID-L**: Customer ID label output
- **CID**: Customer ID field output
- **FN-L**: First name label output
- **FN**: First name field output
- **LN-L**: Last name label output
- **LN**: Last name field output
- **AREA-L**: Area code label output
- **AREA**: Area code field output
- **ADDR-L**: Address label output
- **ADDR**: Address field output
- **CITY-L**: City label output
- **CITY**: City field output
- **UNIT-L**: Units label output
- **UNIT**: Units field output
- **MSG-L**: Message label output
- **MSGTXT**: Message text output

### Input Fields (for RECEIVE MAP)
- **TITLEI**: Title field input
- **CID-LI**: Customer ID label input
- **CIDI**: Customer ID field input
- **FN-LI**: First name label input
- **FNI**: First name field input
- **LN-LI**: Last name label input
- **LNI**: Last name field input
- **AREA-LI**: Area code label input
- **AREAI**: Area code field input
- **ADDR-LI**: Address label input
- **ADDRI**: Address field input
- **CITY-LI**: City label input
- **CITYI**: City field input
- **UNIT-LI**: Units label input
- **UNITI**: Units field input
- **MSG-LI**: Message label input
- **MSGTXTI**: Message text input

## Screen Layout

```
                    CUSTOMER CREATE SCREEN
                    
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

- **Comprehensive Input**: All customer data fields in one screen
- **Clear Labels**: Descriptive labels for each field
- **Logical Flow**: Fields arranged in logical order
- **User Guidance**: Function key instructions provided
- **Error Display**: Dedicated message area for feedback
- **Consistent Sizing**: Field sizes match VSAM record layout
- **Protected Labels**: Labels cannot be modified by user
- **Cursor Positioning**: First field (CID) receives cursor initially

## Usage in Programs

This map is used by:
- **ECSTC030**: Customer Create program
- **SEND MAP('EB01MAP')**: Display the input screen
- **RECEIVE MAP('EB01MAP')**: Get user input
- **Field References**: Program references CIDI, FNI, LNI, etc.

## Design Considerations

- **Field Lengths**: Match VSAM record structure exactly
- **Screen Positioning**: Logical flow from top to bottom
- **User Experience**: Clear, intuitive layout
- **Error Handling**: Dedicated message area for feedback
- **Function Keys**: Standard PF3 for exit, PF6 for clear
- **Accessibility**: High contrast between labels and input fields
