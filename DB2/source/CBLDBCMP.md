# CBLDBCMP - COBOL DB2 Program Compilation JCL

## Overview
CBLDBCMP is a JCL (Job Control Language) script used to precompile, compile, and link COBOL programs that contain embedded SQL statements for DB2 database access. This script handles the complete build process for DB2-enabled COBOL applications.

## Purpose
- **DB2 Precompilation**: Convert embedded SQL to DB2 calls
- **COBOL Compilation**: Compile preprocessed COBOL source code
- **Link Editing**: Create executable load modules
- **DBRM Generation**: Generate Database Request Modules

## Job Configuration
```jcl
//OZA265PL JOB OZA,OZA,MSGLEVEL=(1,1),
//             CLASS=A,MSGCLASS=A,NOTIFY=&SYSUID,REGION=0M
//   SET DB2PGM=MTR002
```

### Job Parameters
- **JOB NAME**: OZA265PL
- **USER**: OZA (replace with actual user ID)
- **CLASS**: A (production job class)
- **MSGLEVEL**: (1,1) - detailed job logging
- **REGION**: 0M - unlimited region size
- **DB2PGM**: MTR002 (target program name)

## Key Components

### 1. Procedure Library
```jcl
//JOBPROC  JCLLIB ORDER=OZA265.USER.PROCLIB
```

#### Procedure Library:
- **Dataset**: OZA265.USER.PROCLIB
- **Purpose**: Contains cataloged procedures
- **Access**: Ordered search for procedures

### 2. DB2 COBOL Compilation
```jcl
//DB2ICOB  EXEC PRCDBCOB,
//    COPYLIB='OZA265.CHARGE.TRGA5.CPYBK',
//    DCLGLIB='OZA265.GRP2.ELE.DCLGEN',
//    DBRMLIB='OZA265.TRGA5.DBRMLIB',
//    LOADLIB='OZA265.TRGA5.DB2.LOADLIB',
//    MEM=MTR002,
//    LMOD=MTR002
```

#### Compilation Parameters:
- **PROCEDURE**: PRCDBCOB (DB2 COBOL compilation procedure)
- **COPYLIB**: OZA265.CHARGE.TRGA5.CPYBK (copybook library)
- **DCLGLIB**: OZA265.GRP2.ELE.DCLGEN (DCLGEN library)
- **DBRMLIB**: OZA265.TRGA5.DBRMLIB (DBRM library)
- **LOADLIB**: OZA265.TRGA5.DB2.LOADLIB (load module library)
- **MEM**: MTR002 (source member name)
- **LMOD**: MTR002 (load module name)

### 3. Source Code Input
```jcl
//SYSIN DD  DSN=OZA265.GRP2.ELE.DB2.SOURCE(&DB2PGM),DISP=SHR
```

#### Source Input:
- **Dataset**: OZA265.GRP2.ELE.DB2.SOURCE
- **Member**: &DB2PGM (MTR002)
- **Access**: Shared read access

### 4. Link Editor Options
```jcl
//LKED.SYSIN   DD *
       INCLUDE SYSLIB(DSNELI)
/*
```

#### Link Editor Commands:
- **INCLUDE**: SYSLIB(DSNELI) - Include DB2 interface module
- **DSNELI**: DB2 Language Interface module

## Compilation Process

### 1. Precompilation Phase
- **Purpose**: Convert embedded SQL to DB2 calls
- **Input**: COBOL source with SQL statements
- **Output**: Modified COBOL source + DBRM
- **Tool**: DB2 precompiler (DSNHPC)

### 2. Compilation Phase
- **Purpose**: Compile preprocessed COBOL code
- **Input**: Modified COBOL source
- **Output**: Object code
- **Tool**: COBOL compiler (IGYCRCTL)

### 3. Link Editing Phase
- **Purpose**: Create executable load module
- **Input**: Object code + DB2 interface modules
- **Output**: Load module
- **Tool**: Linkage editor (IEWL)

## Library Dependencies

### Input Libraries
1. **Source Library**: Contains COBOL source code
2. **Copybook Library**: Contains COPY statements
3. **DCLGEN Library**: Contains table declarations
4. **Procedure Library**: Contains compilation procedures

