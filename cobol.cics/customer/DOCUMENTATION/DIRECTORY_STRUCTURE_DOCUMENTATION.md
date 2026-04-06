# Directory Structure - CICS Customer System

## Purpose
Documentation of the directory organization for the CICS Customer System, showing the relationship between programs, maps, and support files.

## Directory Overview

```
cobol.cics/customer/
├── CODE/                    # COBOL program source files
├── MAP/                     # BMS map definitions
├── DOCUMENTATION/           # Line-by-line documentation
├── CICS_SYSTEM_DOCUMENTATION.md  # System overview
└── struct                  # Directory structure info
```

## CODE Directory

### Purpose
Contains all COBOL program source files for the CICS Customer System.

### Structure
```
CODE/
├── ECSTC030            # Customer Create program
├── ECSTR040            # Customer Read program
├── ECSTU050            # Customer Update program
├── EMNUO010            # Main Menu program
├── EMNUO020            # Sub Menu program
├── CBLSCMP             # Compilation JCL
└── CICSOZA             # Additional CICS utilities
```

### File Descriptions

#### ECSTC030 - Customer Create
- **Purpose**: Creates new customer records in KSDS file
- **Transaction ID**: EB01
- **Map Used**: eb01msd
- **Key Features**:
  - Two-stage process (input → create)
  - Comprehensive error handling
  - Field validation
  - VSAM WRITE operations

#### ECSTR040 - Customer Read
- **Purpose**: Reads and displays existing customer records
- **Transaction ID**: EB04
- **Map Used**: eb02msd
- **Key Features**:
  - Single-stage process (input → read → display)
  - Read-only data display
  - Error handling for read operations
  - VSAM READ operations

#### ECSTU050 - Customer Update
- **Purpose**: Updates existing customer records
- **Transaction ID**: EB05
- **Map Used**: eb05msd
- **Key Features**:
  - Three-stage process (ID input → read → update)
  - Field-level updates
  - Side-by-side comparison
  - VSAM REWRITE operations

#### EMNUO010 - Main Menu
- **Purpose**: Main menu system for navigation
- **Transaction ID**: EMNU
- **Map Used**: None (uses SEND TEXT)
- **Key Features**:
  - Text-based menu interface
  - Navigation to all customer functions
  - Simple and efficient design

#### EMNUO020 - Sub Menu
- **Purpose**: Secondary menu for additional options
- **Transaction ID**: EMNU2
- **Map Used**: None (uses SEND TEXT)
- **Key Features**:
  - Placeholder for future development
  - Reports and utilities options
  - Return to main menu

#### CBLSCMP - Compilation JCL
- **Purpose**: JCL for compiling COBOL CICS programs
- **Format**: Job Control Language
- **Key Features**:
  - Symbolic parameters for program names
  - CICS compilation procedure (PRCCCSCB)
  - Linkage editor integration

#### CICSOZA - CICS Utilities
- **Purpose**: Additional CICS support utilities
- **Format**: Varies (JCL, utilities, etc.)
- **Key Features**:
  - System maintenance tools
  - Administrative functions
  - Support utilities

## MAP Directory

### Purpose
Contains all BMS (Basic Mapping Support) map definitions for the CICS Customer System.

### Structure
```
MAP/
├── eb01msd             # Customer Create map
├── eb02msd             # Customer Read map
├── eb03msd             # Customer Update map (dual version)
├── eb04msd             # Customer Read screen
├── eb05msd             # Customer Update screen
└── CICSMAP             # Map assembly JCL
```

### File Descriptions

#### eb01msd - Customer Create Map
- **Purpose**: Input screen for customer creation
- **Design**: Single-map interface
- **Key Features**:
  - All customer data input fields
  - Clear field labels
  - Message area for feedback
  - Function key instructions

#### eb02msd - Customer Read Map
- **Purpose**: Screen for customer data display
- **Design**: Single-map interface
- **Key Features**:
  - Customer ID input field
  - Protected display fields
  - Read-only data presentation
  - Error message area

