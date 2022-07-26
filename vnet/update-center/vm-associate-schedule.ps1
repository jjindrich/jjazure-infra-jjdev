Invoke-AzRestMethod -Path "/subscriptions/82fb79bf-ee69-4a57-a76c-26153e544afe/resourceGroups/jjdc-rg/providers/Microsoft.HybridCompute/machines/JAJINDRI-SERVER/providers/Microsoft.Maintenance/configurationAssignments/jjupdates?api-version=2021-09-01-preview" `
-Method PUT `
-Payload '{
  "properties": {
    "maintenanceConfigurationId": "/subscriptions/82fb79bf-ee69-4a57-a76c-26153e544afe/resourcegroups/jjdevv2-infra/providers/microsoft.maintenance/maintenanceconfigurations/jjupdates"
  },
  "location": "westeurope"
}'