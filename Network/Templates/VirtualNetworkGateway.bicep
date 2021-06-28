param virtualNetworkGatewayName string 
param rgName string 
param location string = resourceGroup().location
param sku string 

@allowed([
  'Vpn'
  'ExpressRoute'
])
param gatewayType string = 'Vpn'

@allowed([
  'RouteBased'
  'PolicyBased'
])
param vpnType string = 'RouteBased'
param VirtualNetworkName string 
param SubnetName string = 'GatewaySubnet'
param PublicIpAddressName string 
param enableBGP bool = false

resource PublicIpAddressName_resource 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: PublicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource virtualNetworkGateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = {
  name: virtualNetworkGatewayName
  location: location
  properties: {
    gatewayType: gatewayType
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(rgName, 'Microsoft.Network/virtualNetworks/subnets', VirtualNetworkName, SubnetName)
          }
          publicIPAddress: {
            id: resourceId(rgName, 'Microsoft.Network/publicIPAddresses', PublicIpAddressName)
          }
        }
      }
    ]
    vpnType: vpnType
    enableBgp: enableBGP
    sku: {
      name: sku
      tier: sku
    }
  }
  dependsOn: [
    PublicIpAddressName_resource
  ]
}
output vngid string = virtualNetworkGateway.id

