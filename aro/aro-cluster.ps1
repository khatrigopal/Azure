# For CLI Token please uncomment the #43 line. You need to have already installer the oc binary file. 
# 
$RG = "aro"
$CLUSTER = "arodemo"
$LOC = "westeurope"
$VNET = "aronet"
$BROWSER = "C:\PROGRA~2\Microsoft\Edge\Application\"
$ARG=$args[0]
$VNET_PREFIX = "10.0.0.0/22"
$MASTER_SUBNET = "10.0.0.0/23"
$WORKER_SUBNET = "10.0.2.0/23"
#write-host $param1
if ($ARG -eq 'create') {
  echo "---> Registering Azure Providers"
  az provider register -n Microsoft.RedHatOpenShift --wait
  az provider register -n Microsoft.Compute --wait
  az provider register -n Microsoft.Storage --wait
  echo "---> Creating Resource Group"
  az group create --name $RG --location $LOC 
  echo "---> Creating Virtual Network"
  az network vnet create --resource-group $RG --name $VNET --address-prefixes $VNET_PREFIX
  echo "---> Creating subnet for Master Nodes"
  az network vnet subnet create --resource-group $RG --vnet-name $VNET --name master-subnet --address-prefix $MASTER_SUBNET --service-endpoints Microsoft.ContainerRegistry
  echo "---> Creating subnet for Worker Nodes"
  az network vnet subnet create --resource-group $RG --vnet-name $VNET --name worker-subnet --address-prefix $WORKER_SUBNET --service-endpoints Microsoft.ContainerRegistry
  az network vnet subnet update --resource-group $RG --name master-subnet --vnet-name $VNET --disable-private-link-service-network-policies true
  echo "---> Creating ARO Cluster"
  az aro create --resource-group $RG --name $CLUSTER --vnet $VNET --master-subnet master-subnet --worker-subnet worker-subnet --pull-secret @pull-secret.txt
  $API_PROFILE = az aro show -g $RG -n $CLUSTER --query apiserverProfile.url
  echo "---> API Profile for ARO Cluster is: " $API_PROFILE
  #$API_confirmation = Read-Host "Do you want to extract de TOKEN for Openshift-CLI (oc) (y/n) ?:"
  $CONSOLE_PROFILE = az aro show -g $RG -n $CLUSTER --query consoleProfile.url
  echo "---> Console Profile for ARO Cluster is: " $CONSOLE_PROFILE
  $CONSOLE_USERNAME = az aro list-credentials -g aro -n arodemo --query kubeadminUsername
  echo "---> Console Username for ARO Cluster is: " $CONSOLE_USERNAME
  $CONSOLE_PASSWORD = az aro list-credentials -g aro -n arodemo --query kubeadminPassword
  echo "---> Console Password for ARO Cluster is: " $CONSOLE_PASSWORD
  echo "---> Saving Credentials to file: aro-login.txt"
  echo $API_PROFILE > aro-login.txt
  echo $CONSOLE_PROFILE >> aro-login.txt
  echo $CONSOLE_USERNAME >> aro-login.txt
  echo $CONSOLE_PASSWORD  >> aro-login.txt
  #oc login $API_PROFILE
 }
if ($ARG -eq 'delete') {
  echo "---> Delete the ARO Cluster"
  az aro delete --resource-group $RG --name $CLUSTER
  echo "---> Delete the Resource Group"
  az group delete -n $RG
  echo "---> Done"
}
else {
  echo "Usage: aro-cluster.ps1 create/delete"
}