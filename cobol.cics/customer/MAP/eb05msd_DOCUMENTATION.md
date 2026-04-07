# eb05msd - Customer Update Screen

## Purpose
Modern single-map BMS definition for customer update functionality, providing a unified interface for displaying existing data and receiving updates.

## Line-by-Line Explanation

### Map Set Definition
```cobol
EB05MSD DFHMSD TYPE=&SYSPARM,MODE=INOUT,LANG=COBOL,                   X
               STORAGE=AUTO,CTRL=(FREEKB,FRSET),TIOAPFX=YES
```
- **Lines 1-2**: Map set definition with CICS parameters
- **EB05MSD**: Map set name (used in COPY statement)
- **TYPE=&SYSPARM**: System parameter mode
- **MODE=INOUT**: Supports both input and output operations
- **LANG=COBOL**: COBOL language interface
- **STORAGE=AUTO**: Automatic storage management
- **CTRL=(FREEKB,FRSET)**: Control options
- **TIOAPFX=YES**: Terminal I/O area prefix

### Map Definition
```cobol
EB05MAP DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
```
- **Line 4**: Individual map definition
- **EB05MAP**: Map name (referenced in CICS commands)
- **SIZE=(24,80)**: Screen dimensions (24 lines, 80 columns)
- **LINE=1,COLUMN=1**: Starting position (top-left corner)

### Screen Title
```cobol
*----------------------------------------------------------------*
* TITLE
*----------------------------------------------------------------*
TITLE   DFHMDF POS=(2,25),LENGTH=30,ATTRB=(PROT),                      X
               INITIAL='CUSTOMER UPDATE SCREEN'
```
- **Lines 6-9**: Screen title field
- **TITLE**: Field name (generates TITLEO/TITLEI)
- **POS=(2,25)**: Position at line 2, column 25
- **LENGTH=30**: 30 characters long
- **ATTRB=(PROT)**: Protected field (display only)
- **INITIAL**: Default text "CUSTOMER UPDATE SCREEN"

