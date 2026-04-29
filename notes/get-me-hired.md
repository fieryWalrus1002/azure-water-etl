# Operation: Prove I know how to do this

We want to build an azure bicep-deployed data pipeline using some of these sources of data as a portfolio project to show skills in the following fields:

1. Design, create and maintain data pipelines to collect, clean, transform, and load data from various sources, including sensor data, historical records, and geo-spatial information to facilitate data warehousing.
2. Participate in the design of and execute the creation and management of data warehouses, data lakes, and databases to ensure efficient data storage, retrieval, and management.
3. Develop, deploy, execute, and monitor ETL (Extract, Transform, Load) processes to support data analysis, visualization, and machine learning model training.
4. Design and execute testing plans for data pipeline and data warehousing implementation eﬀorts.
5. Implement processes for improving data quality and managing data governance for enhanced reliability and accessibility.
6. Collaborate with IT infrastructure and cybersecurity teams to implement and operate data pipelines within approved data infrastructure, performance, and security guidelines.
7. Design and execute processing tasks using Python and maintain up-to-date understanding of big data processing frameworks.
8. Perform regular data audits and updates to ensure high level of data accuracy and integrity.

## Potential data sources

We don't need to pull all of these. Lets start with one, and can add more later.

### USGS Water Data APIs (NWIS)

Description: These modernized APIs provide real-time and historical sensor data from thousands of monitoring sites across the U.S..

Data Types: Streamflow, groundwater levels, and water temperature.

Integration: Can be ingested via Azure Data Factory using the HTTP connector to pull data directly into an Azure Data Lake Storage (ADLS) Gen2 bronze layer.

### EPA Water Quality Portal (WQP)

Description: This portal integrates data from over 400 state, federal, and tribal agencies, making it the largest source of water-quality monitoring data in the nation.

Data Types: Analytical results for millions of quality-checked water samples, including chemical and biological parameters.

Integration: Provides standard web services that return data in formats like CSV or JSON, which are native to Azure Data Factory ingestion.

### NOAA National Water Model (NWM)

Description: simulates and forecasts streamflow over the entire continental U.S..Data Types: Forecast high water probabilities and reach-level streamflow.

Azure Specifics: Large subsets of NWM data are already hosted in Azure Blob Storage (East US region), allowing for direct, high-speed ingestion into Azure-based pipelines. [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13] 

## Tentative project architecture

Please help me narrow down, or suggest another option from these!

- Medallion Architecture: Ingest raw water quality data from the EPA WQP API into a Bronze layer (ADLS Gen2), use something (NOT Azure Databricks, they don't use it) to clean and transform it into a Silver layer, and finally aggregate it into a Gold layer for visualization in Power BI. We will not do the visualization step.
- IoT-Style Real-time Monitoring: Use Azure Data Factory to periodically poll the USGS real-time sensor API for streamflow data, simulating an IoT data pipeline.