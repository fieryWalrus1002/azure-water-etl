# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hydro-Flow is an Azure data pipeline that ingests USGS streamflow sensor data and processes it through a Medallion Architecture (Bronze → Silver → Gold) on Azure.

**Tech stack:**
- **IaC:** Azure Bicep (`infra/`)
- **Orchestrator:** Azure Data Factory (ADF)
- **Compute:** Azure Functions (Python 3.11)
- **Storage:** Azure Data Lake Storage Gen2 (ADLS), with containers `bronze`, `silver`, `gold`
- **Query:** Azure Synapse Serverless SQL
- **Observability:** Azure Monitor / Log Analytics

## Bicep Deployment

```bash
# Deploy infrastructure to an existing resource group
az deployment group create \
  --resource-group <rg-name> \
  --template-file infra/main.bicep

# Validate without deploying
az deployment group validate \
  --resource-group <rg-name> \
  --template-file infra/main.bicep

# Preview changes (what-if)
az deployment group what-if \
  --resource-group <rg-name> \
  --template-file infra/main.bicep
```

## Architecture

### Bicep Structure

`infra/main.bicep` is the entry point (scoped to `resourceGroup`). It provisions:
1. ADLS Gen2 storage account with `bronze`, `silver`, and `gold` blob containers
2. Azure Data Factory with a System-Assigned Managed Identity

It composes two modules:
- `infra/modules/rbac.bicep` — grants ADF's Managed Identity access to the storage account; also grants a developer/user principal access for local EDA
- `infra/modules/adf_factory.bicep` — ADF linked services and pipeline definitions

`infra/modules/compute.bicep` — Azure Functions hosting plan + Function App (currently commented out; in progress).

`infra/example.bicep` — reference implementation for a Flex Consumption Function App with User-Assigned Managed Identity; use this as a pattern guide when implementing `compute.bicep`.

### Security Model

All resource-to-resource communication uses Managed Identities — no hardcoded keys or connection strings. The ADF System-Assigned Identity is granted RBAC roles on ADLS. The Function App will use a User-Assigned Identity (see `example.bicep`).

### Data Flow (planned)

```
USGS API → ADF Copy Activity → bronze/ (raw JSON)
                             → Azure Function → silver/ (Parquet, cleaned)
                                              → silver/ row count verified via Synapse SQL
                                              → gold/ (daily aggregates)
```

## Testing

Per `specs/testing.md`:
- **Unit:** `pytest` with `unittest.mock` for Azure Blob Storage calls
- **Integration:** Manual ADF "Debug" run; verify files appear in `bronze/` (`.json`) and `silver/` (`.parquet`)
- **Data integrity:** Synapse Serverless SQL `openrowset` row-count comparison between Bronze and Silver

```bash
# Run Python unit tests (once implemented)
pytest

# Run a single test file
pytest tests/test_transform.py
```

## Key Requirements

From `specs/requirements.md`:
- 100% IaC — no manual portal clicks
- Managed Identities only — no hardcoded credentials
- Python transformation must include a schema validation ("Schema Check") step
- Pipeline logs success/failure to Azure Monitor
