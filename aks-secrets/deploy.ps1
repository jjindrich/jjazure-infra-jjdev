# https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver#sync-mounted-content-with-a-kubernetes-secret

# enable addon on AKS
az aks addon enable -n jjaks -g jjmicroservices-rg --addon azure-keyvault-secrets-provider

# update secret provider - if mode nodepools are used then must define 
az aks show -n jjaks -g jjmicroservices-rg --query identityProfile.kubeletidentity.clientId -o tsv

# deploy to AKS
kubectl apply -f .\secretprovider.yaml
kubectl apply -f .\deployment.yaml

# test existence of ENV
kubectl get pod
kubectl exec -it jjnginx-7b89584767-9qpdn -- cat mnt/secrets-store/aksname
kubectl exec -it jjnginx-7b89584767-9qpdn -- env

# clean up
kubectl delete -f .\secretprovider.yaml
kubectl delete -f .\deployment.yaml