### Output Libraries
1. **DBRM Library**: Contains Database Request Modules
2. **Load Module Library**: Contains executable programs

### Runtime Libraries
1. **DB2 Runtime**: Required for DB2 operations
2. **LE/370 Runtime**: Required for COBOL execution

## File Structure

### Source Code Organization
```
OZA265.GRP2.ELE.DB2.SOURCE/
    MTR002        - Meter processing program
    CUST004       - Customer processing program
    (other DB2 programs)
```

### Copybook Organization
```
OZA265.CHARGE.TRGA5.CPYBK/
    (copybook members)
```

### DCLGEN Organization
```
OZA265.GRP2.ELE.DCLGEN/
    CUSTODCL      - Customer table DCLGEN
    MTRODCL       - Meter table DCLGEN
    (other DCLGEN members)
```

## Usage Instructions

### 1. Preparation
- Ensure COBOL source exists in source library
- Verify copybooks and DCLGEN members are available
- Check library permissions and allocations

### 2. Configuration
- Update SET statement with target program name
- Verify library paths and dataset names
- Check procedure library contains required procedures

### 3. Execution
- Submit JCL to appropriate job class
- Monitor compilation progress
- Review output for compilation errors

### 4. Verification
- Check compilation return codes
- Verify load module creation
- Test program execution

## Error Handling

### Common Compilation Errors
1. **Source Not Found**: Verify source dataset and member
2. **Copybook Missing**: Check copybook library allocations
3. **DCLGEN Missing**: Verify DCLGEN library and members
4. **SQL Syntax Errors**: Review embedded SQL statements
5. **Link Errors**: Check library availability

### Troubleshooting Steps
1. **Review SYSOUT**: Check compilation output
2. **Verify Libraries**: Ensure all libraries are accessible
3. **Check Syntax**: Validate COBOL and SQL syntax
4. **Examine Return Codes**: Analyze compilation return codes
5. **Test Dependencies**: Verify required modules are available

## Output Analysis

### Compilation Output
- **Precompiler Messages**: SQL statement processing
- **Compiler Messages**: COBOL syntax checking
- **Linker Messages**: Object code linking

### Return Codes
- **CC 0000**: Successful compilation
- **CC 0004**: Warning messages
- **CC 0008**: Error messages
- **CC 0012**: Severe errors

### Output Files
- **Load Module**: Executable program in LOADLIB
- **DBRM**: Database Request Module in DBRMLIB
- **Listing**: Compilation listing (if requested)

## Performance Considerations

### Compilation Optimization
- **Region Size**: Ensure adequate region allocation
- **Library Access**: Optimize library search order
- **Parallel Compilation**: Consider multiple compilations

### Resource Management
- **Temporary Storage**: Monitor temporary dataset usage
- **CPU Usage**: Optimize compilation time
- **I/O Operations**: Minimize unnecessary I/O

## Security Considerations

### Access Requirements
- **Source Access**: Read access to source libraries
- **Library Access**: Write access to output libraries
- **Procedure Access**: Execute access to procedures

### Best Practices
- **User ID Management**: Replace OZA265 with actual user ID
- **Dataset Security**: Implement proper dataset permissions
- **Audit Trail**: Maintain compilation history

## Maintenance

### Regular Tasks
- **Library Cleanup**: Remove obsolete load modules
- **Backup Procedures**: Backup critical libraries
- **Documentation**: Update compilation procedures

### Updates and Changes
- **Library Changes**: Update dataset references
- **Procedure Updates**: Modify compilation procedures
- **Version Control**: Track source code changes

## Integration with Development Process

### Development Workflow
1. **Code Development**: Write COBOL programs with embedded SQL
2. **Compilation**: Use CBLDBCMP to build programs
3. **Testing**: Execute compiled programs
4. **Deployment**: Move to production environment

### Quality Assurance
- **Code Review**: Review source code before compilation
- **Testing**: Thoroughly test compiled programs
- **Documentation**: Maintain program documentation

## Related Files
- **MTR002**: Target program being compiled
- **CUSTODCL**: Customer table DCLGEN
- **MTRODCL**: Meter table DCLGEN
- **PRCDBCOB**: Compilation procedure
- **CBLDBRUN**: Program execution JCL
- **CBLDBBND**: Program binding JCL
