# eb03msd - Customer Update Map (Dual Map Version)

## Purpose
Original dual-map BMS definition for customer update functionality, using separate maps for customer ID input and update data entry.

## Line-by-Line Explanation

### Map Set Definition
```cobol
EB03MSD DFHMSD TYPE=&SYSPARM,MODE=INOUT,LANG=COBOL,                   X
               STORAGE=AUTO,CTRL=(FREEKB,FRSET),TIOAPFX=YES
```
- **Lines 1-2**: Map set definition with CICS parameters
- **EB03MSD**: Map set name (used in COPY statement)
- **TYPE=&SYSPARM**: System parameter mode
- **MODE=INOUT**: Supports both input and output operations
- **LANG=COBOL**: COBOL language interface
- **STORAGE=AUTO**: Automatic storage management
- **CTRL=(FREEKB,FRSET)**: Control options
- **TIOAPFX=YES**: Terminal I/O area prefix

### Map1 - Customer ID Input
```cobol
*----------------------------------------------------------------*
* MAP1 : CUSTOMER ID INPUT
*----------------------------------------------------------------*
EB03MAP1 DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
```
- **Lines 4-6**: First map definition for customer ID input
- **EB03MAP1**: Map name for customer ID screen
- **SIZE=(24,80)**: Screen dimensions

#### Map1 Title
```cobol
TITLE1  DFHMDF POS=(2,25),LENGTH=25,ATTRB=(PROT),              X
               INITIAL='CUSTOMER UPDATE'
```
- **Lines 8-10**: Title field for first map
- **TITLE1**: Field name (generates TITLE1O/TITLE1I)
- **POS=(2,25)**: Line 2, column 25
- **INITIAL**: "CUSTOMER UPDATE"

#### Customer ID Input
```cobol
CID-L   DFHMDF POS=(6,10),LENGTH=20,ATTRB=(PROT),              X
               INITIAL='ENTER CUSTOMER ID :'
CID     DFHMDF POS=(6,35),LENGTH=12,ATTRB=(UNPROT,FSET)        X
```
- **Lines 12-15**: Customer ID input field
- **CID-L**: Label field ("ENTER CUSTOMER ID :")
- **CID**: Input field for customer ID

#### Message Field
```cobol
MSG1-L  DFHMDF POS=(10,10),LENGTH=10,ATTRB=(PROT),                    X
               INITIAL='MESSAGE:'
MSG1    DFHMDF POS=(10,25),LENGTH=45,ATTRB=(PROT)
```
- **Lines 17-19**: Message display field
- **MSG1-L**: Label field ("MESSAGE:")
- **MSG1**: Message text field (protected)

### Map2 - Update Screen
```cobol
*----------------------------------------------------------------*
* MAP2 : UPDATE SCREEN
*----------------------------------------------------------------*
EB03MAP2 DFHMDI SIZE=(24,80),LINE=1,COLUMN=1
```
- **Lines 21-23**: Second map definition for update screen
- **EB03MAP2**: Map name for update data screen

#### Map2 Title
```cobol
TITLE2  DFHMDF POS=(2,20),LENGTH=35,ATTRB=(PROT),                     X
               INITIAL='CUSTOMER UPDATE SCREEN'
```
- **Lines 25-27**: Title field for second map
- **TITLE2**: Field name (generates TITLE2O/TITLE2I)
- **INITIAL**: "CUSTOMER UPDATE SCREEN"

#### Column Headers
```cobol
HDR1    DFHMDF POS=(4,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='FIELD'
HDR2    DFHMDF POS=(4,30),LENGTH=20,ATTRB=(PROT),                     X
               INITIAL='EXISTING VALUE'
HDR3    DFHMDF POS=(4,55),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='NEW VALUE'
```
- **Lines 29-34**: Column headers for update screen
- **HDR1**: "FIELD" column header
- **HDR2**: "EXISTING VALUE" column header
- **HDR3**: "NEW VALUE" column header

