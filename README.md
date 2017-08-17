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

Once the DB is provisioned, we need to get the Database Username and Password, these may be found in the Settings --> Connection Strings section of your DB. We will need these to run our container, so copy them for convenient access. See below:

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/DBKeys.png)

## 2. Provisioning an Application Insights instance

In the Azure portal, select create new Application Insights instance, enter the following parameters:

Name: <yourappinsightsinstance>
Application Type: General
ResourceGroup: <yourresourcegroup>
Location: <yourlocation>

See below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/ApplicationInsights.png)

Once Application Insights is provisioned, we need to get the Instrumentation key, this may be found in the Overview section. We will need this to run our container, so copy it for convenient access. See below:

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/AppKey.png)

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

## 4. Pull the container to your environment and set the environment keys

Open up your docker command window (if using Windows open it with elevated privileges) and type the following:

``` 
docker pull shanepeckham/go_order_sb
```

We will now test the image locally to ensure that it is working and connecting to our CosmosDB and Application Insights instances. The keys you copied for the DB and App Insights keys are set as environment variables within the container, so we will need to ensure we populate these.

The environment keys that need to be set are as follows:
DATABASE: <your cosmodb username from step 1>
PASSWORD: <your cosmodb password from step 1>
INSIGHTSKEY: <you app insights key from step 2>
SOURCE: This is a free text field which we will use specify where we are running the container from. I use the values localhost, AppService, ACI and K8 for my tests

So to run the container on your local machine, enter the following command, substituting your environment variable values:

```
sudo docker run --name go_order_sb -p 8080:8080 -e DATABASE="<your cosmodb username from step 1>" -e PASSWORD="<your cosmodb password from step 1>" -e INSIGHTSKEY="<you app insights key from step 2>" -e SOURCE="localhost"  --rm -i -t shanepeckham/go_order_sb
```
Note, the application runs on port 8080 which we will bind to the host as well. If you are running on Windows, select 'Allow Access' on Windows Firewall.

If all goes well, you should see something like the image below, with the application running on localhost:8080, see below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/localrun.png)

Now you can navigate to localhost:8080/swagger and test the api. Select the 'POST' /order/ section, select the button "Try it out" and enter some values in the json provided and select "Execute", see below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/swagger.png)

If all goes well, you will get a CosmosDB Id returned for the order you have just placed, see below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/swaggerresponse.png)

We can now go and query CosmosDB to check our entry there, in the Azure portal, navigate back to your Cosmos DB instance and go to the section Data Explorer (note, at the time of writing this is in preview so is subject to change). We can now query for the order we placed. A collection called 'orders' will have been created within your database, you can then apply a filter for the id we created, namely:

```
{"id":"5995b963134e4f007bc45447"}
```
See below:

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/CosmosQuery.png)










