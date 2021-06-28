module virtualNetworkGateway './Templates/VirtualNetworkGateway.bicep' = {
  name: 'VirtualNetworkGateway'
  params: {
    enableBGP: false
    gatewayType: 'Vpn'
    location: resourceGroup().location
    PublicIpAddressName: 'pip-vng-sharedservices-001'
    rgName: resourceGroup().name 
    sku: 'Basic'
    SubnetName: 'GatewaySubnet'
    virtualNetworkGatewayName: 'vng-sharedservices-001'
    VirtualNetworkName: 'vnet-sharedservices-001'
    vpnType: 'RouteBased'
  }
}
module localNetworkGateway './Templates/LocalNetworkGateway.bicep' = {
  name: 'LocalNetworkGateway'
  params: {
    addressPrefixes: [
      '192.168.1.0/24'
      '192.168.10.0/24'
    ]
    gatewayIpAddress: '80.80.80.80'
    localNetworkGatewayName: 'lng-sharedservices-001'
    location: resourceGroup().location
  }
}

module connection './Templates/Connection.bicep' = {
  name: 'connection'
  params: {
    connectionName: 'cnt-sharedservices-001'
    connectionType: 'IPSec'
    enableBgp: false
    localNetworkGatewayId: localNetworkGateway.outputs.lngid
    location: resourceGroup().location
    sharedKey: 'InsertSharedSecret'
    virtualNetworkGatewayId: virtualNetworkGateway.outputs.vngid
  }
}
