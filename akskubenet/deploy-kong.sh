# https://docs.konghq.com/kubernetes-ingress-controller/1.3.x/guides/getting-started/

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Kong
helm repo add kong https://charts.konghq.com
helm repo update
helm install kong kong/kong