#### eb03msd - Customer Update Map (Dual Version)
- **Purpose**: Original dual-map update interface
- **Design**: Two separate maps (MAP1/MAP2)
- **Key Features**:
  - MAP1: Customer ID input
  - MAP2: Side-by-side old/new values
  - Column headers for clarity
  - Complex navigation

#### eb04msd - Customer Read Screen
- **Purpose**: Simplified customer read interface
- **Design**: Single-map interface
- **Key Features**:
  - Identical to eb02msd functionality
  - Consistent naming convention
  - Used by ECSTR040 program
  - Read-only data display

#### eb05msd - Customer Update Screen
- **Purpose**: Modern single-map update interface
- **Design**: Single unified screen
- **Key Features**:
  - Three-column layout (Field | Old | New)
  - Side-by-side comparison
  - Field-level updates
  - Enhanced field sizes

#### CICSMAP - Map Assembly JCL
- **Purpose**: JCL for assembling BMS maps
- **Format**: Job Control Language
- **Key Features**:
  - Symbolic parameters for map names
  - CICS map assembly procedure (PRCMAPCB)
  - Linkage editor integration

## DOCUMENTATION Directory

### Purpose
Contains comprehensive line-by-line documentation for all system components.

### Structure
```
DOCUMENTATION/
├── ECSTC030_DOCUMENTATION.md     # Customer Create program docs
├── ECSTR040_DOCUMENTATION.md     # Customer Read program docs
├── ECSTU050_DOCUMENTATION.md     # Customer Update program docs
├── EMNUO010_DOCUMENTATION.md     # Main Menu program docs
├── EMNUO020_DOCUMENTATION.md     # Sub Menu program docs
├── eb01msd_DOCUMENTATION.md      # Customer Create map docs
├── eb02msd_DOCUMENTATION.md      # Customer Read map docs
├── eb03msd_DOCUMENTATION.md      # Customer Update map (dual) docs
├── eb04msd_DOCUMENTATION.md      # Customer Read screen docs
├── eb05msd_DOCUMENTATION.md      # Customer Update screen docs
├── CBLSCMP_DOCUMENTATION.md      # Compilation JCL docs
└── CICSMAP_DOCUMENTATION.md      # Map assembly JCL docs
```

### Documentation Features

#### Program Documentation
- **Line-by-Line Explanation**: Every significant line explained
- **Data Flow**: How data moves through the program
- **Error Handling**: Comprehensive error management
- **Business Logic**: Program purpose and functionality
- **Integration**: How programs work together

#### Map Documentation
- **Field Definitions**: Every field explained with attributes
- **Screen Layout**: Visual representation of map design
- **Generated Names**: CICS-generated field names
- **Usage Patterns**: How maps are used in programs
- **Design Considerations**: Why certain design choices were made

#### System Documentation
- **JCL Procedures**: Detailed JCL explanations
- **Assembly Process**: How maps are assembled
- **Compilation Process**: How programs are compiled
- **Integration**: How components work together
- **Best Practices**: Development and maintenance guidelines

## File Relationships

### Program-Map Relationships
```
ECSTC030 (Create)  ←→ eb01msd (Create Map)
ECSTR040 (Read)    ←→ eb02msd/eb04msd (Read Maps)
ECSTU050 (Update)  ←→ eb03msd/eb05msd (Update Maps)
EMNUO010 (Menu)    ←→ No map (SEND TEXT)
EMNUO020 (Sub Menu) ←→ No map (SEND TEXT)
```

### Compilation Relationships
```
COBOL Programs → CBLSCMP JCL → PRCCCSCB Procedure → Load Module
BMS Maps       → CICSMAP JCL → PRCMAPCB Procedure → Physical Map
```

### Transaction IDs
```
EB01 → ECSTC030 (Customer Create)
EB04 → ECSTR040 (Customer Read)
EB05 → ECSTU050 (Customer Update)
EMNU → EMNUO010 (Main Menu)
EMNU2 → EMNUO020 (Sub Menu)
```

