# CBLSCMP - Compilation JCL

## Purpose
Job Control Language (JCL) procedure for compiling COBOL CICS programs in the mainframe environment.

## Line-by-Line Explanation

### Job Statement
```jcl
//OZA266C1 JOB OZA,OZA,MSGLEVEL=(1,1),
//            CLASS=A,MSGCLASS=A,NOTIFY=&SYSUID,REGION=0M
```
- **Lines 1-2**: Job statement defining the job characteristics
- **OZA266C1**: Job name (unique identifier)
  - **OZA**: User ID or account name
  - **266**: Project or system identifier
  - **C1**: Sequence number for this job
- **OZA,OZA**: Job owner and user ID (both set to OZA)
- **MSGLEVEL=(1,1)**: Message level specification
  - **First 1**: Print all job control statements
  - **Second 1**: Print all allocation messages
- **CLASS=A**: Job class for execution priority
- **MSGCLASS=A**: Message class for output routing
- **NOTIFY=&SYSUID**: Send notification to job submitter
- **REGION=0M**: Unlimited region size (0M = no limit)

### Variable Definition
```jcl
//   SET CICSPGM=ECSTC030
```
- **Line 4**: Set statement defining a symbolic variable
- **CICSPGM**: Symbolic variable name
- **ECSTC030**: Default value (Customer Create program)
- **Purpose**: Allows easy program name changes without modifying entire JCL

### Documentation Comments
```jcl
//**********************************************************************
//***     SAMPLE JCL TO COMPILE COBOL + CICS PROGRAM                 ***
//***     KEEP USERID IN PLACE OF OZAGSB                             ***
//***     DO NOT CHANGE LOADLIB=OZAADM.CICS.LOADLIB                  ***
//**********************************************************************
```
- **Lines 6-8**: Documentation comments
- **Purpose**: Important instructions and warnings
- **KEEP USERID**: Maintain OZAGSB as user ID in procedures
- **LOADLIB WARNING**: Do not modify load library specification
- **SAMPLE JCL**: This is a template for compilation

### Procedure Library Definition
```jcl
//JOBPROC  JCLLIB ORDER=OZAGSB.USER.PROCLIB
```
- **Line 9**: JCLLIB statement defining procedure library
- **JOBPROC**: Step name for the JCLLIB
- **JCLLIB**: JCL statement defining procedure libraries
- **ORDER=OZAGSB.USER.PROCLIB**: Search order for procedures
  - **OZAGSB**: User's procedure library
  - **USER.PROCLIB**: Standard user procedure library

### Procedure Execution
```jcl
//CICSCOB  EXEC PRCCCSCB,
//             COPYLIB=OZA266.ELE.CPYBK,
//             LOADLIB=OZAADM.CICS.LOADLIB
```
- **Lines 10-12**: Execute the CICS COBOL compilation procedure
- **CICSCOB**: Step name for the compilation
- **EXEC PRCCCSCB**: Execute the PRCCCSCB procedure
  - **PRCCCSCB**: Predefined procedure for CICS COBOL compilation
- **COPYLIB=OZA266.ELE.CPYBK**: Copybook library specification
  - **OZA266.ELE.CPYBK**: Dataset containing copybooks
  - **Contains**: DFHBMSCA, DFHAID, map definitions, etc.
- **LOADLIB=OZAADM.CICS.LOADLIB**: Load library specification
  - **OZAADM.CICS.LOADLIB**: Dataset for compiled programs
  - **Warning**: Do not change as per documentation

### Source Code Input
```jcl
//TRN.SYSIN  DD DSN=OZA266.ELE.SOURCE.CICS.NEW(&CICSPGM),DISP=SHR
```
- **Line 13**: Define input source code file
- **TRN.SYSIN**: DD name for translator input
- **DD**: Data Definition statement
- **DSN=OZA266.ELE.SOURCE.CICS.NEW(&CICSPGM)**: Dataset specification
  - **OZA266.ELE.SOURCE.CICS.NEW**: Source code library
  - **(&CICSPGM)**: Member name (uses symbolic variable)
  - **Default**: ECSTC030 (Customer Create program)
- **DISP=SHR**: Disposition = Shared (read-only access)

### Linkage Editor Input
```jcl
//LKED.SYSIN DD  *
  NAME ECSTC030(R)
/*
```
- **Lines 14-16**: Linkage editor control statements
- **LKED.SYSIN**: DD name for linkage editor input
- **DD ***: In-stream data follows
- **NAME ECSTC030(R)**: Linkage editor command
  - **NAME**: Specify program name
  - **ECSTC030**: Program name (matches symbolic variable)
  - **(R)**: Reentrant attribute (for CICS programs)