#### First Name Fields
```cobol
*----------------------------------------------------------------*
* FIRST NAME
*----------------------------------------------------------------*
FN-L    DFHMDF POS=(6,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='FIRST NAME :'
FN-OLD  DFHMDF POS=(6,30),LENGTH=15,ATTRB=(PROT)
FN-NEW  DFHMDF POS=(6,55),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 36-41**: First name field group
- **FN-L**: Label field ("FIRST NAME :")
- **FN-OLD**: Existing value field (protected display)
- **FN-NEW**: New value field (user input)

#### Last Name Fields
```cobol
*----------------------------------------------------------------*
* LAST NAME
*----------------------------------------------------------------*
LN-L    DFHMDF POS=(7,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='LAST NAME  :'
LN-OLD  DFHMDF POS=(7,30),LENGTH=15,ATTRB=(PROT)
LN-NEW  DFHMDF POS=(7,55),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 43-48**: Last name field group
- **LN-L**: Label field ("LAST NAME  :")
- **LN-OLD**: Existing value field (protected)
- **LN-NEW**: New value field (user input)

#### Area Code Fields
```cobol
*----------------------------------------------------------------*
* AREA CODE
*----------------------------------------------------------------*
AR-L    DFHMDF POS=(8,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='AREA CODE  :'
AR-OLD  DFHMDF POS=(8,30),LENGTH=10,ATTRB=(PROT)
AR-NEW  DFHMDF POS=(8,55),LENGTH=10,ATTRB=(UNPROT,FSET)
```
- **Lines 50-55**: Area code field group
- **AR-L**: Label field ("AREA CODE  :")
- **AR-OLD**: Existing value field (protected)
- **AR-NEW**: New value field (user input)

#### Address Fields
```cobol
*----------------------------------------------------------------*
* ADDRESS
*----------------------------------------------------------------*
AD-L    DFHMDF POS=(9,10),LENGTH=15,ATTRB=(PROT),                     X
               INITIAL='ADDRESS    :'
AD-OLD  DFHMDF POS=(9,30),LENGTH=20,ATTRB=(PROT)
AD-NEW  DFHMDF POS=(9,55),LENGTH=20,ATTRB=(UNPROT,FSET)
```
- **Lines 57-62**: Address field group
- **AD-L**: Label field ("ADDRESS    :")
- **AD-OLD**: Existing value field (protected)
- **AD-NEW**: New value field (user input)

#### City Fields
```cobol
*----------------------------------------------------------------*
* CITY
*----------------------------------------------------------------*
CT-L    DFHMDF POS=(10,10),LENGTH=15,ATTRB=(PROT),                    X
                INITIAL='CITY       :'
CT-OLD  DFHMDF POS=(10,30),LENGTH=15,ATTRB=(PROT)
CT-NEW  DFHMDF POS=(10,55),LENGTH=15,ATTRB=(UNPROT,FSET)
```
- **Lines 64-69**: City field group
- **CT-L**: Label field ("CITY       :")
- **CT-OLD**: Existing value field (protected)
- **CT-NEW**: New value field (user input)

#### Units Field
```cobol
*----------------------------------------------------------------*
* UNITS (PROTECTED)
*----------------------------------------------------------------*
UN-L    DFHMDF POS=(11,10),LENGTH=15,ATTRB=(PROT),                    X
                INITIAL='UNITS      :'
UN-OLD  DFHMDF POS=(11,30),LENGTH=6,ATTRB=(PROT)
```
- **Lines 71-75**: Units field group
- **UN-L**: Label field ("UNITS      :")
- **UN-OLD**: Existing value field (protected)
- **Note**: No UN-NEW field - units cannot be updated

#### Message Field
```cobol
*----------------------------------------------------------------*
* MESSAGE
*----------------------------------------------------------------*
MSG2-L  DFHMDF POS=(14,10),LENGTH=10,ATTRB=(PROT),                    X
               INITIAL='MESSAGE:'
MSG2    DFHMDF POS=(14,25),LENGTH=45,ATTRB=(PROT)
```
- **Lines 77-80**: Message display field
- **MSG2-L**: Label field ("MESSAGE:")
- **MSG2**: Message text field (protected)

#### Function Key Instructions
```cobol
        DFHMDF POS=(18,10),LENGTH=25,ATTRB=(PROT),                     X
               INITIAL='PF3->EXIT | PF6->CLR SCR '
         DFHMSD TYPE=FINAL
       END
```
- **Lines 82-85**: Function key instructions and map end

## Generated Field Names

### Map1 Fields
#### Output Fields
- **TITLE1O**: Title field output
- **CID-L**: Customer ID label output
- **CID**: Customer ID field output
- **MSG1-L**: Message label output
- **MSG1**: Message text output

#### Input Fields
- **TITLE1I**: Title field input
- **CID-LI**: Customer ID label input
- **CIDI**: Customer ID field input
- **MSG1-LI**: Message label input
- **MSG1I**: Message text input

### Map2 Fields
#### Output Fields
- **TITLE2O**: Title field output
- **HDR1**: Header 1 output
- **HDR2**: Header 2 output
- **HDR3**: Header 3 output
- **FN-L**: First name label output
- **FN-OLD**: First name old value output
- **FN-NEW**: First name new value output
- **LN-L**: Last name label output
- **LN-OLD**: Last name old value output
- **LN-NEW**: Last name new value output
- **AR-L**: Area code label output
- **AR-OLD**: Area code old value output
- **AR-NEW**: Area code new value output
- **AD-L**: Address label output
- **AD-OLD**: Address old value output
- **AD-NEW**: Address new value output
- **CT-L**: City label output
- **CT-OLD**: City old value output
- **CT-NEW**: City new value output
- **UN-L**: Units label output
- **UN-OLD**: Units old value output
- **MSG2-L**: Message label output
- **MSG2**: Message text output

#### Input Fields
- **TITLE2I**: Title field input
- **HDR1I**: Header 1 input
- **HDR2I**: Header 2 input
- **HDR3I**: Header 3 input
- **FN-LI**: First name label input
- **FN-OLDI**: First name old value input (protected)
- **FN-NEWI**: First name new value input
- **LN-LI**: Last name label input
- **LN-OLDI**: Last name old value input (protected)
- **LN-NEWI**: Last name new value input
- **AR-LI**: Area code label input
- **AR-OLDI**: Area code old value input (protected)
- **AR-NEWI**: Area code new value input
- **AD-LI**: Address label input
- **AD-OLDI**: Address old value input (protected)
- **AD-NEWI**: Address new value input
- **CT-LI**: City label input
- **CT-OLDI**: City old value input (protected)
- **CT-NEWI**: City new value input
- **UN-LI**: Units label input
- **UN-OLDI**: Units old value input (protected)
- **MSG2-LI**: Message label input
- **MSG2I**: Message text input (protected)

## Screen Layouts

### Map1 - Customer ID Input
```
               CUSTOMER UPDATE

     ENTER CUSTOMER ID : [____________]
     
     MESSAGE: [_____________________________________]
     
          PF3->EXIT | PF6->CLR SCR
```

### Map2 - Update Screen
```
          CUSTOMER UPDATE SCREEN

     FIELD           EXISTING VALUE    NEW VALUE
     -------------------------------------------------
     FIRST NAME :     [____________]    [____________]
     LAST NAME  :     [____________]    [____________]
     AREA CODE  :     [__________]      [__________]
     ADDRESS    :     [________________] [________________]
     CITY       :     [____________]    [____________]
     UNITS      :     [______]
     
     MESSAGE: [_____________________________________]
     
          PF3->EXIT | PF6->CLR SCR
```

## Key Features

- **Dual Map Design**: Separate screens for ID input and data update
- **Side-by-Side Comparison**: Existing and new values displayed together
- **Field-Level Updates**: Individual fields can be updated independently
- **Protected Display**: Existing values shown but not editable
- **Clear Column Headers**: Three-column layout for clarity
- **Units Protection**: Units field cannot be updated (display only)

## Usage in Programs

This map was originally designed for:
- **ECSTU050**: Customer Update program (before single-map redesign)
- **Two-Stage Process**: 
  1. Send MAP1, receive customer ID
  2. Send MAP2 with existing data, receive updates

## Program Flow

1. **Stage 1**: Display MAP1 for customer ID input
2. **User Input**: User enters customer ID
3. **VSAM Read**: Program reads customer record
4. **Stage 2**: Display MAP2 with existing data
5. **User Updates**: User enters new values in NEW VALUE columns
6. **Field Processing**: Program updates only fields with new data

## Limitations

- **Complex Navigation**: Requires two separate screens
- **State Management**: More complex program flow
- **User Experience**: Multiple screens for single operation
- **Maintenance**: Two maps to maintain instead of one

## Replacement by eb05msd

This dual-map approach has been replaced by:
- **eb05msd**: Single unified map design
- **Simplified Flow**: Single screen for all operations
- **Better UX**: More intuitive user interface
- **Reduced Complexity**: Simpler program logic

## Historical Context

- **Original Design**: Early CICS applications often used dual-map approach
- **Evolution**: Moved toward single-map designs for better UX
- **Legacy Code**: May still exist in older mainframe systems
- **Modern Practice**: Single-map designs preferred

## Field Naming Convention

- **OLD suffix**: Existing values (protected)
- **NEW suffix**: User input values
- **L suffix**: Label fields
- **No suffix**: Primary data fields