## Data Flow Architecture

### Customer Data Flow
```
User Input → Map → Program → VSAM File → Database
    ↓           ↓        ↓         ↓
  eb01msd   ECSTC030  WRITE   CU01KSDS
  eb02msd   ECSTR040  READ    CU01KSDS
  eb05msd   ECSTU050  READ/REWRITE CU01KSDS
```

### Menu Navigation Flow
```
Main Menu (EMNUO010)
    ↓
├── Customer Create (EB01 → ECSTC030)
├── Customer Read (EB04 → ECSTR040)
├── Customer Update (EB05 → ECSTU050)
└── Sub Menu (EMNU2 → EMNUO020)
```

## Development Workflow

### Source Code Management
1. **Development**: Edit source files in CODE/ directory
2. **Compilation**: Use CBLSCMP JCL to compile programs
3. **Map Assembly**: Use CICSMAP JCL to assemble maps
4. **Testing**: Test programs with assembled maps
5. **Documentation**: Update documentation in DOCUMENTATION/

### Deployment Process
1. **Load Modules**: Deploy to OZAADM.CICS.LOADLIB
2. **Physical Maps**: Deploy to CICS regions
3. **Transaction Registration**: Register transaction IDs
4. **Testing**: End-to-end system testing
5. **Documentation**: Update system documentation

## Naming Conventions

### Program Names
- **ECS**: Electricity Customer System
- **T**: Transaction Type (C=Create, R=Read, U=Update)
- **XXX**: Sequence number (030, 040, 050)

### Menu Names
- **EMNU**: Menu program
- **O**: Option type
- **XXX**: Sequence number (010, 020)

### Map Names
- **eb**: Electronic Billing
- **XX**: Program sequence (01, 02, 03, 04, 05)
- **msd**: Map Set Definition

### JCL Names
- **CBLSCMP**: COBOL Compilation
- **CICSMAP**: CICS Map Assembly

## Integration Points

### VSAM Integration
- **CU01KSDS**: Customer KSDS file
- **Operations**: READ, WRITE, REWRITE
- **Key Field**: Customer ID (12 characters)
- **Record Size**: 83 bytes

### CICS Integration
- **Transaction IDs**: EB01, EB04, EB05, EMNU, EMNU2
- **Map Sets**: eb01msd, eb02msd, eb03msd, eb04msd, eb05msd
- **Copybooks**: DFHBMSCA, DFHAID, map definitions
- **Response Codes**: DFHRESP-NORMAL, DFHRESP-NOTFND, etc.

### System Integration
- **Job Control**: JCL procedures for compilation and assembly
- **Load Libraries**: OZAADM.CICS.LOADLIB for programs and maps
- **Source Libraries**: OZA266.ELE.SOURCE.CICS.NEW for programs
- **Map Libraries**: OZA266.ELE.SOURCE.MAP for maps

## Maintenance Considerations

### Regular Maintenance
- **Source Code**: Update programs for business requirements
- **Map Definitions**: Modify maps for UI improvements
- **Documentation**: Keep documentation current
- **JCL Procedures**: Update compilation procedures as needed

### Version Control
- **Source Files**: Track changes in CODE/ and MAP/ directories
- **Documentation**: Version documentation in DOCUMENTATION/
- **Load Modules**: Track deployed versions
- **Testing**: Maintain test environments

### Backup Strategy
- **Source Code**: Regular backups of CODE/ and MAP/
- **Documentation**: Backup documentation files
- **Load Libraries**: Backup production load modules
- **JCL Procedures**: Backup procedure libraries

## Future Enhancements

### Planned Additions
- **Reports Module**: Customer reporting functionality
- **Utilities Module**: System maintenance tools
- **Batch Processing**: Bulk customer operations
- **Web Interface**: Modern web-based access

### Scalability Considerations
- **Additional Maps**: New screens for enhanced functionality
- **Extended Programs**: Additional business logic
- **Integration**: Interface with other systems
- **Performance**: Optimization for high volume usage
