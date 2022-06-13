# AzureStack HCI deployment

## Deploy basic infrastructure

How to create Lab
- https://docs.microsoft.com/en-us/azure-stack/hci/deploy/tutorial-private-forest
- https://github.com/microsoft/MSLab/tree/master/Scenarios/AzSHCI%20and%20Cluster%20Creation%20Extension

Create virtual machine
- sizing: Standard E16bds v5
- disk: Premium SSD LRS 512 GB
- run prepare scripts from MSLab

Run LabConfig.ps1 under administrator rights
- find LabConfig, copy and run on Hyper-V virtual machine
- run 3_Deploy.ps1
- install Windows Admin Center 
    - https://github.com/microsoft/MSLab/tree/master/Scenarios/AzSHCI%20and%20Cluster%20Creation%20Extension#install-windows-admin-center-in-gw-mode
    - https://docs.microsoft.com/en-us/windows-server/manage/windows-admin-center/deploy/install#install-on-server-core

Register Windows Admin Center
- https://docs.microsoft.com/en-us/azure-stack/hci/manage/register-windows-admin-center
- login https://wacgw/

## Deploy AzureStack HCI cluster with Arc

Lab scripts
- https://github.com/microsoft/MSLab/tree/dev/Scenarios/AzSHCI%20and%20Arc-enabled%20VMs

Steps in script
- create HCI cluster
- register HCI in Azure
- create MOC agent service (https://docs.microsoft.com/en-us/azure-stack/aks-hci/concepts-node-networking#microsoft-on-premises-cloud-service)
- create Arc bridge
- create images

Logon into DC virtual machine 
- run script Scenario.ps1 - step by step run regions under administrator rights
- test to connect jjazscluster