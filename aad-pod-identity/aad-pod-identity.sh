az aks create -n aad -g aad --generate-ssh-keys --node-count 1 --network-plugin azure --network-policy calico

export SUBSCRIPTION_ID="d53beca8-7450-4196-a689-84cf17f3bfe3"
echo $SUBSCRIPTION_ID

export RESOURCE_GROUP="aad"
echo $RESOURCE_GROUP

export CLUSTER_NAME="aad"
echo $CLUSTER_NAME

export IDENTITY_RESOURCE_GROUP="$(az aks show -g ${RESOURCE_GROUP} -n ${CLUSTER_NAME} --query nodeResourceGroup -otsv)"
echo $IDENTITY_RESOURCE_GROUP

export IDENTITY_NAME="demo"
echo $IDENTITY_NAME

helm install aad-pod-identity aad-pod-identity/aad-pod-identity --namespace=kube-system

az identity create -g ${IDENTITY_RESOURCE_GROUP} -n ${IDENTITY_NAME}
export IDENTITY_CLIENT_ID="$(az identity show -g ${IDENTITY_RESOURCE_GROUP} -n ${IDENTITY_NAME} --query clientId -otsv)"
echo $IDENTITY_CLIENT_ID

export IDENTITY_RESOURCE_ID="$(az identity show -g ${IDENTITY_RESOURCE_GROUP} -n ${IDENTITY_NAME} --query id -otsv)"
echo $IDENTITY_RESOURCE_ID

cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: ${IDENTITY_NAME}
spec:
  type: 0
  resourceID: ${IDENTITY_RESOURCE_ID}
  clientID: ${IDENTITY_CLIENT_ID}
EOF

cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: ${IDENTITY_NAME}-binding
spec:
  azureIdentity: ${IDENTITY_NAME}
  selector: ${IDENTITY_NAME}
EOF

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: demo
  labels:
    aadpodidbinding: $IDENTITY_NAME
spec:
  containers:
  - name: demo
    image: mcr.microsoft.com/oss/azure/aad-pod-identity/demo:v1.8.4
    args:
      - --subscription-id=${SUBSCRIPTION_ID}
      - --resource-group=${IDENTITY_RESOURCE_GROUP}
      - --identity-client-id=${IDENTITY_CLIENT_ID}
  nodeSelector:
    kubernetes.io/os: linux
EOF

-------- Global Net Policy for Calico 

kind: GlobalNetworkPolicy
apiVersion: crd.projectcalico.org/v1
metadata:
  name: egress-localhost
spec:
  types:
    - Egress
  egress:
    - action: Allow
      protocol: TCP
      destination:
        nets:
          - 127.0.0.1
        ports: [2579]
