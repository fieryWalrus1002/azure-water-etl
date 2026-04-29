# specs/requirements.md

## Project: Hydro-Flow Data Pipeline
**Objective:** Ingest, transform, and govern USGS streamflow sensor data using a Medallion Architecture on Azure platform.

## Success Criteria
1. **Infrastructure as Code (IaC):** 100% of resources deployed via Azure Bicep. No manual portal clicks.
2. **Security:** Use Managed Identities (Service Principals) for all resource-to-resource communication. No hardcoded API keys or connection strings.
3. **Data Architecture:** - **Bronze:** Raw JSON responses from USGS API.
    - **Silver:** Cleaned, flattened Parquet files with standardized timestamps.
    - **Gold:** Aggregated daily averages for streamflow.
4. **Data Quality:** Implement a "Schema Check" step in the Python transformation.
5. **Observability:** Pipeline must log success/failure to Azure Monitor (Log Analytics).

## Technical Stack
- **Orchestrator:** Azure Data Factory (ADF).
- **Compute:** Azure Functions (Python 3.11) for transformation.
- **Storage:** Azure Data Lake Storage (ADLS) Gen2.
- **Query Layer:** Azure Synapse Serverless SQL.