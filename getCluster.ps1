$aksClusters = Get-AzAksCluster

foreach ($aksCluster in $aksClusters) {
    Write-Host "AKS Cluster: $($aksCluster.Name)"
    $nodePools = Get-AzAksNodepool -ResourceGroupName ($aksCluster.Id.Split('/')[4]) -ClusterName $aksCluster.Name

    foreach ($nodePool in $nodePools) {
        Write-Host "  Node Pool: $($nodePool.Name)"
        $vmssName = (Get-AzVmss -ResourceGroupName $aksCluster.NodeResourceGroup | Where-Object {$_.Tags['aks-managed-poolName'] -eq $nodePool.Name}).Name
        $vmssInstances = Get-AzVmssVM -ResourceGroupName $aksCluster.NodeResourceGroup -VMScaleSetName $vmssName

        foreach ($vmssInstance in $vmssInstances) {
            Write-Host "    VM: $($vmssInstance.Name)"
        }
    }
}
