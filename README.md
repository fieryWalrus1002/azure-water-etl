# azure-water-etl

Azure data pipeline for environmental data, with bicep deployment. Let the data flow like water!

## Create the Resource Group with CLI

I prefer CLI, I'm sure you can do it in the portal instead.

```
az group create \
  --name rg-hydroflow-dev \
  --location westus
```

## Dry Run

With bicep you can perform a quick check of the bicep configuration to find any problems. You can do this in a simple syntax & policy check, or even preview what actual changes will occur.

### 1. The basic "Once Over" (Syntax & Policy Check)

``` bash
az deployment group validate \
  --resource-group rg-hydroflow-dev \
  --template-file infra/main.bicep \
  --parameters infra/main.local.bicepparam
```

### 2. The "Dry Run" (Previewing the actual changes)

``` bash
az deployment group what-if \
  --resource-group rg-hydroflow-dev \
  --template-file main.bicep \
  --parameters main.local.bicepparam

# or redirect the output json to a file
az deployment group validate \
  --resource-group rg-hydroflow-dev \
  --template-file infra/main.bicep \
  --parameters infra/main.local.bicepparam \
  --output json \
  1> validate-result.json

```

## Deploy

``` bash
az deployment group create \
   --resource-group rg-hydroflow-dev \
   --template-file infra/main.bicep
```