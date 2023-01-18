$rg ='jjmicroservices-rg'

# install frontdoor
az deployment group create -g $rg --template-file deploy-fd.bicep
