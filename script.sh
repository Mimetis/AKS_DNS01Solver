
# Create a namespace for your ingress resources
kubectl create namespace ingress-basic

# Use Helm to deploy an NGINX ingress controller
helm install nginx stable/nginx-ingress \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

# Deploy vote.yaml
kubectl apply -f vote.yaml

# Deploy ingress.yaml
kubectl apply -f ingress.yaml

# Deploy custom resources definition
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.1/cert-manager.crds.yaml

# create namespace for cert
kubectl create namespace cert-manager  

# Add repo
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Label the ingress-basic namespace to disable resource validation
kubectl label namespace ingress-basic cert-manager.io/disable-validation=true

# Install cert manager
helm install cert-manager jetstack/cert-manager \
     --namespace cert-manager \
     --version v0.14.1 \
     --set ingressShim.defaultIssuerName=letsencrypt-staging \
     --set ingressShim.defaultIssuerKind=ClusterIssuer

# Create a service principal for DNS validation
az ad sp create-for-rbac --name spcertmanageridentity

Creating a role assignment under the scope of "/subscriptions/subid000-eeee-ffff-gggg-hhhhhhhhhhh"
{
  "appId": "appid000-aaaa-bbbb-cccc-dddddddddddd",
  "displayName": "spcertmanageridentity",
  "name": "http://spcertmanageridentity",
  "password": "password-aaaa-bbbb-cccc-dddddddddddd",
  "tenant": "tenant00-aaaa-bbbb-cccc-dddddddddddd"
}

kubectl create secret generic azuredns-config --from-literal=client-secret=password-aaaa-bbbb-cccc-dddddddddddd -n cert-manager

kubectl apply -f dnsissuer.yaml

