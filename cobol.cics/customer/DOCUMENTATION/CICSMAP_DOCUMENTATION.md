# CICSMAP - Map Assembly JCL

## Purpose
Job Control Language (JCL) procedure for assembling BMS (Basic Mapping Support) maps in the CICS environment.

## Line-by-Line Explanation

### Job Statement
```jcl
//OZA266M1 JOB OZA,OZA,MSGLEVEL=(1,1),
//            CLASS=A,MSGCLASS=A,NOTIFY=&SYSUID
```
- **Lines 1-2**: Job statement defining the job characteristics
- **OZA266M1**: Job name (unique identifier)
  - **OZA**: User ID or account name
  - **266**: Project or system identifier
  - **M1**: Sequence number (M for Map assembly)
- **OZA,OZA**: Job owner and user ID
- **MSGLEVEL=(1,1)**: Message level specification
  - **First 1**: Print all job control statements
  - **Second 1**: Print all allocation messages
- **CLASS=A**: Job class for execution priority
- **MSGCLASS=A**: Message class for output routing
- **NOTIFY=&SYSUID**: Send notification to job submitter

### Procedure Library Definition
```jcl
//MAPPROC  JCLLIB ORDER=OZAGSB.USER.PROCLIB
```
- **Line 4**: JCLLIB statement defining procedure library
- **MAPPROC**: Step name for the JCLLIB
- **JCLLIB**: JCL statement defining procedure libraries
- **ORDER=OZAGSB.USER.PROCLIB**: Search order for procedures
  - **OZAGSB**: User's procedure library
  - **USER.PROCLIB**: Standard user procedure library

### Procedure Execution
```jcl
//CICSMAP  EXEC PRCMAPCB,
//             COPYLIB=OZA266.ELE.CPYBK,
//             LOADLIB=OZAADM.CICS.LOADLIB
```
- **Lines 6-8**: Execute the CICS map assembly procedure
- **CICSMAP**: Step name for the map assembly
- **EXEC PRCMAPCB**: Execute the PRCMAPCB procedure
  - **PRCMAPCB**: Predefined procedure for CICS map assembly
  - **CB**: COBOL language specification
- **COPYLIB=OZA266.ELE.CPYBK**: Copybook library specification
  - **OZA266.ELE.CPYBK**: Dataset containing map copybooks
  - **Contains**: BMS map definitions (eb01msd, eb02msd, etc.)
- **LOADLIB=OZAADM.CICS.LOADLIB**: Load library specification
  - **OZAADM.CICS.LOADLIB**: Dataset for assembled maps
  - **Contains**: Physical map modules (BMS executable code)

### Map Source Input
```jcl
//ASM.SYSIN  DD DSN=OZA266.ELE.SOURCE.MAP(&MAPNAME),DISP=SHR
```
- **Line 9**: Define input map source file
- **ASM.SYSIN**: DD name for assembler input
- **DD**: Data Definition statement
- **DSN=OZA266.ELE.SOURCE.MAP(&MAPNAME)**: Dataset specification
  - **OZA266.ELE.SOURCE.MAP**: Map source library
  - **(&MAPNAME)**: Member name (symbolic parameter)
  - **Examples**: eb01msd, eb02msd, eb03msd, eb04msd, eb05msd
- **DISP=SHR**: Disposition = Shared (read-only access)

### Linkage Editor Input
```jcl
//LKED.SYSIN DD  *
  NAME &MAPNAME(R)
/*
```
- **Lines 11-13**: Linkage editor control statements
- **LKED.SYSIN**: DD name for linkage editor input
- **DD ***: In-stream data follows
- **NAME &MAPNAME(R)**: Linkage editor command
  - **NAME**: Specify map name
  - **&MAPNAME**: Symbolic parameter for map name
  - **(R)**: Reentrant attribute (for CICS maps)
