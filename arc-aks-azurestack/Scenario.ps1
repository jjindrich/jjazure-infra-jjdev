#https://aka.ms/ArcEnabledHCI
#https://aka.ms/AzureArcVM

###################
### Run from DC ###
###################

#region Variables 
$ClusterNodeNames="jjazsaks1","jjazsaks2"
$ClusterName="jjazsakscluster"
$vswitchName="vSwitch"

#Install or update Azure packages
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
$ModuleNames="Az.Accounts","Az.Compute","Az.Resources","Az.StackHCI"
foreach ($ModuleName in $ModuleNames){
    $Module=Get-InstalledModule -Name $ModuleName -ErrorAction Ignore
    if ($Module){$LatestVersion=(Find-Module -Name $ModuleName).Version}
    if (-not($Module) -or ($Module.Version -lt $LatestVersion)){
        Install-Module -Name $ModuleName -Force
    }
}

#login to Azure
if (-not (Get-AzContext)){
    Login-AzAccount -UseDeviceAuthentication
}

$SubscriptionID=(Get-AzContext).Subscription.ID

#select context
$context=Get-AzContext -ListAvailable
if (($context).count -gt 1){
    $context=$context | Out-GridView -OutputMode Single
    $context | Set-AzContext
}

#I did only test same for all (EastUS)
$AzureStackLocation="eastus"

<#or populate by choosing your own
#grab region where to grab VMs from
$VMImageLocation = (Get-AzLocation | Where-Object Providers -Contains "Microsoft.Compute" | Out-GridView -OutputMode Single -Title "Choose location where to grab VMs from").Location

#grab location for Arc Resource Bridge and Custom location
$ArcResourceBridgeLocation=(Get-AzLocation | Where-Object Providers -Contains "Microsoft.ResourceConnector" | Out-GridView -OutputMode Single -Title "Choose location for Arc Resource Bridge and Custom location").Location

#grab location for Azure Stack
$AzureStackLocation=(Get-AzLocation | Where-Object Providers -Contains "Microsoft.AzureStackHCI" | Out-GridView -OutputMode Single -Title "Choose location for Azure Stack HCI - where it should be registered").Location
#>

#endregion

#region Create 2 node cluster (just simple. Not for prod - follow hyperconverged scenario for real clusters https://github.com/microsoft/MSLab/tree/master/Scenarios/AzSHCI%20Deployment)
# Install features for management on server
Install-WindowsFeature -Name RSAT-Clustering,RSAT-Clustering-Mgmt,RSAT-Clustering-PowerShell,RSAT-Hyper-V-Tools

# Update servers (optional)
    <#
    Invoke-Command -ComputerName $ClusterNodeNames -ScriptBlock {
        New-PSSessionConfigurationFile -RunAsVirtualAccount -Path $env:TEMP\VirtualAccount.pssc
        Register-PSSessionConfiguration -Name 'VirtualAccount' -Path $env:TEMP\VirtualAccount.pssc -Force
    } -ErrorAction Ignore
    # Run Windows Update via ComObject.
    Invoke-Command -ComputerName $ClusterNodeNames -ConfigurationName 'VirtualAccount' {
        $Searcher = New-Object -ComObject Microsoft.Update.Searcher
        $SearchCriteriaAllUpdates = "IsInstalled=0 and DeploymentAction='Installation' or
                                IsPresent=1 and DeploymentAction='Uninstallation' or
                                IsInstalled=1 and DeploymentAction='Installation' and RebootRequired=1 or
                                IsInstalled=0 and DeploymentAction='Uninstallation' and RebootRequired=1"
        $SearchResult = $Searcher.Search($SearchCriteriaAllUpdates).Updates
        $Session = New-Object -ComObject Microsoft.Update.Session
        $Downloader = $Session.CreateUpdateDownloader()
        $Downloader.Updates = $SearchResult
        $Downloader.Download()
        $Installer = New-Object -ComObject Microsoft.Update.Installer
        $Installer.Updates = $SearchResult
        $Result = $Installer.Install()
        $Result
    }
    #remove temporary PSsession config
    Invoke-Command -ComputerName $ClusterNodeNames -ScriptBlock {
        Unregister-PSSessionConfiguration -Name 'VirtualAccount'
        Remove-Item -Path $env:TEMP\VirtualAccount.pssc
    }
    #>

# Install features on servers
Invoke-Command -computername $ClusterNodeNames -ScriptBlock {
    Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V -Online -NoRestart 
    Install-WindowsFeature -Name "Failover-Clustering","RSAT-Clustering-Powershell","Hyper-V-PowerShell"
}

