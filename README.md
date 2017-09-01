# Intro to Containers on Azure
This lab aims to show a few ways you can quickly deploy container workloads to Azure. 

# What is it?

This intro lab serves to guide you on a few ways you can deploy a container on Azure, namely:

*	Deploy a container on App Service PaaS platform
*	Deploy a container on an Azure Container Instance (managed Kubernetes cluster)
*	Deploy an unmanaged Kubernetes cluster on Azure using Azure Container Service (ACS) and deploy our container onto it
* Deploy the ACS Connector to a Kubernetes cluster and use it to manage Azure Container Service instances
* Write to Azure Cosmos DB. [Cosmos DB](https://azure.microsoft.com/en-us/services/cosmos-db/) is Microsoft's globally distributed, multi-model database 
* Use [Application Insights](https://azure.microsoft.com/en-us/services/application-insights/) to track custom events in the container

# Technology used

* Our container contains a swagger enabled API developed in Go which writes a simple order via json to your specified Cosmos DB and tracks custom events via Application Insights.

# Preparing for this lab

For this Lab you will require:

* Install the Azure CLI 2.0, get it here - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
* Install Docker, get it here - https://docs.docker.com/engine/installation/
* Install Postman, get it here - https://www.getpostman.com - this is optional but useful

When using the Azure CLI, after logging in, if you have more than one subscripton you may need to set the default subscription you wish to perform actions against. To do this use the following command:

```
az account set --subscription "<your requried subscription guid>"
```

## 1. Provisioning a Cosmos DB instance

Let's start by creating a Cosmos DB instance in the portal, this is a quick process. Navigate to the Azure portal and create a new Azure Cosmos DB instance, enter the following parameters:

* ID: <yourdbinstance>
* API: Select MongoDB as the API as our container API will use this driver
* ResourceGroup: <yourresourcegroup>
* Location: <yourlocation>

See below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/CosmosDB.png)

Once the DB is provisioned, we need to get the Database Username and Password, these may be found in the Settings --> Connection Strings section of your DB. We will need these to run our container, so copy them for convenient access. See below:

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/DBKeys.png)

## 2. Provisioning an Application Insights instance

In the Azure portal, select create new Application Insights instance, enter the following parameters:

* Name: <yourappinsightsinstance>
* Application Type: General
* ResourceGroup: <yourresourcegroup>
* Location: <yourlocation>

See below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/ApplicationInsights.png)

Once Application Insights is provisioned, we need to get the Instrumentation key, this may be found in the Overview section. We will need this to run our container, so copy it for convenient access. See below:

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/AppKey.png)

## 3. Provisioning an Azure Container Registry instance

If you would like an example of how to setup an [Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry/) instance via ARM, have a look [here](https://github.com/shanepeckham/CADScenario_Recommendations)

Navigate to the Azure Portal and select create new Azure Container Registry, enter the following parameters:

* Registry Name: <yourcontainerregistryinstance>
* ResourceGroup: <yourresourcegroup>
* Location: <yourlocation>
* Admin User: Enable
* SKU: Classic
* Storage Account: Select the default value provided

See below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/ContainerRegistry.png)

## 4. Pull the container to your environment and set the environment keys

Open up your docker command window (if using Windows open it with elevated privileges) and type the following:

``` 
docker pull shanepeckham/go_order_sb
```

We will now test the image locally to ensure that it is working and connecting to our CosmosDB and Application Insights instances. The keys you copied for the DB and App Insights keys are set as environment variables within the container, so we will need to ensure we populate these.

The environment keys that need to be set are as follows:
* DATABASE: <your cosmodb username from step 1>
* PASSWORD: <your cosmodb password from step 1>
* INSIGHTSKEY: <you app insights key from step 2>
* SOURCE: This is a free text field which we will use specify where we are running the container from. I use the values localhost, AppService, ACI and K8 for my tests

So to run the container on your local machine, enter the following command, substituting your environment variable values (if you are running Docker on Windows, omit the 'sudo'):

```
sudo docker run --name go_order_sb -p 8080:8080 -e DATABASE="<your cosmodb username from step 1>" -e PASSWORD="<your cosmodb password from step 1>" -e INSIGHTSKEY="<you app insights key from step 2>" -e SOURCE="localhost"  --rm -i -t shanepeckham/go_order_sb
```
Note, the application runs on port 8080 which we will bind to the host as well. If you are running on Windows, select 'Allow Access' on Windows Firewall.