- **/***: End of in-stream data

### Job Termination
```jcl
//
```
- **Line 14**: Null statement marking end of job

## Usage Instructions

### Assembly Parameters
This JCL uses symbolic parameters that must be supplied:

```jcl
//   SET MAPNAME=eb01msd    // Customer Create Map
//   SET MAPNAME=eb02msd    // Customer Read Map
//   SET MAPNAME=eb03msd    // Customer Update Map (Dual)
//   SET MAPNAME=eb04msd    // Customer Read Screen
//   SET MAPNAME=eb05msd    // Customer Update Screen
```

### Complete Example
```jcl
//   SET MAPNAME=eb01msd
//OZA266M1 JOB OZA,OZA,MSGLEVEL=(1,1),
//            CLASS=A,MSGCLASS=A,NOTIFY=&SYSUID
//MAPPROC  JCLLIB ORDER=OZAGSB.USER.PROCLIB
//CICSMAP  EXEC PRCMAPCB,
//             COPYLIB=OZA266.ELE.CPYBK,
//             LOADLIB=OZAADM.CICS.LOADLIB
//ASM.SYSIN  DD DSN=OZA266.ELE.SOURCE.MAP(&MAPNAME),DISP=SHR
//LKED.SYSIN DD  *
  NAME &MAPNAME(R)
/*
//
```

## Assembly Process

### Step 1: Map Assembly
- **BMS Assembler**: Processes map definition source
- **Generates**: Physical map (executable code)
- **Validates**: Map syntax and field definitions
- **Creates**: Symbol table and field definitions

### Step 2: Linkage Editing
- **Linkage Editor**: Combines assembled modules
- **Creates**: Load module for CICS
- **Resolves**: External references
- **Sets**: Reentrant attribute for CICS

## Generated Files

### Physical Map
- **OZAADM.CICS.LOADLIB(&MAPNAME)**: Executable map module
- **Format**: CICS-compatible load module
- **Attributes**: Reentrant, CICS-enabled
- **Usage**: Referenced by CICS programs

### Assembly Listing
- **SYSOUT**: Contains assembly messages
- **Errors**: Map syntax errors, field definition issues
- **Statistics**: Assembly statistics, resource usage
- **Map Information**: Field names, positions, attributes

## Map Structure Validation

### Field Definitions
- **Field Names**: Valid COBOL identifiers
- **Positions**: Within screen boundaries (24x80)
- **Lengths**: Appropriate for data types
- **Attributes**: Valid protection and control settings

### Map Validation
- **Syntax**: Correct BMS macro usage
- **Structure**: Proper map set organization
- **Consistency**: Field naming conventions
- **Integration**: Compatibility with CICS programs

## Required Datasets

### Source Datasets
- **OZA266.ELE.SOURCE.MAP**: Map source code library
  - **eb01msd**: Customer Create map
  - **eb02msd**: Customer Read map
  - **eb03msd**: Customer Update map (dual)
  - **eb04msd**: Customer Read screen
  - **eb05msd**: Customer Update screen

### Copybook Library
- **OZA266.ELE.CPYBK**: Copybook library
  - **DFHBMSCA**: Basic map communication area
  - **DFHAID**: Attention identifier constants
  - **Map-specific copybooks**: Generated by BMS

### Load Library
- **OZAADM.CICS.LOADLIB**: Load library for maps
  - **Physical maps**: Executable map modules
  - **CICS integration**: Ready for CICS use

### Procedure Library
- **OZAGSB.USER.PROCLIB**: Procedure library
  - **PRCMAPCB**: Map assembly procedure
  - **Dependencies**: Assembler, linkage editor

## Error Scenarios

### Assembly Errors
- **Syntax Errors**: Invalid BMS macro syntax
- **Field Conflicts**: Duplicate field names or positions
- **Screen Overflow**: Fields outside screen boundaries
- **Invalid Attributes**: Incorrect protection or control settings

### JCL Errors
- **Dataset Not Found**: Map source or copybook datasets missing
- **Authorization Errors**: Insufficient access rights
- **Procedure Errors**: PRCMAPCB procedure not found
- **Parameter Errors**: Missing or incorrect symbolic parameters

### Linkage Errors
- **Unresolved References**: Missing map components
- **Storage Violations**: Memory allocation issues
- **Load Module Errors**: Format problems
- **Attribute Errors**: Incorrect reentrant settings

## Integration with Development Process

### Map Development Workflow
1. **Design**: Create map definition source
2. **Assembly**: Assemble map using CICSMAP JCL
3. **Testing**: Test map with CICS programs
4. **Deployment**: Move to production load library

### Program Integration
- **COPY Statement**: Programs reference map copybooks
- **SEND MAP**: Display map to user terminal
- **RECEIVE MAP**: Get user input from map
- **Field References**: Program uses generated field names

### Version Management
- **Source Control**: Track map definition changes
- **Load Module Updates**: Reassemble after changes
- **Testing**: Validate changes with programs
- **Documentation**: Update map documentation

## Best Practices

### Before Assembly
1. **Validate Source**: Check map syntax manually
2. **Verify Datasets**: Ensure all datasets exist
3. **Check Permissions**: Verify read/write access
4. **Test Parameters**: Validate symbolic parameters

### After Assembly
1. **Review Listings**: Check for warnings and errors
2. **Test Maps**: Verify with CICS programs
3. **Validate Fields**: Ensure all fields work correctly
4. **Update Documentation**: Record assembly results

### Maintenance
1. **Monitor Load Library**: Watch for space issues
2. **Track Changes**: Maintain assembly history
3. **Archive Listings**: Store assembly listings
4. **Update Procedures**: Keep PRCMAPCB current

## Customization Options

### Alternative Procedures
- **PRCMAPCB**: Standard CICS map assembly
- **Custom Procedures**: Organization-specific assembly steps
- **Debug Options**: Include debugging information

### Assembly Options
- **LIST**: Generate assembly listing
- **XREF**: Cross-reference listing
- **MAP**: Map structure listing
- **TEST**: Test assembly mode

## Troubleshooting

### Common Issues
1. **Map Not Found**: Check source dataset and member name
2. **Assembly Errors**: Review map syntax and field definitions
3. **Procedure Not Found**: Verify JCLLIB specification
4. **Load Module Errors**: Check load library permissions

### Debugging Steps
1. **Review JCL**: Check for syntax errors
2. **Check Parameters**: Verify symbolic parameters
3. **Examine Listings**: Look for error messages
4. **Test Environment**: Try assembly in test region

## Map-Specific Considerations

### Single Map vs Dual Map
- **eb01msd/eb02msd/eb04msd**: Single map designs
- **eb03msd**: Dual map design (MAP1/MAP2)
- **eb05msd**: Enhanced single map design

### Field Naming Conventions
- **Labels**: Field names with -L suffix
- **Input/Output**: -I/-O suffixes generated
- **Old/New Values**: -OLD/-NEW suffixes for update maps

### Screen Layout Optimization
- **Field Positioning**: Logical flow and grouping
- **Label Alignment**: Consistent positioning
- **User Experience**: Intuitive navigation
- **Function Keys**: Standard placement and instructions
