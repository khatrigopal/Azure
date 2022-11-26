# AKS KeyVault Integration with multiline secret

This document will provide the guide to use a multi line secret from Azure Key Vault in Azure Kubernetes Secret


1. Update my existing AKS Cluster to csi-secret addon:

```
az aks enable-addons --addons azure-keyvault-secrets-provider --name aks --resource-group aks
```
2.Creating Azure Key Vault:

```
az keyvault create -n ovidiuborlean-keyvault -g MC_aks_aks_westeurope -l westeurope
```

3.  Query for the Managed Identity assigned to AKS cluster to access the Key Vault:

```
az aks show -g aks -n aks --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv
```
4. Settings access policies based on the Id of Managed Identity:

```
az keyvault set-policy -n ovidiuborlean-keyvault --key-permissions get --spn xxxxxxxx

az keyvault set-policy -n ovidiuborlean-keyvault --secret-permissions get --spn xxxxxxx

keyvault set-policy -n ovidiuborlean-keyvault --certificate-permissions get --spn xxxxxxxx
```

5. Creating a multiline secret from a defined file:

```
az keyvault secret set --vault-name ovidiuborlean-keyvault --name multilinenew --file secretfile.txt
```

Used the following secretfile format for this multiline secret:

```
{
    "type": "service account",
    "project_id": "proj-12345",
    "private_key_id": "qwertyuiopasdfghjkl",
    "private_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAqfdlCY4DbgfkSKF/tgPzy+lMJBP/C7mQ3P32AWqPZy/wHW9Z\nMe8VXJo4P/crCR98GzCWYXsWmFGZolhTmS2ylZmOHfaLts3erVB1uLtuSc1wo8gE\n8xxSZWEsiQCpHgHDbOXr+CDJWz65JjI8l+f7jOjQYWtyra3onlG/fG5OqCv/oiAA\nWqQyWM//osc0h0ENBZ3X0qH5Mr135XjeZAQWzrBPNHLP9LUgJRHBagqFDIetN21T\n380iqt4u5MWpwCpXbTIEOPIJm+LUExMG5ng51nEV9rrm/sl1fWeUQ8Lx7loglvTc\nn2ZmxXynqYMSvTvM3WRVTi8UxS/u58Dib5a9oQIDAQABAoIBAFduxVH59Pe4JY3b\nTigitloyBBIXGz870TJtjgxCdcx+E4YAzqBqPdHqH3+ANWo3AQ+3mdRBjmkCqQaj\nazXEFTbxy/LL7ik2lBMR7cz+1ggvH3+RGEK7UgOGznMXnOervo0ZZZ65tvsyM+pb\nM2JtWrCs3u0OaerAKIawxNFMqTfGu7xeMbzclBfj6X82iNzsDtpoNPaeUiwe6cqH\n2zNGrgFVcO4qwKRtpCfrFyt3iO1TMFVS6UaBkHT2AeFyVjijQvbZUMyFJJ3P4NBb\n+Ho9udgENnEdjfdr7/b0CQXaT4X547i/8YDZyaYNI1YtWtSXyPgxKnm3uyKYcLZY\nHDx6ODECgYEA1246raxvNADfhYFgEbPMJGpWGr8U0V02mTsduxFBQcFp4wXpXdhA\n+OHl3UxqZF7adyl18rDYEF0cb0artewBiimmIcXGt8JBQ90tt848eLai9Mgqt3g4\ncpTGV0MqRBOvvmVrmPcD635r0PEJKGZ9BqlPKTAQ9CfGroKxa3GSN10CgYEAyfld\nlKE0WyPmp92AYFR4k/c8t7OVG4tgJMALtj/FRnQG7mX07PzqbOnU+Z+4Qb/NKs/w\n0HSfE0WPVh4Uq35AFicynjFs0A36HTR8J8BGuAGiwIOWePKN8sAkKH48cBn/+OmH\ni9XrtxurpQqeGTDymH2eAolWI2RCDS+O0ZnkzxUCgYAgM3XJ5/BnUYoXppL5kmp9\nNvfP36f483npxZBYGegrMAHn0UZkpKJxkTKOtZFhl1wIW8YplI13RLOvXlzkQHaq\ndDdE7Q8bAIpI3pKq2sTnNkV9WT4pVmr5lYtgF8YFjvvB9d7zaljHponvHVhFFayy\nhjQy7+BY3mkwRJDIgp1ccQKBgQCfrQmSy698rnFYHQG1JpL9R+U0xkEHubSU2U9p\nEhmAjZI9P1XXVkxvNp4ti1w8fspRInwcEVcCAWhEiRuGSRWZbfvSnPiNs78c/7V4\nJ8bBCmoFEQMRM5GNbOIpMUPOzH9V5ipHHyRvauzUWgSLnertK8KT9semy0h87DBY\n/PWr0QKBgQCC7SHs7pNeJTelft+TKaEasZAMtlc1lxeTdbXegoB1oFN5Ck5cCfaI\nnTrd4tc2z1Rc3m8eVxctkRcIJcUxeR56NjxrHL40Be8D1S9VsQvab61vEJXNhxaO\nXxCr6YyfZArQQdIB5aWkbVEir60Mfnq5agFwS5Y0bTcG3CJnKQAlHA==\n-----END RSA PRIVATE KEY-----\n",
    "email": testuser@live.com
}
```

6. Creating SecretProviderClass on cluster:

```
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-user-msi
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"          # Set to true for using managed identity
    userAssignedIdentityID: 65c67e63-ab55-42a8-bc20-xxxxx# Set the clientID of the user-assigned managed identity to use
    keyvaultName: ovidiuborlean-keyvault        # Set to the name of your key vault
    cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: multilinenew
          objectType: secret              # object types: secret, key, or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
    tenantId: 72f988bf-86f1-41af-91ab-xxx                 # The tenant ID of the key vault
```

7. Creating Pod where our secret will be mounted:

```
kind: Pod
apiVersion: v1
metadata:
  name: busybox-secrets-store-inline-user-msi
spec:
  containers:
    - name: busybox
      image: k8s.gcr.io/e2e-test-images/busybox:1.29-1
      command:
        - "/bin/sleep"
        - "10000"
      volumeMounts:
      - name: secrets-store01-inline
        mountPath: "/mnt/secrets-store"
        readOnly: true
  volumes:
    - name: secrets-store01-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: "azure-kvname-user-msi"
```

