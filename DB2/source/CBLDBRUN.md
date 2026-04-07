# CBLDBRUN - COBOL DB2 Program Execution JCL

## Overview
CBLDBRUN is a JCL (Job Control Language) script used to execute COBOL programs that have been compiled with DB2 database connectivity. This script provides the runtime environment for DB2-enabled COBOL applications, including database connectivity and file I/O operations.

## Purpose
- **Program Execution**: Run compiled COBOL DB2 programs
- **Database Connectivity**: Establish connection to DB2 subsystem
- **Runtime Environment**: Provide necessary runtime libraries
- **File Management**: Handle input/output file operations

## Job Configuration
```jcl
//OZA265EX JOB OZA,OZA,MSGLEVEL=(1,1),
//             CLASS=A,MSGCLASS=A,NOTIFY=&SYSUID,REGION=0M
```

### Job Parameters
- **JOB NAME**: OZA265EX
- **USER**: OZA (replace with actual user ID)
- **CLASS**: A (production job class)
- **MSGLEVEL**: (1,1) - detailed job logging
- **REGION**: 0M - unlimited region size

## Key Components

### 1. Runtime Execution
```jcl
//RUNPGM   EXEC PGM=IKJEFT01
```

#### Execution Program:
- **PGM=IKJEFT01**: DB2 TSO attachment facility
- **Purpose**: Provides DB2 connectivity and program execution environment

### 2. Runtime Libraries
```jcl
//STEPLIB  DD DISP=SHR,DSN=DSNA10.DBAG.SDSNEXIT
//         DD DISP=SHR,DSN=DSNA10.SDSNLOAD
//         DD DISP=SHR,DSN=CEE.SCEERUN
```

#### Runtime Libraries:
- **DSNA10.DBAG.SDSNEXIT**: DB2 exit routines
- **DSNA10.SDSNLOAD**: DB2 load modules
- **CEE.SCEERUN**: LE/370 runtime environment

### 3. Program Files
```jcl
//METERIN  DD DSN=OZA265.GRP2.ELE.METER.PS,DISP=SHR
//CUSTKSDS DD DSN=OZA265.GRP2.CUST.KSDS,DISP=SHR
//METERERR DD SYSOUT=*
```

#### File Definitions:
- **METERIN**: Input file for meter data (sequential file)
- **CUSTKSDS**: Customer master file (VSAM KSDS)
- **METERERR**: Error output file (SYSOUT)

### 4. Output and Logging
```jcl
//SYSTSPRT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
```

#### Output Destinations:
- **SYSTSPRT**: TSO output and program messages
- **SYSOUT**: General job output
- **SYSPRINT**: Program-specific output

### 5. DB2 Execution Commands
```jcl
//SYSTSIN DD *
  DSN SYSTEM(DBAG)
  RUN PROGRAM(MTR002) -
  PLAN(OZA267A) -
  LIBRARY('OZA265.TRGA5.DB2.LOADLIB')
  END
/*
```

#### DB2 Commands:
- **DSN SYSTEM(DBAG)**: Connect to DB2 subsystem
- **RUN PROGRAM(MTR002)**: Execute specified program
- **PLAN(OZA267A)**: Use specified application plan
- **LIBRARY**: Specify load module library

## Execution Process

### 1. Environment Setup
- Load runtime libraries
- Establish DB2 connection
- Allocate file resources

### 2. Program Execution
- Load program from specified library
- Execute with specified application plan
- Handle file I/O operations

### 3. Database Operations
- Connect to DB2 subsystem
- Execute SQL statements via application plan
- Handle database transactions

### 4. Output Generation
- Generate program output
- Create error logs
- Produce execution reports

## File Operations

### Input Files
#### METERIN (Sequential File)
- **Dataset**: OZA265.GRP2.ELE.METER.PS
- **Format**: Sequential (PS)
- **Purpose**: Input meter readings data
- **Access**: Shared read access

#### CUSTKSDS (VSAM File)
- **Dataset**: OZA265.GRP2.CUST.KSDS
- **Format**: VSAM KSDS (Keyed Sequential)
- **Purpose**: Customer master data
- **Access**: Shared read access

### Output Files
#### METERERR (Error File)
- **Dataset**: SYSOUT*
- **Format**: Printer output
- **Purpose**: Error record output
- **Access**: System output

## Database Connectivity

### DB2 Subsystem Connection
```jcl
DSN SYSTEM(DBAG)
```

#### Connection Parameters:
- **Subsystem**: DBAG
- **Purpose**: Connect to DB2 database
- **Authentication**: Use job submitter credentials

### Application Plan
```jcl
PLAN(OZA267A)
```

#### Plan Details:
- **Plan Name**: OZA267A
- **Purpose**: Contains SQL execution plans
- **Binding**: Must be bound before execution
- **Authority**: User must have EXECUTE authority

### Load Module Library
```jcl
LIBRARY('OZA265.TRGA5.DB2.LOADLIB')
```

#### Library Specification:
- **Dataset**: OZA265.TRGA5.DB2.LOADLIB
- **Purpose**: Contains compiled COBOL programs
- **Access**: Must be accessible during execution

