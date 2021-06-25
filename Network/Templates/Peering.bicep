param virtualNetworkName string
param allowForwardedTraffic bool = true
param allowGatewayTransit bool = false
param allowVirtualNetworkAccess bool = true
param useRemoteGateways bool = true
param remoteResourceGroup string
param remoteVirtualNetworkName string

resource remotevnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: remoteVirtualNetworkName
  scope: resourceGroup(remoteResourceGroup)  
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${virtualNetworkName}/Peering-To-${remoteVirtualNetworkName}'
  properties: {
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: remotevnet.id
    }
  }
}
