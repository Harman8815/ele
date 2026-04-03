# CICS Electricity Board System - Documentation Specification

## Table of Contents
1. [System Overview](#system-overview)
2. [File Summary Table](#file-summary-table)
3. [Detailed File Analysis](#detailed-file-analysis)
4. [System Flow and Navigation](#system-flow-and-navigation)
5. [Compilation and Deployment](#compilation-and-deployment)
6. [VSAM Data Structure](#vsam-data-structure)
7. [Integration and Testing](#integration-and-testing)

---

## System Overview

The CICS Electricity Board System is a mainframe-based customer management application built using IBM CICS (Customer Information Control System) with COBOL programming language. The system provides CRUD (Create, Read, Update) operations for customer management in an electricity board context.

### Key Components:
- **BMS Maps**: Screen definitions for user interface
- **COBOL Programs**: Business logic and CICS commands
- **VSAM Files**: Data storage for customer records
- **JCL Scripts**: Compilation and deployment procedures

---

## File Summary Table

| File Name | Type | Purpose | Transaction ID |
|-----------|------|---------|----------------|
| **cblcsmp** | JCL | Sample compilation script for COBOL+CICS programs | N/A |
| **cicsmap** | JCL | Sample compilation script for CICS maps | N/A |
| **eb01msd** | BMS Map | Main menu screen layout | EB01 |
| **emnuo010** | COBOL Program | Main menu controller program | EB01 |
| **eb02msd** | BMS Map | Customer submenu screen layout | EB02 |
| **eb02cstm** | COBOL Program | Customer menu controller | EB02 |
| **eb03msd** | BMS Map | Customer creation screen layout | EB03 |
| **eb03cstc** | COBOL Program | Customer creation logic | EB03 |
| **eb04msd** | BMS Map | Customer read/inquiry screen layout | EB04 |
| **eb04cstr** | COBOL Program | Customer read/inquiry logic | EB04 |
| **eb05msd** | BMS Map | Customer update screen layout (dual maps) | EB05 |
| **eb05cstu** | COBOL Program | Customer update logic | EB05 |
| **struct** | Documentation | System structure overview | N/A |

---

## Detailed File Analysis

### 1. JCL Compilation Scripts

#### **cblcsmp** - COBOL Program Compilation
- **Purpose**: Compiles COBOL-CICS programs
- **Key Features**:
  - Uses `PRCCCSCB` procedure for compilation
  - Sets program name via `CICSPGM` variable
  - Outputs to `OZAADM.CICS.LOADLIB`
  - Example compiles `EB01MSD` program

#### **cicsmap** - BMS Map Compilation
- **Purpose**: Compiles CICS BMS maps
- **Key Features**:
  - Uses `PRCCCMAP` procedure for map compilation
  - Sets mapset name via `MAPSET` variable
  - Outputs to same load library
  - Example compiles `EB01MSD` mapset

### 2. Main Menu System

#### **eb01msd** - Main Menu BMS Map
- **Screen Layout**: 24x80 terminal screen
- **Fields**:
  - Title: "Electricity Board of Trivandrum"
  - Options: Customer (1), Meter (2), Exit (3)
  - Input field for user choice
  - Message area for feedback
- **Navigation**: Single choice selection

#### **emnuo010** - Main Menu Controller
- **Purpose**: Controls main menu flow and navigation
- **Key Logic**:
  - Handles initial screen display
  - Processes user input (1, 2, 3)
  - Routes to appropriate subsystems:
    - `EB02CUSTM` for Customer operations
    - `EB06METERM` for Meter operations (not implemented)
    - Exit for system termination
- **Error Handling**: Invalid option messages, key press validation

### 3. Customer Submenu System

#### **eb02msd** - Customer Menu BMS Map
- **Screen Layout**: Customer operation selection
- **Options**:
  - C - Create Customer
  - R - Read Customer  
  - U - Update Customer
  - 3 - Exit to Main Menu
- **Input**: Single character choice

#### **eb02cstm** - Customer Menu Controller
- **Purpose**: Routes customer operations
- **Navigation Logic**:
  - 'C' → `EB03CUSTC` (Create)
  - 'R' → `EB04CUSTR` (Read)
  - 'U' → `EB05CUSTU` (Update)
  - '3' → `EB01MAIN` (Main Menu)
- **Error Handling**: Invalid option validation

### 4. Customer Creation System

#### **eb03msd** - Customer Creation BMS Map
- **Input Fields**:
  - First Name (15 chars)
  - Last Name (15 chars)
  - Area Code (10 chars)
  - Address (30 chars)
  - City (15 chars)
- **Output Fields**:
  - Generated Customer ID (12 chars)
  - Status messages
- **Validation**: All fields mandatory

#### **eb03cstc** - Customer Creation Logic
- **Purpose**: Creates new customer records
- **Key Features**:
  - **ID Generation**: 
    - Format: C[first2][last2][timestamp]
    - Example: CJOHNDO123456
  - **Validation**: Mandatory field checking
  - **VSAM Operations**: 
    - WRITE to `OZA266.ELE.CUST.KSDS.FILE`
    - Duplicate record handling
  - **Error Handling**: 
    - Retry on duplicate ID
    - Error message display

### 5. Customer Read System

#### **eb04msd** - Customer Read BMS Map
- **Input Fields**:
  - Customer ID (12 chars) for search
- **Output Fields**:
  - All customer details (read-only)
  - First Name, Last Name, Area Code, Address, City, Units
- **Message Area**: Status feedback

#### **eb04cstr** - Customer Read Logic
- **Purpose**: Retrieves and displays customer records
- **Operations**:
  - READ from VSAM file using Customer ID as key
  - Display all customer fields
- **Error Handling**:
  - Customer not found message
  - Read error handling

### 6. Customer Update System

#### **eb05msd** - Customer Update BMS Maps (Dual Map Design)
- **Map1**: Customer ID input screen
  - Input: Customer ID (12 chars)
  - Message area for status
- **Map2**: Update screen with side-by-side comparison
  - Left column: Field labels
  - Middle column: Existing values (read-only)
  - Right column: New values (editable)
  - Units field is protected (non-updatable)

#### **eb05cstu** - Customer Update Logic
- **Two-Stage Process**:
  1. **Stage 1**: Customer ID input and record retrieval
  2. **Stage 2**: Display existing data and collect new values
- **Update Logic**:
  - Partial updates supported (only non-empty fields updated)
  - Units field cannot be modified
  - REWRITE operation to VSAM file
- **State Management**: Uses COMMAREA to track stages

---

## System Flow and Navigation

### Complete User Flow

```
START
  ↓
EB01 (Main Menu)
  ├── 1 → EB02 (Customer Menu)
  │     ├── C → EB03 (Create Customer)
  │     │     └── Return to EB02
  │     ├── R → EB04 (Read Customer)
  │     │     └── Return to EB02
  │     ├── U → EB05 (Update Customer)
  │     │     ├── Stage 1: ID Input
  │     │     ├── Stage 2: Update Fields
  │     │     └── Return to EB02
  │     └── 3 → Return to EB01
  ├── 2 → EB06 (Meter Menu) [Not Implemented]
  └── 3 → EXIT
```

### Transaction IDs and Program Mapping

| Transaction | Program | Mapset | Function |
|-------------|---------|--------|----------|
| EB01 | EMNUO010 | EB01MSD | Main Menu |
| EB02 | EB02CUSTM | EB02MSD | Customer Menu |
| EB03 | EB03CUSTC | EB03MSD | Create Customer |
| EB04 | EB04CUSTR | EB04MSD | Read Customer |
| EB05 | EB05CUSTU | EB05MSD | Update Customer |

---

## Compilation and Deployment

### Prerequisites
1. All COBOL programs must compile with CC=0
2. All BMS maps must be compiled successfully
3. VSAM files must be properly defined and allocated
4. CICS region must be configured with proper resources

### Compilation Steps

#### Step 1: Compile BMS Maps
```bash
// Use cicsmap JCL template
// Update MAPSET parameter for each mapset:
// - EB01MSD for main menu
// - EB02MSD for customer menu
// - EB03MSD for create customer
// - EB04MSD for read customer
// - EB05MSD for update customer
```

#### Step 2: Compile COBOL Programs
```bash
// Use cblcsmp JCL template
// Update CICSPGM parameter for each program:
// - EMNUO010 for main menu controller
// - EB02CUSTM for customer menu
// - EB03CUSTC for create customer
// - EB04CUSTR for read customer
// - EB05CUSTU for update customer
```

#### Step 3: CICS Resource Definition
```bash
// Define transactions in CICS:
// - EB01 through EB05
// Define programs in CICS
// Define mapsets in CICS
// Define VSAM files in CICS
```

---

## VSAM Data Structure

### Customer File: OZA266.ELE.CUST.KSDS.FILE

#### Record Layout (87 bytes total)
```
01 CUSTOMER-RECORD.
   05 CUST-ID               PIC X(12).  *> Primary Key
   05 FIRST-NAME            PIC X(15).
   05 LAST-NAME             PIC X(15).
   05 AREA-CODE             PIC X(10).
   05 ADDRESS               PIC X(30).
   05 CITY                  PIC X(15).
   05 UNITS                 PIC 9(05).
```

#### Key Structure
- **Primary Key**: CUST-ID (12 bytes)
- **Key Format**: C[first2][last2][timestamp]
- **Example**: CJOHNDO123456

#### VSAM Operations Used
- **WRITE**: Create new records (EB03CUSTC)
- **READ**: Retrieve records (EB04CUSTR, EB05CUSTU)
- **REWRITE**: Update existing records (EB05CUSTU)

---

## Integration and Testing

### System Integration Steps

#### 1. Environment Setup
- Verify CICS region is active
- Ensure all programs are compiled and loaded
- Confirm VSAM files are allocated and available
- Test transaction definitions

#### 2. Component Testing
- Test each program individually
- Verify map displays correctly
- Validate input/output field mappings
- Test error conditions

#### 3. Integration Testing
- Test complete navigation flow
- Verify data persistence across operations
- Test concurrent user scenarios
- Validate error handling paths

#### 4. End-to-End Testing Scenario
```
1. Start EB01 transaction
2. Select option 1 (Customer)
3. Select C (Create Customer)
4. Enter new customer details
5. Verify customer ID generation
6. Return to customer menu
7. Select R (Read Customer)
8. Enter created customer ID
9. Verify all details displayed
10. Return to customer menu
11. Select U (Update Customer)
12. Enter customer ID
13. Modify some fields
14. Verify update success
15. Return to main menu
16. Select 3 (Exit)
```

### Common Issues and Solutions

#### Compilation Issues
- **CC != 0**: Check syntax, copybooks, and compile options
- **Missing Copybooks**: Verify DFHBMSCA, DFHAID availability
- **Map Compilation**: Verify BMS syntax and field definitions

#### Runtime Issues
- **Transaction Not Found**: Verify CICS resource definitions
- **Map Not Found**: Check mapset compilation and installation
- **VSAM Errors**: Verify file allocation and permissions

#### Data Issues
- **Duplicate Customer IDs**: Check ID generation logic
- **Record Not Found**: Verify key format and VSAM file contents
- **Update Failures**: Check record locking and access rights

---

## Conclusion

This CICS Electricity Board System provides a complete customer management solution with robust error handling, data validation, and user-friendly navigation. The modular design allows for easy maintenance and future enhancements.

The system is ready for deployment once all components are compiled with CC=0 and properly integrated into the CICS environment. Regular testing and monitoring should be performed to ensure system reliability and performance.