If all goes well, you should see the application running on localhost:8080, see below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/localrun.png)

Now you can navigate to localhost:8080/swagger and test the api. Select the 'POST' /order/ section, select the button "Try it out" and enter some values in the json provided and select "Execute", see below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/swagger.png)

If the request succeeded, you will get a CosmosDB Id returned for the order you have just placed, see below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/swaggerresponse.png)

We can now go and query CosmosDB to check our entry there, in the Azure portal, navigate back to your Cosmos DB instance and go to the section Data Explorer (note, at the time of writing this is in preview so is subject to change). We can now query for the order we placed. A collection called 'orders' will have been created within your database, you can then apply a filter for the id we created, namely:

```
{"id":"5995b963134e4f007bc45447"}
```
See below:

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/CosmosQuery.png)

## 5. Retag the image and upload it your private Azure Container Registry

Navigate to the Azure Container Registry instance you provisioned within the Azure portal. Click on the *Quick Start* blade, this will provide you with the relevant commands to upload a container image to your registry, see below:

![alt text](https://github.com/shanepeckham/CADScenario_Recommendations/blob/master/images/quicksstartacs.png)

Now we will push the image up to the Azure Container Registry, enter the following (from the quickstart screen):

``` 
docker login <yourcontainerregistryinstance>.azurecr.io

```

To get the username and password, navigate to the *Access Keys* blade, see below:

![alt text](https://github.com/shanepeckham/CADScenario_Recommendations/blob/master/images/acskeys.png)

You will receive a 'Login Succeeded' message. Now type the following:
```
docker tag shanepeckham/go_order_sb <yourcontainerregistryinstance>.azurecr.io/go_order_sb
docker push <yourcontainerregistryinstance>.azurecr.io/go_order_sb
```
Once this has completed, you will be able to see your container uploaded to the Container Registry within the portal, see below:

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/registryrepo.png)

## 6. Deploy the container to App Services

We will now deploy the container to Azure App Services via the Azure CLI. If you would like an example of how to setup an [App Service Application](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-intro) instance via ARM and associate the container with your Azure Container Registry, have a look [here](https://github.com/shanepeckham/CADScenario_Recommendations)

[Login to your Azure subscription via the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli) and enter the following first command to create your App service plan:

```
az appservice plan create -g <yourresourcegroup> -n <yourappserviceplan> --is-linux
```

Upon receiving the 'provisioningState': 'Succeeded' json response, enter the following to create your app which will run our API:

```
az webapp create -n <your unique web app name> -p <yourappserviceplan> -g <yourresourcegroup> --deployment-container-image-name <yourcontainerregistryinstance>.azurecr.io/go_order_sb
```

If you are not using the latest Azure CLI version, you may need to use the following alternative syntax:

```az appservice web create -n <your unique web app name> -p <yourappserviceplan> -g <yourresourcegroup>```

Upon receiving the successul completion json response, we will now associate our container from our private Azure Registry to the App Service App, type the following (if you are using PowerShell on Windows, you may need to remove any line breaks and continue on a single line):

```
az webapp config container set -n <your unique web app name> -g <yourresourcegroup>
--docker-custom-image-name <yourcontainerregistryinstance>.azurecr.io/go_order_sb:latest
--docker-registry-server-url https://<yourcontainerregistryinstance>.azurecr.io
--docker-registry-server-user <your acr admin username>
--docker-registry-server-password <your acr admin password>
```

### Associate the environment variables with API App

Now we need to go and set the environment variables for our container to ensure that we can connect to our Cosmos DB and Application Insights. Navigate to the *Application Settings* pane within the Azure portal for your Web App and add the following entries in the 'App Settings' section, namely:

The environment keys that need to be set are as follows:
* DATABASE: <your cosmodb username from step 1>
* PASSWORD: <your cosmodb password from step 1>
* INSIGHTSKEY: <you app insights key from step 2>
* SOURCE: This is a free text field which we will use specify where we are running the container from. I use the values localhost, AppService, ACI and K8 for my tests
* PORT: 8080 

See below:
![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/appsettings.png)

## 7. Deploy the container to Azure Container Instance

Now we will deploy our container to [Azure Container Instances](https://azure.microsoft.com/en-us/services/container-instances/). 

In the command terminal, login using the AZ CLI and we will start off by created a new resourcegroup for our Container instance. At the time of writing this functionality is still in preview and is thus not available in all regions (it is currently available in westeurope, eastus, westus), hence why we will create a new resourcegroup just in case. 

Enter the following:

```
az group create --name <yourACIresourcegroup> --location <westeurope, eastus, westus>
```

### Associate the environment variables with Azure Container Instance

We will now deploy our container instance via an ARM template, which is [here](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/azuredeploy.json) but before we do, we need to edit this document to ensure we set our environment variables.


In the document, the following section needs to be amended, adding your environment keys like you did before:

```

"properties": {
                "containers": [
                    {
                        "name": "[variables('container1name')]",
                        "properties": {
                            "image": "[variables('container1image')]",
                            "environmentVariables": [
                                {
                                    "name": "DATABASE",
                                    "value": "<your cosmodb username from step 1>"
                                },
                                {
                                    "name": "PASSWORD",
                                    "value": "<your cosmodb password from step 1>"
                                },
                                {
                                    "name": "INSIGHTSKEY",
                                    "value": "<you app insights key from step 2>"
                                },
                                {
                                    "name": "SOURCE",
                                    "value": "ACI"
                                }
                            ],

```
Once this document is saved, we can create the deployment via the az CLI. Enter the following:

```
az group deployment create --name <yourACIname> --resource-group <yourACIresourcegroup> --template-file /<path to your file>/azuredeploy.json
```

Once this has succeeded, you will see your external IP address within the response json, copy this value and navigate to http://yourACIExternalIP:8080/swagger and test your API like before.

## 8. Deploy the container to an Azure Container Engine provisioned Kubernetes cluster

Here we will deploy a Kubernetes cluster quickly using the [Azure Container Engine](https://azure.microsoft.com/en-us/services/container-service/). Note, the approach below will control all aspects of your Kubernetes setup and is intended for quick provisioning, for more control on the implementation look at the [following](https://github.com/Azure/acs-engine/blob/master/docs/acsengine.md). 

We will start by once again creating a resource group for our cluster using the az CLI and the acs engine, in a command window enter the following:

```
az group create --name <yourresourcegroupk8> --location <yourlocation>
```

Upon receiving your "provisioningState": "Succeeded" json response, enter the following:

```
az acs create --orchestrator-type kubernetes --resource-group <yourresourcegroupk8> --name <yourk8cluster> --generate-ssh-keys
```
In case you have not already, install the kubernetes client:

```
az acs kubernetes install-cli
```

You will now be able to connect to your cluster with the following command:

```
az acs kubernetes get-credentials --resource-group=<yourresourcegroupk8> --name=<yourk8cluster>
```

And to access your Kubernetes graphical dashboard enter:

```
az acs kubernetes browse -g <yourresourcegroupk8> -n <yourk8cluster> 
```

Note, it is always a good idea to apply an auto shutdown policy to your VMs to avoid unnecessary costs for a test cluster, you can do this in the portal by navigating to the VMs provisioned within your resource group <yourresourcegroupk8> and navigating to the Auto Shutdown section for each one, see below:

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/autoshutdown.png)

### Register our Azure Container Registry within Kubernetes

We now want to register our private Azure Container Registry with our Kubernetes cluster to ensure that we can pull images from it. Enter the following within your command window:

```
kubectl create secret docker-registry <yourcontainerregistryinstance> --docker-server=<yourcontainerregistryinstance>.azurecr.io --docker-username=<your acr admin username> --docker-password=<your acr admin password> --docker-email=shanepeckham@live.com
```

In the Kubernetes dashboard you should now see this created within the secrets section:

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/K8secrets.png)

### Associate the environment variables with container we want to deploy to Kubernetes

We will now deploy our container via a yaml file, which is [here](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/go_order_sb.yaml) but before we do, we need to edit this file to ensure we set our environment variables and ensure that you have set your private Azure Container Registry correctly:

```

spec:
      containers:
      - name: goordersb
        image: <containerregistry>.azurecr.io/go_order_sb
        env:
        - name: DATABASE
          value: "<your cosmodb username from step 1>""
        - name: PASSWORD
          value: "<your cosmodb password from step 1>""
        - name: INSIGHTSKEY
          value: ""<you app insights key from step 2>""
        - name: SOURCE
          value: "K8"
        ports:
        - containerPort: 8080
      imagePullSecrets:
        - name: <yourcontainerregistry>
```

Once the yaml file has been updated, we can now deploy our container. Within the command line enter the following:

```
kubectl create -f ./<your path>/go_order_sb.yaml
```
You should get a success message that a deployment and service has been created. Navigate back to the Kubernetes dashboard and you should see the following:

#### Your deployments running 

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/k8deployments.png)

#### Your three pods

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/k8pods.png)

