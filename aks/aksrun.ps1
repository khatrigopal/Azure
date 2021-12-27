# For CLI Token please uncomment the #43 line. You need to have already installer the oc binary file. 
# 
$RG = "k8s"
$AKS_VER = "1.22.2"
$CLUSTER = "aks"
$LOC = "westeurope"
$VNET = "k8svnet"
$NODE_COUNT = "2"
$BROWSER = "C:\PROGRA~2\Microsoft\Edge\Application\"
$ARG=$args[0]
$VNET_PREFIX = "10.0.0.0/22"
$WIN_USER = "azureuser"
$WIN_PASS = "Kubernetes!!!!"
#write-host $param1
if ($ARG -eq 'create') {
  echo "---> Creating Resource Group"
  az group create --name $RG --location $LOC 
  echo "---> Creating AKS Cluster"
  az aks create --name $CLUSTER --resource-group $RG --enable-addons monitoring --enable-managed-identity --generate-ssh-keys --enable-cluster-autoscaler --kubernetes-version $AKS_VER --location $LOC --max-count 3 --min-count 1 --network-plugin azure --network-policy calico --node-count $NODE_COUNT


 }
if ($ARG -eq 'delete') {
  echo "---> Delete the AKS Cluster"
  az aks delete --resource-group $RG --name $CLUSTER
  echo "---> Delete the Resource Group"
  az group delete -n $RG
  echo "---> Done"
}
else {
  echo "Usage: aksrun.ps1 create/delete"
}