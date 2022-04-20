# GitOps with Azure Kubernetes Service (AKS)

Docs https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2

Add GitOps configuration

```powershell
az k8s-configuration flux create -g jjmicroservices-rg -c jjaks -n jjaks-gitops -t managedClusters --scope cluster -u https://github.com/jjindrich/jjazure-infra-jjdev --branch master  --kustomization name=infra path=./aks-gitops/infra prune=true
```

Remove GitOps configuration

```powershell
az k8s-configuration flux delete -g jjmicroservices-rg -c jjaks -n jjaks-gitops -t managedClusters
```