### Input Field Section Header
```cobol
*----------------------------------------------------------------*
* INPUT FIELD - CUSTOMER ID
*----------------------------------------------------------------*
```
- **Lines 11-13**: Comment section for customer ID input

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
* OUTPUT FIELDS - EXISTING VALUES
*----------------------------------------------------------------*
```
- **Lines 20-22**: Comment section for existing value display

### First Name Existing Value
```cobol
FN-OLDL DFHMDF POS=(7,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='FIRST NAME  :'
FN-OLD  DFHMDF POS=(7,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 24-27**: First name existing value field group
- **FN-OLDL**: Label field ("FIRST NAME  :")
  - **POS=(7,10)**: Line 7, column 10
  - **LENGTH=15**: 15 characters for label
  - **ATTRB=(PROT)**: Protected display only
- **FN-OLD**: Existing value display field (protected)
  - **POS=(7,30)**: Line 7, column 30
  - **LENGTH=15**: 15 characters for first name
  - **ATTRB=(PROT)**: Protected (program writes, user reads)

### Last Name Existing Value
```cobol
LN-OLDL DFHMDF POS=(8,10),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='LAST NAME   :'
LN-OLD  DFHMDF POS=(8,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 29-32**: Last name existing value field group
- **LN-OLDL**: Label field ("LAST NAME   :")
  - **POS=(8,10)**: Line 8, column 10
- **LN-OLD**: Existing value display field (protected)
  - **POS=(8,30)**: Line 8, column 30
  - **LENGTH=15**: 15 characters for last name

### Area Code Existing Value
```cobol
AREA-OLDL DFHMDF POS=(9,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='AREA CODE   :'
AREA-OLD DFHMDF POS=(9,30),LENGTH=10,ATTRB=(PROT)
```
- **Lines 34-37**: Area code existing value field group
- **AREA-OLDL**: Label field ("AREA CODE   :")
  - **POS=(9,10)**: Line 9, column 10
- **AREA-OLD**: Existing value display field (protected)
  - **POS=(9,30)**: Line 9, column 30
  - **LENGTH=10**: 10 characters for area code

### Address Existing Value
```cobol
ADDR-OLDL DFHMDF POS=(10,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='ADDRESS     :'
ADDR-OLD DFHMDF POS=(10,30),LENGTH=30,ATTRB=(PROT)
```
- **Lines 39-42**: Address existing value field group
- **ADDR-OLDL**: Label field ("ADDRESS     :")
  - **POS=(10,10)**: Line 10, column 10
- **ADDR-OLD**: Existing value display field (protected)
  - **POS=(10,30)**: Line 10, column 30
  - **LENGTH=30**: 30 characters for address

### City Existing Value
```cobol
CITY-OLDL DFHMDF POS=(11,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='CITY        :'
CITY-OLD DFHMDF POS=(11,30),LENGTH=15,ATTRB=(PROT)
```
- **Lines 44-47**: City existing value field group
- **CITY-OLDL**: Label field ("CITY        :")
  - **POS=(11,10)**: Line 11, column 10
- **CITY-OLD**: Existing value display field (protected)
  - **POS=(11,30)**: Line 11, column 30
  - **LENGTH=15**: 15 characters for city

### Units Existing Value
```cobol
UNIT-OLDL DFHMDF POS=(12,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='UNITS       :'
UNIT-OLD DFHMDF POS=(12,30),LENGTH=6,ATTRB=(PROT)
```
- **Lines 49-52**: Units existing value field group
- **UNIT-OLDL**: Label field ("UNITS       :")
  - **POS=(12,10)**: Line 12, column 10
- **UNIT-OLD**: Existing value display field (protected)
  - **POS=(12,30)**: Line 12, column 30
  - **LENGTH=6**: 6 characters for units

### Input Fields Section Header
```cobol
*----------------------------------------------------------------*
* INPUT FIELDS - NEW VALUES
*----------------------------------------------------------------*
```
- **Lines 54-56**: Comment section for new value input

### First Name New Value
```cobol
FN-NEWL  DFHMDF POS=(7,50),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='NEW VALUE:'
FN-NEW   DFHMDF POS=(7,65),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 58-61**: First name new value field group
- **FN-NEWL**: Label field ("NEW VALUE:")
  - **POS=(7,50)**: Line 7, column 50 (right side)
  - **LENGTH=15**: 15 characters for label
  - **ATTRB=(PROT)**: Protected display only
- **FN-NEW**: New value input field (unprotected)
  - **POS=(7,65)**: Line 7, column 65
  - **LENGTH=15**: 15 characters for first name
  - **ATTRB=(UNPROT,FSET)**: User input allowed

### Last Name New Value
```cobol
LN-NEWL  DFHMDF POS=(8,50),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='NEW VALUE:'
LN-NEW   DFHMDF POS=(8,65),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 63-66**: Last name new value field group
- **LN-NEWL**: Label field ("NEW VALUE:")
  - **POS=(8,50)**: Line 8, column 50
- **LN-NEW**: New value input field (unprotected)
  - **POS=(8,65)**: Line 8, column 65
  - **LENGTH=15**: 15 characters for last name

### Area Code New Value
```cobol
AREA-NEWL DFHMDF POS=(9,50),LENGTH=15,ATTRB=(PROT),                      X
               INITIAL='NEW VALUE:'
AREA-NEW DFHMDF POS=(9,65),LENGTH=10,ATTRB=(UNPROT,FSET)
```
- **Lines 68-71**: Area code new value field group
- **AREA-NEWL**: Label field ("NEW VALUE:")
  - **POS=(9,50)**: Line 9, column 50
- **AREA-NEW**: New value input field (unprotected)
  - **POS=(9,65)**: Line 9, column 65
  - **LENGTH=10**: 10 characters for area code

### Address New Value
```cobol
ADDR-NEWL DFHMDF POS=(10,50),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='NEW VALUE:'
ADDR-NEW DFHMDF POS=(10,65),LENGTH=30,ATTRB=(UNPROT,FSET)
```
- **Lines 73-76**: Address new value field group
- **ADDR-NEWL**: Label field ("NEW VALUE:")
  - **POS=(10,50)**: Line 10, column 50
- **ADDR-NEW**: New value input field (unprotected)
  - **POS=(10,65)**: Line 10, column 65
  - **LENGTH=30**: 30 characters for address

### City New Value
```cobol
CITY-NEWL DFHMDF POS=(11,50),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='NEW VALUE:'
CITY-NEW DFHMDF POS=(11,65),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 78-81**: City new value field group
- **CITY-NEWL**: Label field ("NEW VALUE:")
  - **POS=(11,50)**: Line 11, column 50
- **CITY-NEW**: New value input field (unprotected)
  - **POS=(11,65)**: Line 11, column 65
  - **LENGTH=15**: 15 characters for city

### Message Field Section Header
```cobol
*----------------------------------------------------------------*
* MESSAGE FIELD
*----------------------------------------------------------------*
```
- **Lines 83-85**: Comment section for message field

### Message Display Field
```cobol
MSG-L   DFHMDF POS=(15,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='MESSAGE     :'
MSGTXT  DFHMDF POS=(15,30),LENGTH=45,ATTRB=(PROT)
```
- **Lines 87-90**: Message display field group
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
- **Lines 92-95**: Function key instructions and map end
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
- **FN-OLDL**: First name old label output
- **FN-OLD**: First name old value output
- **FN-NEWL**: First name new label output
- **FN-NEW**: First name new value output
- **LN-OLDL**: Last name old label output
- **LN-OLD**: Last name old value output
- **LN-NEWL**: Last name new label output
- **LN-NEW**: Last name new value output
- **AREA-OLDL**: Area code old label output
- **AREA-OLD**: Area code old value output
- **AREA-NEWL**: Area code new label output
- **AREA-NEW**: Area code new value output
- **ADDR-OLDL**: Address old label output
- **ADDR-OLD**: Address old value output
- **ADDR-NEWL**: Address new label output
- **ADDR-NEW**: Address new value output
- **CITY-OLDL**: City old label output
- **CITY-OLD**: City old value output
- **CITY-NEWL**: City new label output
- **CITY-NEW**: City new value output
- **UNIT-OLDL**: Units old label output
- **UNIT-OLD**: Units old value output
- **MSG-L**: Message label output
- **MSGTXT**: Message text output

### Input Fields (for RECEIVE MAP)
- **TITLEI**: Title field input
- **CID-LI**: Customer ID label input
- **CIDI**: Customer ID field input
- **FN-OLDLI**: First name old label input (protected)
- **FN-OLDI**: First name old value input (protected)
- **FN-NEWLI**: First name new label input (protected)
- **FN-NEWI**: First name new value input
- **LN-OLDLI**: Last name old label input (protected)
- **LN-OLDI**: Last name old value input (protected)
- **LN-NEWLI**: Last name new label input (protected)
- **LN-NEWI**: Last name new value input
- **AREA-OLDLI**: Area code old label input (protected)
- **AREA-OLDI**: Area code old value input (protected)
- **AREA-NEWLI**: Area code new label input (protected)
- **AREA-NEWI**: Area code new value input
- **ADDR-OLDLI**: Address old label input (protected)
- **ADDR-OLDI**: Address old value input (protected)
- **ADDR-NEWLI**: Address new label input (protected)
- **ADDR-NEWI**: Address new value input
- **CITY-OLDLI**: City old label input (protected)
- **CITY-OLDI**: City old value input (protected)
- **CITY-NEWLI**: City new label input (protected)
- **CITY-NEWI**: City new value input
- **UNIT-OLDLI**: Units old label input (protected)
- **UNIT-OLDI**: Units old value input (protected)
- **MSG-LI**: Message label input (protected)
- **MSGTXTI**: Message text input (protected)

## Screen Layout

```
                    CUSTOMER UPDATE SCREEN
                    
     ENTER CUSTOMER ID : [____________]
     
     FIRST NAME  :       [____________]    NEW VALUE: [____________]
     LAST NAME   :       [____________]    NEW VALUE: [____________]
     AREA CODE   :       [__________]      NEW VALUE: [__________]
     ADDRESS     :       [________________] NEW VALUE: [________________]
     CITY        :       [____________]    NEW VALUE: [____________]
     UNITS       :       [______]
     
     MESSAGE     :       [_____________________________________]
     
          PF3->EXIT | PF6->CLR SCR
```

## Key Features

- **Single Map Design**: Unified interface for all update operations
- **Side-by-Side Comparison**: Existing and new values displayed together
- **Field-Level Updates**: Individual fields can be updated independently
- **Three-Column Layout**: Field | Existing Value | New Value
- **Protected Display**: Existing values shown but not editable
- **Flexible Updates**: User can update any combination of fields
- **Units Protection**: Units field is display only (no new value field)

## Usage in Programs

This map is used by:
- **ECSTU050**: Customer Update program
- **SEND MAP('EB05MAP')**: Display the screen
- **RECEIVE MAP('EB05MAP')**: Get user input
- **Three-Stage Process**:
  1. Customer ID input
  2. Display existing data
  3. Receive field updates

## Program Flow

1. **Stage 1**: Display screen for customer ID input
2. **User Input**: User enters customer ID in CID field
3. **VSAM Read**: Program reads customer record from CU01KSDS
4. **Stage 2**: Display existing data in OLD value fields
5. **User Updates**: User enters new values in NEW value fields
6. **Field Processing**: Program updates only fields with new data
7. **VSAM Rewrite**: Updated record written back to file

## Advantages Over Dual-Map Approach

- **Simplified Navigation**: Single screen instead of two
- **Better UX**: Side-by-side comparison of old/new values
- **Reduced Complexity**: Simpler program logic
- **Visual Clarity**: Clear three-column layout
- **Efficient Updates**: All changes made on single screen

## Field Naming Convention

- **OLD suffix**: Existing values (protected display)
- **NEW suffix**: User input values
- **OLDL/NEWL suffix**: Label fields for old/new values
- **No suffix**: Primary data fields

## Differences from eb03msd

- **Single Map**: One screen instead of two separate maps
- **Unified Interface**: All functionality in single map
- **Simplified Logic**: Easier program flow
- **Better UX**: More intuitive user experience
- **Reduced State Management**: Less complex program state

## Design Considerations

- **Visual Comparison**: Easy to see old vs new values
- **Field-Level Updates**: Only update fields with user input
- **Protected Display**: Prevent accidental modification of existing data
- **Consistent Layout**: Same field positions as other maps
- **Error Handling**: Message area for feedback
- **User Guidance**: Clear labels and instructions

## Enhanced Field Sizes

Compared to earlier versions, this map uses larger field sizes:
- **First Name**: 15 characters (increased from 10)
- **Last Name**: 15 characters (increased from 10)
- **Area Code**: 10 characters (increased from 6)
- **Address**: 30 characters (increased from 29)
- **City**: 15 characters (increased from 10)

## Integration with System

- **Transaction ID**: EB05 (for ECSTU050 program)
- **VSAM Integration**: Works with CU01KSDS file
- **Error Handling**: Integrates with CICS response codes
- **Menu System**: Accessible from main menu (EMNUO010)
- **Field Validation**: Program validates field inputs before update
