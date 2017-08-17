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

* Our container contains a swagger enabled API developed in Go which writes a simple order via json to your specified Cosmos DB and tracks custom events via Application Insights: 

