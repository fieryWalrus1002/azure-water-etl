# specs/testing.md

## Test Plan: Hydro-Flow Pipeline

Establish a test plan for our mvp data pipeline.

### 1. Unit Testing (Python)
- **Tool:** `pytest`
- **Criteria:** The transformation function must handle empty JSON responses from USGS without crashing.
- **Mocking:** Use `unittest.mock` to simulate Azure Blob Storage calls.

### 2. Integration Testing (ADF)
- **Trigger:** Manual "Debug" run in Azure Data Factory.
- **Success Condition:**
    - File exists in `bronze/` as `.json`.
    - File exists in `silver/` as `.parquet`.
    - ADF Pipeline Monitor shows "Succeeded" status.

### 3. Data Integrity Audit
- **Query:** Use Azure Synapse Serverless SQL to run:
  `SELECT COUNT(*) FROM openrowset(...)`
- **Verification:** Compare row counts between the Raw JSON and the Silver Parquet.