#### Your service and external endpoint

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/k8service.png)

You can now navigate to http://k8serviceendpoint:8080/swagger and test your API

## 8. Deploy the container to an Azure Container Engine and manage it from within your Kubernetes cluster

Now we will deploy our container to Azure Container Instances and use the [ACI connector](https://github.com/azure/aci-connector-k8s) to manage it from within our Kubernetes cluster.

### Create a Service Principle

A service principal is required to allow the ACI Connector to create resources in your Azure subscription. You can create one using the az CLI using the instructions below.

Find your ``` subscriptionId ``` with the az CLI:

```
$ az account list -o table
Name                                             CloudName    SubscriptionId                        State    IsDefault
-----------------------------------------------  -----------  ------------------------------------  -------  -----------
Pay-As-You-Go                                    AzureCloud   12345678-9012-3456-7890-123456789012  Enabled  True
```

Use ``` az ``` to create a Service Principal that can perform operations on your resource group:
```
$ az ad sp create-for-rbac --role=Contributor --scopes /subscriptions/<subscriptionId>/resourceGroups/<yourresourcegroupk8>
```
After one or a few attempts, you should see the following json structure being output:
```
{
  "appId": "<redacted>",
  "displayName": "azure-cli-2017-07-19-19-13-19",
  "name": "http://azure-cli-2017-07-19-19-13-19",
  "password": "<redacted>",
  "tenant": "<redacted>"
}
```

#### Install the ACI Connector

Edit the [aci_connector_go_order_sb.yaml](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/aci_connector_go_order_sb.yaml) and input environment variables using the values above:

* AZURE_CLIENT_ID: insert appId
* AZURE_CLIENT_KEY: insert password
* AZURE_TENANT_ID: insert tenant
* AZURE_SUBSCRIPTION_ID: insert subscriptionId

```
$ kubectl create -f ./<your_path>/aci-connector.yaml 
deployment "aci-connector" created

$ kubectl get nodes -w
NAME                        STATUS                     AGE       VERSION
aci-connector               Ready                      3s        1.6.6
k8s-agentpool1-31868821-0   Ready                      5d        v1.7.0
k8s-agentpool1-31868821-1   Ready                      5d        v1.7.0
k8s-agentpool1-31868821-2   Ready                      5d        v1.7.0
k8s-master-31868821-0       Ready,SchedulingDisabled   5d        v1.7.0
```

You should now the see the ACI Connector running within your Kubernetes cluster, see below:

![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/k8acsconnector.png)

### Deploy the container to Azure Container Instance managed by Kubernetes and set environment variables

We will now deploy our container via a yaml file again, which is [here](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/go_order_sb_aci_node.yaml) but before we do, we need to edit this file to ensure we set our environment variables.

Now we want to add the environment variables and ensure that you have set your private Azure Container Registry correctly:
```
spec:
  containers:
  - name: goordersb
    image: <yourcontainerregistry>.azurecr.io/go_order_sb
    env:
    - name: DATABASE
      value: ""
    - name: PASSWORD
      value: ""
    - name: INSIGHTSKEY
      value: ""
    - name: SOURCE
      value: "K8ACI"
    ports:
      - containerPort: 8080
  imagePullSecrets:
    - name: <yourcontainerregistry>
  dnsPolicy: ClusterFirst
  nodeName: aci-connector
  
  ```
  
Once deployed you should now see your container instances running, one within your cluster, and one running on the ACI Connector pod, see below:
  
 ![alt text](https://github.com/shanepeckham/ContainersOnAzure_MiniLab/blob/master/images/K8acipod.png)

You can now test the API
 
