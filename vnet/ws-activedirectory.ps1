# Configure Windows Active Directory Service

Install-WindowsFeature AD-Domain-Services
Install-WindowsFeature -Name RSAT-AD-AdminCenter

Import-Module ADDSDeployment

Install-ADDSForest -DomainName "corp.jjazure.org" -DomainNetbiosName "corp"