# Mount Azure Blob containers with NFS in AKS Cluster

## Objective
Azure Blob containers could be mounted on AKS cluster through the CSI Blob drivers provided as part of AKS Addon. You can find Microsoft Learn documentation at the following link:

https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi?tabs=NFS

## Prerequisites

AKS Cluster in supported version with CSI Blob drivers enabled. If your cluster doesn't have these drivers enabled, you can update your deployment with the following command:

```
az aks update --enable-blob-driver -n myAKSCluster -g myResourceGroup
```

After enabling these drivers, we will have csi-blob-node-xxxx Pods available in the kube-system namespace.

## Storage Account implementation
We will choose the Premium Tier of Storage Account with Block blobs account type.
In advanced panel, we will select Enable hierarchical namespace and Enable network file system v3

In order to mount as NFS from AKS workloads, we need to create this Storage Account in the same VNET as our AKS Cluster. It will be automatically disabled the Enable Public access from all networks.

We create a Container from Azure Portal/Containers panel, in our case, it will be named nginx-blob

Please use the manifests file on this repository for implementation

## Testing
If for some reason, the mount operation on Pods is failing, you can check at the Node level with the following commands:

```
mkdir /mnt/nfs
mount -o sec=sys,vers=3,nolock,proto=tcp azstorageblobtest.blob.core.windows.net:/azstorageblobtest/aks /mnt/nfs
```
