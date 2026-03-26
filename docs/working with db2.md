# DB2 Setup and Data Population (Capstone Guide)

## 1. Dataset Creation

Before working with DB2 in the capstone project, create the following datasets:

### Required Datasets

1. `oza265.trga5.dclgen`
   - LRECL: 80  
   - Space: Tracks (20,20)  
   - BLKSIZE: 24000  

2. `oza265.trga5.db2.loadlib`
   - Type: U (Undefined)  
   - LRECL: 80  
   - Space: Tracks (25,25)  
   - BLKSIZE: 24000  

3. `oza265.trga5.dbrmlib`
   - LRECL: 80  
   - Space: Tracks (10,10)  
   - BLKSIZE: 24000  

4. `oza265.trga.dclgen`
   - LRECL: 80  
   - Space: Tracks (20,20)  
   - BLKSIZE: 24000  

---

## 2. Using SPUFI (SQL Processing)

### Steps to Access SPUFI

1. Go to option `9`  
2. Select `SP`  
3. Choose option `1` (SPUFI)  

### Input in SPUFI

- Enter dataset names in **single quotes**
- Provide:
  - Input dataset (SQL statements)
  - Output dataset (results)

---

## 3. Important Note

- Sometimes SQL execution may fail with **access errors**
- In such cases:
  - Ask for:
    - Database name (DBNAME)
    - Tablespace name
  - Add them explicitly in your SQL statements

---

## 4. Table Creation and Data Insertion

- Create tables for all required datasets
- Populate data using one of the following methods

---

# Data Population Methods

## Method 1: Using DB2 LOAD Utility (Recommended)

### Overview

This is the fastest and most efficient method for bulk data insertion.

### Step 1: Convert PDS to Sequential Dataset

- DB2 utilities cannot read PDS directly
- Convert PDS member to a PS (Sequential Dataset)

#### Tools:
- IEBGENER
- ISPF Option 3.3 (Copy utility)

```

PDS(Member) → PS Dataset

```

---

### Step 2: Prepare Data Format

Ensure:

- Record format is Fixed Block (FB)
- Field lengths match DB2 table columns
- Field order matches table definition

---

### Step 3: Execute DB2 LOAD

Conceptual syntax:

```

LOAD DATA  
INFILE your.ps.dataset  
INTO TABLE your_table

```

### What Happens Internally

- DB2 reads the input dataset
- Maps file fields to table columns
- Inserts data in bulk mode

---

## Method 2: Using COBOL Program with INSERT

### Overview

Used when data requires validation or transformation.

### Flow

```

PDS → COBOL Program → DB2 INSERT

```

### Steps

1. Read records from PDS member  
2. Parse individual fields  
3. Execute SQL INSERT:

```

EXEC SQL  
INSERT INTO table_name ...  
END-EXEC

```

4. Perform periodic commits to manage transactions  

### Use Case

- Data validation required  
- Data transformation needed  

---

## Method 3: Using DSNUTILB (JCL Utility)

### Overview

This is the production-level approach for executing LOAD operations.

### Flow

```

PS Dataset → DSNUTILB → DB2 Table

```

### Notes

- DSNUTILB executes DB2 utilities via JCL
- Commonly used in enterprise batch jobs

---

## 5. Key Concepts

### PDS vs PS

- PDS cannot be directly processed by DB2 utilities
- Always convert:

```

PDS → PS Dataset → DB2

```

---

### Data Type Mapping

| File Format | DB2 Type |
|------------|---------|
| PIC X      | CHAR / VARCHAR |
| PIC 9      | INTEGER / DECIMAL |
| PIC 9V99   | DECIMAL |

---

### Data Consistency Rules

- Field length must match exactly  
- Incorrect alignment causes errors  
- Spaces are counted as valid data  

---

## 6. Summary

1. Create required datasets  
2. Use SPUFI for SQL execution  
3. Create DB2 tables  
4. Convert PDS to PS dataset  
5. Load data using:
   - LOAD utility (preferred)
   - COBOL INSERT (if logic needed)
   - DSNUTILB (production jobs)

---
