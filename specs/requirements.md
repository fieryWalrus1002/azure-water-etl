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

## Status (as of 2026-04-29)

| Requirement | Status | Notes |
|---|---|---|
| 100% IaC | In progress | Synapse SQL not yet in Bicep |
| Managed Identities | In progress | ADF→Function App auth method not yet specified in linked service |
| Bronze / Silver layers | Done | Gold aggregation pipeline step missing |
| Schema Check (Python) | Not started | No Function App code yet |
| Azure Monitor / Log Analytics | Not started | AppInsights deployed but not workspace-based; no Log Analytics resource |

## Technical Stack
- **Orchestrator:** Azure Data Factory (ADF).
- **Compute:** Azure Functions (Python 3.11) for transformation.
- **Storage:** Azure Data Lake Storage (ADLS) Gen2.
- **Query Layer:** Azure Synapse Serverless SQL.