$AKS_NAME = "aks"
$AKS_RG = "aks"
$SUB_ID = "d325fdf"

$SP_ID = $(az aks show --resource-group $AKS_RG --name $AKS_NAME --query servicePrincipalProfile.clientId -o tsv)
az ad sp credential list --id "$SP_ID" --query "[].endDateTime" -o tsv
echo $SP_ID
$SP_SECRET = $(az ad sp credential reset --id "$SP_ID" --query password -o tsv)
echo $SP_SECRET




az aks update-credentials --resource-group $AKS_RG --name $AKS_NAME --reset-service-principal --service-principal "$SP_ID" --client-secret "${SP_SECRET}"
