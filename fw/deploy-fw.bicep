param fwName string = 'jjazfw'
param fwTier string = 'Premium' // Standard or Premium
param location string = 'westeurope'

param virtualNetworkName string = 'jjazhubvnet'
param publicIpPrefix string = 'jjaz-pip'

// reference existing network resources
resource fwVnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: virtualNetworkName
}
resource fwSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: fwVnet
  name: 'AzureFirewallSubnet'
}
resource ipprefix 'Microsoft.Network/publicIPPrefixes@2021-02-01' existing = {
  name: publicIpPrefix
}

// --------------------------
// --- Firewall resources ---
// --------------------------
// LIMITS: 
//    https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-firewall-limits
//    10,000 unique source/destinations in network rules
//    298 is maximum number of DNAT rules
//    Network and Application rules cannot be combined in one Rule collection !!!
//    Application rules must has lower priority NAT/Network rule !!!
resource fwPublicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${fwName}-ip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: fwName
    }
    publicIPPrefix: {
      id: ipprefix.id
    }
  }
}

resource fw 'Microsoft.Network/azureFirewalls@2021-02-01' = {
  name: fwName
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  dependsOn: [
    fwPolicyRule
    fwPolicyRule2
  ]
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: fwTier
    }
    threatIntelMode: 'Alert'
    additionalProperties: {}
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: fwSubnet.id
          }
          publicIPAddress: {
            id: fwPublicIp.id
          }
        }
      }
    ]
    networkRuleCollections: []
    applicationRuleCollections: []
    natRuleCollections: []
    firewallPolicy: {
      id: fwPolicy.id
    }
  }
}

resource fwPolicy 'Microsoft.Network/firewallPolicies@2021-02-01' = {
  name: '${fwName}-policy'
  location: location
  properties: {
    sku: {
      tier: fwTier
    }
    dnsSettings: {
      enableProxy: true
      servers: []
    }
  }
}

resource fwPolicyRule 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-02-01' = {
  parent: fwPolicy
  name: 'CoreRules'
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'RdpConnect'
        priority: 100
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        action: {
          type: 'DNAT'
        }
        rules: [
          {
            ruleType: 'NatRule'
            name: 'Rdp-jjdevv2addc'
            translatedAddress: '10.3.250.10'
            translatedPort: '3389'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              fwPublicIp.properties.ipAddress
            ]
            destinationPorts: [
              '3389'
            ]
          }
        ]
      }
      {
        name: 'Console'
        priority: 1000
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'RDP'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.3.0.0/16'
              '10.4.0.0/16'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '3389'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'SSH'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.3.0.0/16'
              '10.4.0.0/16'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '22'
            ]
          }
        ]
      }
      {
        name: 'CoreServices'
        priority: 1003
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Ping'
            ipProtocols: [
              'ICMP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'DNStoAD'
            ipProtocols: [
              'UDP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '53'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'NTPLinux'
            ipProtocols: [
              'UDP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '123'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'LDAPtoAD, Kerberos'
            ipProtocols: [
              'TCP'
              'UDP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.3.250.10'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '389'
              '88'
              '135'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'AAD'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              'AzureActiveDirectory'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '443'
            ]
          }          
          {
            ruleType: 'NetworkRule'
            name: 'AzureGlobalKMS'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '23.102.135.246'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '1688'
            ]
          }
        ]
      }     
      {
        name: 'CoreServicesPaaS'
        priority: 1030
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'management'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              //'management.azure.com'
              split(environment().resourceManager, '/')[2]
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'login'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [              
              //'login.microsoftonline.com'
              split(environment().authentication.loginEndpoint, '/')[2]
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
        ]
      }           
      {
        name: 'Updates'
        priority: 1010
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Windows Update'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: [
              'WindowsUpdate'
            ]
            targetFqdns: []
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'LinuxUpdates'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
            ]
            fqdnTags: []
            targetFqdns: [
              'security.ubuntu.com'
              'azure.archive.ubuntu.com'
              'changelogs.ubuntu.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'MsPackages'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              'packages.microsoft.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
        ]
      }      
      {
        name: 'CorePaaS'
        priority: 1020
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Monitoring'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              '*.ods.opinsights.azure.com'
              '*.oms.opinsights.azure.com'
              '*.monitoring.azure.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'ADsync'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              '*.servicebus.windows.net'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '10.3.250.10'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Automation'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              '*.azure-automation.net'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'SiteRecovery'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              '*.servicebus.windows.net'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'ATP'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              'winatp-gw-neu.microsoft.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Core'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: [
              'WindowsDiagnostics'
              'AzureBackup'
              'MicrosoftActiveProtectionService'
            ]
            targetFqdns: []
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'MonitorQualys'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              '*.apps.qualys.eu'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'monitoring'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              '*.westeurope.monitoring.azure.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
        ]
      }      
    ]
  }
}

