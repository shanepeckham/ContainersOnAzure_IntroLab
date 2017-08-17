# Intro to Containers on Azure
This lab aims to show a few ways you can quickly deploy container workloads to Azure. 

# What is it?

This intro lab serves to guide you on a few ways you can deploy a container on Azure, namely:

*	Deploy a container on App Service PaaS platform
*	Deploy a container on an Azure Container Instance (managed Kubernetes cluster)
*	Deploy an unmanaged Kubernetes cluster on Azure using Azure Container Service and deploy our container onto it
* Write to Azure Cosmos DB. [Cosmos DB](https://azure.microsoft.com/en-us/services/cosmos-db/) is Microsoft's globally distributed, multi-model database: 
* Use [Application Insights](https://azure.microsoft.com/en-us/services/application-insights/) to track custom events in the application

# Technology used

* Our container contains a swagger enabled API developed in Go which writes a simple order via json to your specified Cosmos DB and tracks custom events via Application Insights.

# Preparing for this lab

For this Lab you will require:

* Install Postman, get it here - https://www.getpostman.com - this is optional but useful
* Install Docker, get it here - https://docs.docker.com/engine/installation/

## 1. Provisioning a Cosmos DB instance

Let's start by creating a Cosmos DB instance in the portal, this is a quick process. Navigate to the Azure portal and create a new Azure Cosmos DB instance, enter the following parameters:

ID: <yourdbinstance>
API: Select MongoDB as the API as our container API will use this driver
ResourceGroup: <yourresourcegroup>
Location: <yourlocation>

See below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/CosmosDB.png)

## 2. Provisioning an Application Insights instance

In the Azure portal, select create new Application Insights instance, enter the following parameters:

Name: <yourappinsightsinstance>
Application Type: General
ResourceGroup: <yourresourcegroup>
Location: <yourlocation>

See below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/ApplicationInsights.png)

## 3. Provisioning an Azure Container Registry instance

If you would like an example of how to setup an Azure Container Registry instance via ARM, have a look [here](https://github.com/shanepeckham/CADScenario_Recommendations)

Navigate to the Azure Portal and select create new Azure Container Registry, enter the following parameters:

Registry Name: <yourcontainerregistryinstance>
ResourceGroup: <yourresourcegroup>
Location: <yourlocation>
Admin User: Enable
SKU: Classic
Storage Account: Select the default value provided

See below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/ContainerRegistry.png)







