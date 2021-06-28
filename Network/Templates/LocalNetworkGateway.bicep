param localNetworkGatewayName string
param location string = resourceGroup().location
param gatewayIpAddress string
param addressPrefixes array = []

resource localNetworkGateway 'Microsoft.Network/localNetworkGateways@2021-02-01' = {
  name: localNetworkGatewayName
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: addressPrefixes
    }
    gatewayIpAddress: gatewayIpAddress
  }
}
output lngid string = localNetworkGateway.id
