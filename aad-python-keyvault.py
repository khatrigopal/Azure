from azure.identity import ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient

credential = ManagedIdentityCredential(client_id="")
client = SecretClient("https://aadvault01.vault.azure.net", credential)
retrieved_secret = client.get_secret("test")
print(retrieved_secret)
