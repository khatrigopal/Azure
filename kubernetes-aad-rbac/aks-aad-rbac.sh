AKS_ID=$(az aks show --resource-group aks --name aks --query id -o tsv)
echo $AKS_ID
APPDEV_ID=$(az ad group create --display-name appdev --mail-nickname ovidiuappdev@ovidiuborleangmail.onmicrosoft.com --query objectId -o tsv)
echo $APPDEV
az role assignment create --assignee $APPDEV_ID --role "Azure Kubernetes Service Cluster User Role" --scope $AKS_ID

OPSSRE_ID=$(az ad group create --display-name opssre --mail-nickname ovidiuopssre@ovidiuborleangmail.onmicrosoft.com --query objectId -o tsv)
echo #OPSSRE

az role assignment create --assignee $OPSSRE_ID --role "Azure Kubernetes Service Cluster User Role" --scope $AKS_ID
echo "Please enter the UPN for application developers: " && read AAD_DEV_UPN
echo "Please enter the secure password for application developers: " && read AAD_DEV_PW
AKSDEV_ID=$(az ad user create --display-name "AKS Dev" --user-principal-name $AAD_DEV_UPN --password $AAD_DEV_PW --query objectId -o tsv)
echo $AKSDEV_ID
az ad group member add --group appdev --member-id $AKSDEV_ID
echo "Please enter the UPN for SREs: " && read AAD_SRE_UPN
echo "Please enter the secure password for SREs: " && read AAD_SRE_PW
# Create a user for the SRE role
AKSSRE_ID=$(az ad user create --display-name "AKS SRE" --user-principal-name $AAD_SRE_UPN --password $AAD_SRE_PW --query objectId -o tsv)

# Add the user to the opssre Azure AD group
az ad group member add --group opssre --member-id $AKSSRE_ID

az aks get-credentials --resource-group myResourceGroup --name myAKSCluster --admin
kubectl create namespace dev

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dev-user-full-access
  namespace: dev
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources:
  - jobs
  - cronjobs
  verbs: ["*"]


  kubectl apply -f role-dev-namespace.yaml

  az ad group show --group appdev --query objectId -o tsv

  kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dev-user-access
  namespace: dev
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: dev-user-full-access
subjects:
- kind: Group
  namespace: dev
  name: groupObjectId


  kubectl apply -f rolebinding-dev-namespace.yaml

  kubectl create namespace sre

  kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: sre-user-full-access
  namespace: sre
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources:
  - jobs
  - cronjobs
  verbs: ["*"]

  kubectl apply -f role-sre-namespace.yaml

  az ad group show --group opssre --query objectId -o tsv


  kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: sre-user-access
  namespace: sre
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: sre-user-full-access
subjects:
- kind: Group
  namespace: sre
  name: groupObjectId


  kubectl apply -f rolebinding-sre-namespace.yaml

  az aks get-credentials --resource-group myResourceGroup --name myAKSCluster --overwrite-existing

kubectl run nginx-dev --image=mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine --namespace dev

$ kubectl run nginx-dev --image=mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine --namespace dev

To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code B24ZD6FP8 to authenticate.

pod/nginx-dev created



