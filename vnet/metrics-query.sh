# Get metrics for my VPN tunel

# How to use Azure REST API https://mauridb.medium.com/calling-azure-rest-api-via-curl-eb10a06127

az rest -m get --header "Accept=application/json" -u "https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/JJDevV2-Infra/providers/Microsoft.Network/virtualNetworkGateways/jjdevv2vpngw/providers/microsoft.Insights/metrics?timespan=2021-12-01T13:30:00.000Z/2021-12-02T13:45:00.000Z&interval=PT15M&metricnames=TunnelIngressBytes&aggregation=total&metricNamespace=microsoft.network%2Fvirtualnetworkgateways&top=10&orderby=total desc&$filter=RemoteIP eq '*'&autoadjusttimegrain=true&validatedimensions=false&api-version=2019-07-01"