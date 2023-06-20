param location string = 'Global'
param fdName string = 'jjazfd'
param privateLinkLbId string = '/subscriptions/eb1d6021-9f80-4613-b383-2bd8c4d31f09/resourceGroups/mc_jjmicroservices-rg_jjazaks_westeurope/providers/Microsoft.Network/privateLinkServices/pls-ac8a852e666174ad5a99ab3134022c9c'
// docs: https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.cdn/front-door-premium-waf-managed/main.bicep

resource fd 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: fdName
  location: location
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource fdEndpoint1 'Microsoft.Cdn/profiles/afdEndpoints@2022-11-01-preview' = {
  parent: fd
  name: fdName
  location: location
  properties: {
    enabledState: 'Enabled'
  }
}

resource fdOriginGroupDefault 'Microsoft.Cdn/profiles/originGroups@2022-11-01-preview' = {
  parent: fd
  name: 'default-origin-group'
  properties: {
    healthProbeSettings: {
      probeProtocol: 'Http'
      probePath: '/'
      probeRequestType: 'HEAD'
      probeIntervalInSeconds: 100
    }
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
  }
}

resource fdOriginDefault 'Microsoft.Cdn/profiles/originGroups/origins@2022-11-01-preview' = {
  parent: fdOriginGroupDefault
  name: 'default-origin'
  properties: {
    hostName: '10.4.2.250'
    httpPort: 80
    httpsPort: 443
    originHostHeader: '10.4.2.250'
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    sharedPrivateLinkResource: {
      privateLink: {
        id: privateLinkLbId
      }
      privateLinkLocation: 'westeurope'
      requestMessage: fdName
    }
    enforceCertificateNameCheck: true
  }
}

resource fdRouteDefault 'Microsoft.Cdn/profiles/afdendpoints/routes@2022-11-01-preview' = {
  parent: fdEndpoint1
  name: 'default-route'
  properties: {
    originGroup: {
      id: fdOriginGroupDefault.id
    }
    enabledState: 'Enabled'
    forwardingProtocol: 'HttpOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
  }
}

resource fdSecurityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2022-11-01-preview' = {
  parent: fd
  name: 'waf-policy'
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: wafSecurityPolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: fdEndpoint1.id
            }
          ]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
    }
  }
}

resource wafSecurityPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = {
  location: location
  name: '${fdName}waf'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
      requestBodyCheck: 'Enabled'
    }
    customRules: {
      rules: [
        {
          name: 'geocheck'
          priority: 100
          ruleType: 'MatchRule'
          matchConditions: [
            {
              matchVariable: 'SocketAddr'
              operator: 'GeoMatch'
              negateCondition: true
              matchValue: [
                'CZ'
                'GB'
                'NL'
              ]
            }
          ]
          action: 'Block'
        }
      ]
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.0'
          ruleSetAction: 'Block'
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '1.0'
          ruleSetAction: 'Block'
        }
      ]
    }
  }
}