# restart servers
Restart-Computer -ComputerName $ClusterNodeNames -Protocol WSMan -Wait -For PowerShell
#failsafe - sometimes it evaluates, that servers completed restart after first restart (hyper-v needs 2)
Start-sleep 20

# create vSwitch (sometimes happens, that I need to restart servers again and then it will create vSwitch...)
Invoke-Command -ComputerName $ClusterNodeNames -ScriptBlock {New-VMSwitch -Name $using:vswitchName -EnableEmbeddedTeaming $TRUE -NetAdapterName (Get-NetIPAddress -IPAddress 10.* ).InterfaceAlias}

#create cluster
New-Cluster -Name $ClusterName -Node $ClusterNodeNames
Start-Sleep 5
Clear-DNSClientCache

#add file share witness
#Create new directory
    $WitnessName=$ClusterName+"Witness"
    Invoke-Command -ComputerName DC -ScriptBlock {new-item -Path c:\Shares -Name $using:WitnessName -ItemType Directory}
    $accounts=@()
    $accounts+="corp\$($ClusterName)$"
    $accounts+="corp\Domain Admins"
    New-SmbShare -Name $WitnessName -Path "c:\Shares\$WitnessName" -FullAccess $accounts -CimSession DC
#Set NTFS permissions
    Invoke-Command -ComputerName DC -ScriptBlock {(Get-SmbShare $using:WitnessName).PresetPathAcl | Set-Acl}
#Set Quorum
    Set-ClusterQuorum -Cluster $ClusterName -FileShareWitness "\\DC\$WitnessName"

#Enable S2D
Enable-ClusterS2D -CimSession $ClusterName -Verbose -Confirm:0

#configure thin volumes a default if available (because why not :)
$OSInfo=Invoke-Command -ComputerName $ClusterName -ScriptBlock {
    Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\'
}
if ($OSInfo.productname -eq "Azure Stack HCI" -and $OSInfo.CurrentBuild -ge 20348){
    Get-StoragePool -CimSession $ClusterName -FriendlyName S2D* | Set-StoragePool -ProvisioningTypeDefault Thin
}


#endregion

#region Register Azure Stack HCI to Azure - if not registered, VMs are not added as cluster resources = AKS script will fail
#download Azure module
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
if (!(Get-InstalledModule -Name Az.StackHCI -ErrorAction Ignore)){
    Install-Module -Name Az.StackHCI -Force
}

#login to azure
#download Azure module
if (!(Get-InstalledModule -Name az.accounts -ErrorAction Ignore)){
    Install-Module -Name Az.Accounts -Force
}
Connect-AzAccount -UseDeviceAuthentication

#select subscription if more available
$subscription=Get-AzSubscription
if (($subscription).count -gt 1){
    $subscription | Out-GridView -OutputMode Single | Set-AzContext
}

#grab subscription ID
$subscriptionID=(Get-AzContext).Subscription.id

<# Register AZSHCi without prompting for creds, 
Notes: As Dec. 2021, in Azure Stack HCI 21H2,  if you Register-AzStackHCI the cluster multiple times in same ResourceGroup (e.g. default
resource group name is AzSHCI-Cluster-rg) without run UnRegister-AzStackHCI first, although you may succeed in cluster registration, but
sever node Arc integration will fail, even if you have deleted the ResourceGroup in Azure Portal before running Register-AzStackHCI #>

$armTokenItemResource = "https://management.core.windows.net/"
$graphTokenItemResource = "https://graph.windows.net/"
$azContext = Get-AzContext
$authFactory = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory
$graphToken = $authFactory.Authenticate($azContext.Account, $azContext.Environment, $azContext.Tenant.Id, $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, $graphTokenItemResource).AccessToken
$armToken = $authFactory.Authenticate($azContext.Account, $azContext.Environment, $azContext.Tenant.Id, $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, $armTokenItemResource).AccessToken
$id = $azContext.Account.Id

#grab location
if (!(Get-InstalledModule -Name Az.Resources -ErrorAction Ignore)){
    Install-Module -Name Az.Resources -Force
}

#register
Register-AzStackHCI -SubscriptionID $subscriptionID -Region $AzureStackLocation -ComputerName $ClusterName -GraphAccessToken $graphToken -ArmAccessToken $armToken -AccountId $id

#Install Azure Stack HCI RSAT Tools to all nodes
Invoke-Command -ComputerName $ClusterNodeNames -ScriptBlock {
    Install-WindowsFeature -Name RSAT-Azure-Stack-HCI
}
#Validate registration (query on just one node is needed)
Invoke-Command -ComputerName $ClusterName -ScriptBlock {
    Get-AzureStackHCI
}
#endregion