resource fwPolicyRule2 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-02-01' = {
  parent: fwPolicy
  name: 'WebRules'
  dependsOn: [
    fwPolicyRule
  ]
  properties: {
    priority: 200
    ruleCollections: [
      {
        name: 'HttpPublish'
        priority: 100
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        action: {
          type: 'DNAT'
        }
        rules: [
          {
            ruleType: 'NatRule'
            name: 'HttpAppGw'
            translatedAddress: '10.3.253.10'
            translatedPort: '80'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              fwPublicIp.properties.ipAddress
            ]
            destinationPorts: [
              '80'
            ]
          }
        ]
      }
      {
        name: 'Web'
        priority: 1001
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'HTTPtoApp'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '10.3.0.0/16'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.4.0.0/16'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '80'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'HTTPtoJJDEVBR1'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '10.3.0.0/16'
              '10.4.0.0/16'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.1.0.0/16'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '80'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'HTTPAppGwtoADDC'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '10.3.253.0/24'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.3.250.0/24'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '80'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'HTTPADDCtoAppGW'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '10.3.250.0/24'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.3.253.0/24'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '80'
              '8080'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'HTTPADDCtoApiMngmt'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '10.3.250.0/24'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.3.251.0/24'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '80'
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'HTTPAppGwtoApiMngmt'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              '10.3.253.0/24'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '10.3.251.0/24'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '80'
              '443'
            ]
          }
        ]
      }
      {
        name: 'AKS'
        priority: 1005
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'AksInternal'
            ipProtocols: [
              'UDP'
              'TCP'
            ]
            sourceAddresses: [
              '10.4.2.0/24'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '9000'
              '1194'
            ]
          }
        ]
      } 
      {
        name: 'AKSPaaS'
        priority: 1030
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'api'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              '*.hcp.westeurope.azmk8s.io'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'repo'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              'aksrepos.azurecr.io'
              'quay.io'
              '*.quay.io'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'packages'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              'packages.microsoft.com'
              'api.snapcraft.io'
              'motd.ubuntu.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'api endpoint'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              '*.tun.westeurope.azmk8s.io'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'storage'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              //'*.blob.core.windows.net'
              '*.blob.${environment().suffixes.storage}'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'mcr'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              'mcr.microsoft.com'
              '*.mcr.microsoft.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'cdn'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              '*.cdn.mscr.io'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'acs-mirror.azureedge.net'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              'acs-mirror.azureedge.net'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'devops'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              '*.services.visualstudio.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }          
          {
            ruleType: 'ApplicationRule'
            name: 'events'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              '*.events.data.microsoft.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'gcp'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              'k8s.gcr.io'
              'storage.googleapis.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'jjappconfig'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              'jjaksconfig.azconfig.io'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'jjrepo'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            targetFqdns: [
              'jjakscontainers.azurecr.io'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AKSservice'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: [
              'AzureKubernetesService'
            ]
            targetFqdns: []
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '10.4.2.0/24'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
        ]
      }
    ]
  }
}

// --------------------------
// --- Route tables       ---
// --------------------------
resource routeTablesNameInfra 'Microsoft.Network/routeTables@2019-07-01' = {
  name: 'jjazhubvnet-infra-rt'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'InternetToFw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'JJBR1toFw'
        properties: {
          addressPrefix: '10.1.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'JJBR1toFw-router'
        properties: {
          addressPrefix: '10.1.0.10/32'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'SpokeAppToFw'
        properties: {
          addressPrefix: '10.4.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'HubAppgwtToFw'
        properties: {
          addressPrefix: '10.3.253.0/24'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'HubApiMngmtToFw'
        properties: {
          addressPrefix: '10.3.251.0/24'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource routeTablesNameVpn 'Microsoft.Network/routeTables@2019-07-01' = {
  name: 'jjazhubvnet-vpn-rt'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'HubToFw'
        properties: {
          addressPrefix: '10.3.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'SpokeAppToFw'
        properties: {
          addressPrefix: '10.4.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'Subnet'
        properties: {
          addressPrefix: '10.3.0.0/24'
          nextHopType: 'VnetLocal'
        }
      }
    ]
  }
}

resource routeTablesNameAppGw 'Microsoft.Network/routeTables@2019-07-01' = {
  name: 'jjazhubvnet-appgw-rt'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'JJBR1toFw'
        properties: {
          addressPrefix: '10.1.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'JJBR1toFw-router'
        properties: {
          addressPrefix: '10.1.0.10/32'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'SpokeAppToFw'
        properties: {
          addressPrefix: '10.4.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'HubInfraToFw'
        properties: {
          addressPrefix: '10.3.250.0/24'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'HubApiMngmtToFw'
        properties: {
          addressPrefix: '10.3.251.0/24'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource routeTablesNameApiMngmt 'Microsoft.Network/routeTables@2019-07-01' = {
  name: 'jjazhubvnet-apimngmt-rt'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'SpokeAppToFw'
        properties: {
          addressPrefix: '10.4.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'HubInfraToFw'
        properties: {
          addressPrefix: '10.3.250.0/24'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'HubAppgwtToFw'
        properties: {
          addressPrefix: '10.3.253.0/24'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

resource routeTablesNameSpokeApp 'Microsoft.Network/routeTables@2019-07-01' = {
  name: 'jjazappvnet-default-rt'
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'InternetToFw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'HubAppgwtToFw'
        properties: {
          addressPrefix: '10.3.253.0/24'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'HubInfraToFw'
        properties: {
          addressPrefix: '10.3.250.0/24'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'HubApiMngmtToFw'
        properties: {
          addressPrefix: '10.3.251.0/24'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'JJBR1toFw'
        properties: {
          addressPrefix: '10.1.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'JJBR1toFw-router'
        properties: {
          addressPrefix: '10.1.0.10/32'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fw.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}
