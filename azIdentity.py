import azure.identity
# Get the AKS cluster credentialsclient = azure.identity.DefaultAzureCredential()
credentials = client.get_client_secret("AKS:Kubernetes")
# Deploy the workloadimport kubernetes
# Create a Kubernetes clientk8s = kubernetes.client.CoreV1Api(api_key=credentials.token)
# Deploy a deploymentdeployment = kubernetes.client.V1Deployment(
    metadata=kubernetes.client.V1ObjectMeta(name="my-deployment"),
    spec=kubernetes.client.V1DeploymentSpec(        replicas=3,
        selector=kubernetes.client.V1LabelSelector(            match_labels={"app": "my-app"}
        ),        template=kubernetes.client.V1PodTemplateSpec(            metadata=kubernetes.client.V1ObjectMeta(labels={"app": "my-app"}),
            spec=kubernetes.client.V1PodSpec(                containers=[                    kubernetes.client.V1Container(                        name="my-app",
                        image="nginx:latest",
                        ports=[kubernetes.client.V1ContainerPort(container_port=80)]
                    )
                ]
            )
        )
    )
)

k8s.create_namespaced_deployment(namespace="default", body=deployment)

# Wait for the deployment to be ready
import time

while True:
    deployment = k8s.read_namespaced_deployment(name="my-deployment", namespace="default")

    if deployment.status.ready_replicas == 3:
        break

    time.sleep(1)
