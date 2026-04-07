# CBLDBBND - DB2 Program Bind JCL

## Overview
CBLDBBND is a JCL (Job Control Language) script used to bind COBOL programs with DB2 database modules. This script creates DB2 application plans that allow COBOL programs to execute SQL statements.

## Purpose
- **Bind COBOL DB2 Programs**: Creates DB2 application plans for COBOL programs
- **Database Connectivity**: Enables COBOL programs to communicate with DB2 databases
- **Plan Management**: Manages DB2 application plans with specific binding options

## Job Configuration
```jcl
//OZA267BR JOB OZA,OZA,MSGLEVEL=(1,1),
//             CLASS=A,MSGCLASS=A,NOTIFY=&SYSUID,REGION=0M
```

### Job Parameters
- **JOB NAME**: OZA267BR
- **USER**: OZA (replace with actual user ID)
- **CLASS**: A (production job class)
- **MSGLEVEL**: (1,1) - detailed job logging
- **REGION**: 0M - unlimited region size

## Key Components

### 1. Library Definitions (JOBLIB)
```jcl
//JOBLIB   DD DISP=SHR,DSN=DSNA10.DBAG.SDSNEXIT
//         DD DISP=SHR,DSN=DSNA10.SDSNLOAD
//         DD DISP=SHR,DSN=CEE.SCEERUN
```

#### Libraries Used:
- **DSNA10.DBAG.SDSNEXIT**: DB2 exit routines
- **DSNA10.SDSNLOAD**: DB2 load modules
- **CEE.SCEERUN**: LE/370 runtime environment

### 2. Bind Plan Execution
```jcl
//BINDPLAN EXEC PGM=IKJEFT01,DYNAMNBR=20
```

#### Program Details:
- **PGM=IKJEFT01**: DB2 TSO attachment facility
- **DYNAMNBR=20**: Maximum dynamic SQL statements

### 3. DBRM Library
```jcl
//DBRMLIB  DD DSN=OZA267.TRGA5.DBRMLIB,DISP=SHR
```

#### DBRM Library:
- **Dataset**: OZA267.TRGA5.DBRMLIB
- **Purpose**: Contains Database Request Modules (DBRMs)
- **Access**: Shared read access

### 4. Output Files
```jcl
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
```

#### Output Destinations:
- **SYSTSPRT**: TSO output
- **SYSPRINT**: Bind process output
- **SYSUDUMP**: System dump (if errors occur)
- **SYSOUT**: General job output

## DB2 Bind Commands

### 1. Database Connection
```jcl
  DSN SYSTEM(DBAG)
```

#### Connection Parameters:
- **SYSTEM**: DBAG (DB2 subsystem name)
- **Purpose**: Connect to DB2 subsystem

### 2. Bind Statement
```jcl
  BIND  MEMBER(CUST004) -
        PLAN(OZA267A) -
        QUALIFIER(OZA267) -
        OWNER(OZA267) -
        ACTION(REP) -
        ISOLATION(CS) -
        VALIDATE(BIND) -
        RELEASE(COMMIT)
```

#### Bind Parameters:
- **MEMBER**: CUST004 - DBRM member name
- **PLAN**: OZA267A - Application plan name
- **QUALIFIER**: OZA267 - Default schema/qualifier
- **OWNER**: OZA267 - Plan owner
- **ACTION**: REP - Replace existing plan
- **ISOLATION**: CS - Cursor Stability
- **VALIDATE**: BIND - Validate at bind time
- **RELEASE**: COMMIT - Release locks at commit

## Important Notes

### 1. User ID Replacement
```jcl
//*** KEEP USERID IN PLACE OF OZA267 ***
```
- Replace all instances of "OZA267" with actual user ID
- Includes job name, dataset names, and bind parameters

### 2. Plan Naming Convention
```jcl
//*** NOTE: NEVER USE OZA267PL AS A PLAN NAME ***
```
- Avoid using "PL" suffix for plan names
- Use meaningful plan names that don't conflict with standards

### 3. Library Paths
Ensure the following libraries are accessible:
- **DBRMLIB**: Must contain the DBRM member to be bound
- **STEPLIB**: Must contain DB2 runtime libraries
- **LOADLIB**: Must contain compiled COBOL programs

## Usage Instructions

### 1. Preparation
- Ensure COBOL program is compiled and DBRM is created
- Verify DBRM member exists in DBRMLIB
- Check DB2 subsystem availability

### 2. Execution
- Submit JCL to appropriate job class
- Monitor job execution for completion
- Check return codes for successful bind

### 3. Verification
- Review SYSPRINT for bind results
- Confirm plan creation with DB2 commands
- Test program execution with new plan

## Error Handling

### Common Issues:
1. **DBRM Not Found**: Verify DBRM member exists in DBRMLIB
2. **DB2 Connection Failed**: Check DB2 subsystem status
3. **Bind Errors**: Review SYSPRINT for specific error messages
4. **Authorization Issues**: Verify user has BIND authority

### Troubleshooting:
- Check SYSOUT for job execution details
- Review SYSPRINT for bind-specific messages
- Verify dataset allocations and permissions
- Confirm DB2 subsystem is active

## Security Considerations

### Access Requirements:
- **BIND AUTHORITY**: User must have BIND privilege on target database
- **Dataset Access**: Read access to DBRMLIB and STEPLIB datasets
- **TSO Access**: Ability to execute IKJEFT01 program

### Best Practices:
- Use specific plan names that follow naming conventions
- Regular backup of application plans
- Monitor bind job execution for errors
- Document plan versions and dependencies

## Related Files
- **DBRM Members**: Database Request Modules created during COBOL compilation
- **COBOL Programs**: Source programs containing embedded SQL
- **Load Modules**: Compiled COBOL programs ready for execution
- **Application Plans**: DB2 execution plans for SQL statements

## Maintenance
- **Plan Rebinding**: Rebind plans after database schema changes
- **Version Control**: Track plan versions with application releases
- **Performance Monitoring**: Monitor plan performance and optimize as needed
