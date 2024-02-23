#/bin/bash

echo "Deploy APPConfig Cluster"
RESOURCE_GROUP="appconfig"
AKS_CLUSTER_NAME="aksappconfig"
UAMI="appconfigmsi"
SUBSCRIPTION="aa1792c8-2080-4570-9e12-a13c30464c9f"
LOCATION="EastUS"
APPCFG_NAME="appconfig0001x"

az group create -n $RESOURCE_GROUP --location $LOCATION

echo "Create App Configuration"
az appconfig create --location $LOCATION --name $APPCFG_NAME --resource-group $RESOURCE_GROUP --enable-public-network true --sku Free

APPCFG_ID=$(az appconfig show -n $APPCFG_NAME -g RESOURCE_GROUP --query 'id' -otsv)

echo "Create AKS Cluster"
az aks create -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP --node-count 2 network-plugin azure --network-policy calico --enable-workload-identity --enable-odic-issuer

echo "Create a Managed Identity to be used by AppConfig provider"
az identity create --name $UAMI --resource-group $RESOURCE_GROUP

export USER_ASSIGNED_IDENTITY_CLIENT_ID="$(az identity show --resource-group $RESOURCE_GROUP --name $UAMI --query 'clientId' -otsv)"
echo $USER_ASSIGNED_IDENTITY_CLIENT_ID

export AKS_OIDC_ISSUER="$(az aks show -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP --query "oidcIssuerProfile.issuerUrl" -otsv)"
echo $AKS_OIDC_ISSUER

echo "Create Federated Identity:
az identity federated-credential create --resource-group $RESOURCE_GROUP --name apconfig_federated --identity-name appconfigmsi --issuer ${AKS_OIDC_ISSUER} --subject  system:serviceaccou>

az role assignment create --assignee "${USER_ASSIGNED_IDENTITY_CLIENT_ID}" --scope $APPCFG_ID --role "App Configuration Data Reader"