## Program Configuration

### Target Program
```jcl
RUN PROGRAM(MTR002)
```

#### Program Details:
- **Program Name**: MTR002
- **Type**: COBOL DB2 program
- **Function**: Meter data processing
- **Requirements**: Must be compiled and bound

### Execution Parameters
- **Program**: MTR002 (meter processing)
- **Plan**: OZA267A (application plan)
- **Library**: OZA265.TRGA5.DB2.LOADLIB
- **Files**: METERIN, CUSTKSDS, METERERR

## Usage Instructions

### 1. Prerequisites
- **Program Compiled**: MTR002 must be compiled
- **Plan Bound**: OZA267A must be bound
- **Files Available**: Input files must exist
- **Libraries Accessible**: Runtime libraries must be available

### 2. Configuration
- **Update Job Name**: Replace OZA265 with actual user ID
- **Verify Datasets**: Ensure all input datasets exist
- **Check Plan**: Confirm application plan is bound
- **Test Access**: Verify library and file permissions

### 3. Execution
- **Submit Job**: Submit to appropriate job class
- **Monitor Progress**: Check job execution status
- **Review Output**: Examine execution results
- **Handle Errors**: Address any execution errors

### 4. Post-Execution
- **Check Results**: Review program output
- **Analyze Errors**: Investigate any errors
- **Archive Output**: Save important execution results
- **Update Statistics**: Record execution statistics

## Error Handling

### Common Execution Errors
1. **Program Not Found**: Verify program exists in load library
2. **Plan Not Found**: Check application plan binding
3. **File Not Found**: Ensure input datasets exist
4. **DB2 Connection Failed**: Check DB2 subsystem status
5. **Authorization Error**: Verify user permissions

### Troubleshooting Steps
1. **Check SYSOUT**: Review job execution log
2. **Verify Libraries**: Ensure all libraries are accessible
3. **Test DB2**: Confirm DB2 subsystem is active
4. **Check Files**: Validate input file availability
5. **Review Permissions**: Verify user has required authorities

### Error Analysis
- **Return Codes**: Analyze program return codes
- **SQL Codes**: Check SQL error codes
- **File Status**: Review file status codes
- **System Messages**: Examine system error messages

## Performance Considerations

### Execution Optimization
- **Region Size**: Ensure adequate region allocation
- **Buffer Size**: Optimize file buffer sizes
- **Database Buffers**: Configure appropriate DB2 buffers
- **I/O Operations**: Minimize unnecessary I/O

### Resource Management
- **Memory Usage**: Monitor program memory consumption
- **CPU Usage**: Optimize program CPU utilization
- **I/O Operations**: Efficient file access patterns
- **Database Access**: Optimize SQL statement execution

## Security Considerations

### Access Requirements
- **Program Execution**: EXECUTE authority on program
- **Plan Execution**: EXECUTE authority on application plan
- **File Access**: READ access to input files
- **Database Access**: Appropriate database privileges

### Best Practices
- **User ID Management**: Replace OZA265 with actual user ID
- **Dataset Security**: Implement proper dataset permissions
- **Audit Trail**: Maintain execution history
- **Error Handling**: Implement comprehensive error handling

## Monitoring and Maintenance

### Execution Monitoring
- **Job Status**: Monitor job execution progress
- **Resource Usage**: Track system resource consumption
- **Database Performance**: Monitor database operation efficiency
- **Error Rates**: Track error frequency and types

### Regular Maintenance
- **Log Review**: Regularly review execution logs
- **Performance Analysis**: Analyze execution performance
- **File Cleanup**: Remove obsolete output files
- **Library Maintenance**: Update load modules as needed

## Integration with Development Process

### Development Workflow
1. **Program Development**: Write and compile COBOL programs
2. **Plan Binding**: Create application plans
3. **Testing**: Execute programs using CBLDBRUN
4. **Production**: Deploy to production environment

### Quality Assurance
- **Unit Testing**: Test individual program components
- **Integration Testing**: Test program with databases and files
- **Performance Testing**: Evaluate execution performance
- **Error Testing**: Verify error handling procedures

## Sample Execution Scenarios

### Successful Execution
```
//SYSOUT:
MTR002 EXECUTION BEGINS HERE
METER GENERATION PROGRAM
----------------------------------------
CUSTOMER KSDS OPENED ..............
METER INPUT FILE OPENED ...........
METER ERROR FILE IS OPENED ..........
----------------------------------------
METER INSERTED MTR-2024-C001
----------------------------------------
INPUT RECORDS PROCESSED  1000
OUTPUT RECORDS WRITTEN   995
DUPLICATE KEY RETRIES     5
ERROR RECORDS            0
----------------------------------------
```

### Error Scenario
```
//SYSOUT:
ERROR OPENING CUSTOMER MASTER KSDS
FILE STAT  35
```

## Related Files
- **MTR002**: Program being executed
- **CBLDBCMP**: Program compilation JCL
- **CBLDBBND**: Program binding JCL
- **OZA267A**: Application plan
- **METER.PS**: Input meter data file
- **CUST.KSDS**: Customer master file