- **/***: End of in-stream data

### Job Termination
```jcl
//
```
- **Line 17**: Null statement marking end of job

## Usage Instructions

### Compiling Different Programs
To compile different programs, change the SET statement:

```jcl
//   SET CICSPGM=ECSTR040    // Customer Read
//   SET CICSPGM=ECSTU050    // Customer Update
//   SET CICSPGM=EMNUO010    // Main Menu
//   SET CICSPGM=EMNUO020    // Sub Menu
```

### Required Datasets
The following datasets must exist:
- **OZA266.ELE.CPYBK**: Copybook library
- **OZAADM.CICS.LOADLIB**: Load library
- **OZA266.ELE.SOURCE.CICS.NEW**: Source code library
- **OZAGSB.USER.PROCLIB**: Procedure library

### Procedure Dependencies
- **PRCCCSCB**: Must exist in the procedure library
- **Contains**: COBOL compiler, CICS translator, linkage editor steps

## Compilation Process

### Step 1: CICS Translation
- CICS translator processes CICS commands
- Generates intermediate COBOL code
- Handles EXEC CICS statements

### Step 2: COBOL Compilation
- COBOL compiler processes translated code
- Generates object code
- Performs syntax checking

### Step 3: Linkage Editing
- Linkage editor combines object modules
- Creates load module
- Resolves external references

## Output Files

### Compilation Listing
- **SYSOUT**: Contains compilation messages
- **Errors**: Syntax errors, warnings, informational messages
- **Statistics**: Compilation statistics, resource usage

### Load Module
- **OZAADM.CICS.LOADLIB(ECSTC030)**: Executable program
- **Format**: CICS-compatible load module
- **Attributes**: Reentrant, CICS-enabled

## Error Scenarios

### Compilation Errors
- **Syntax Errors**: Invalid COBOL syntax
- **Copybook Errors**: Missing or invalid copybooks
- **CICS Errors**: Invalid CICS commands

### JCL Errors
- **Dataset Not Found**: Source or copybook datasets missing
- **Authorization Errors**: Insufficient access rights
- **Procedure Errors**: PRCCCSCB procedure not found

### Linkage Errors
- **Unresolved References**: Missing subprograms
- **Storage Violations**: Memory allocation issues
- **Load Module Errors**: Format problems

## Best Practices

### Before Submission
1. **Verify Datasets**: Ensure all required datasets exist
2. **Check Permissions**: Verify read/write access
3. **Validate Source**: Ensure source code is syntactically correct
4. **Test Copybooks**: Verify all copybooks are accessible

### After Compilation
1. **Review Listings**: Check for warnings and errors
2. **Test Load Module**: Verify program can be loaded
3. **Update Documentation**: Record compilation results
4. **Backup Load Module**: Save working version

### Maintenance
1. **Monitor Load Library**: Watch for space issues
2. **Update Procedures**: Keep PRCCCSCB procedure current
3. **Archive Listings**: Store compilation listings for reference
4. **Track Changes**: Maintain compilation history

## Integration with Development Process

### Source Code Management
- **Source Library**: OZA266.ELE.SOURCE.CICS.NEW
- **Version Control**: Track program versions
- **Change Management**: Document modifications

### Testing Integration
- **Test Region**: Compile in test environment first
- **Load Module Testing**: Verify program functionality
- **Regression Testing**: Ensure no breaking changes

### Production Deployment
- **Production Compile**: Use production datasets
- **Load Library**: OZAADM.CICS.LOADLIB for production
- **Validation**: Test in production environment

## Customization Options

### Alternative Procedures
- **PRCCCSCB**: Standard CICS COBOL compilation
- **Custom Procedures**: Organization-specific compilation steps
- **Debug Options**: Include debugging information

### Compiler Options
- **LIST**: Generate compilation listing
- **XREF**: Cross-reference listing
- **MAP**: Data division map
- **OPTIMIZE**: Code optimization options

## Troubleshooting

### Common Issues
1. **Copybook Not Found**: Check COPYLIB dataset
2. **Procedure Not Found**: Verify JCLLIB specification
3. **Load Module Errors**: Check LOADLIB permissions
4. **Source Code Errors**: Review compilation listing

### Debugging Steps
1. **Review JCL**: Check for syntax errors
2. **Check Datasets**: Verify dataset names and permissions
3. **Examine Listings**: Look for error messages
4. **Test Environment**: Try compilation in test region
