targetScope = 'subscription'
param companyPrefix string = 'bicep'
var Location = 'WestEurope'
var Sharedservice_ResourceGroup = 'rg-${companyPrefix}-sharedservices-network-001'
var Sharedservice_vNet_Name = 'vnet-${companyPrefix}-sharedservices-001'
var Sharedservice_vNet_Prefix = '172.16.0.0/16'
var Sharedservice_vNet_Subnets = [
  {
    Name: 'GatewaySubnet'
    Prefix: '172.16.0.0/26'
  }
  {
    name: 'snet-sharedservices-adds-001'
    prefix: '172.16.0.64/26'
  }      
]
var Sharedservice_vNet_dnsServers = [
  '192.168.10.10'
]
var Citrix_ResourceGroup = 'rg-${companyPrefix}-citrix-network-001'
var Citrix_vNetName = 'vnet-${companyPrefix}-citrix-001'
var Citrix_vNet_Prefix = '172.17.0.0/16'
var Citrix_vNet_Subnets = [
  {
    Name: 'snet-citrix-vm-001'
    Prefix: '172.17.0.0/26'
  }
  {
    name: 'snet-citrix-workers-001'
    prefix: '172.17.1.0/24'
  }
  {
    name: 'snet-citrix-workers-002'
    prefix: '172.17.2.0/24'
  }
]
var Citrix_vNet_dnsServers = [
  '192.168.10.10'
]

module CitrixvNet './Templates/vNet.bicep' = {
  name: 'Citrix-vNet-Deployment'
  params: {
    dnsServers: Citrix_vNet_dnsServers
     Location: Location
     Subnets: Citrix_vNet_Subnets
     vNetName: Citrix_vNetName
     Prefix: Citrix_vNet_Prefix
  }
  dependsOn: [
    SharedservicevNet
  ]
  scope: resourceGroup(Citrix_ResourceGroup)
}

module SharedservicevNet './Templates/vNet.bicep' = {
  name: 'Sharedservice-vNet-Deployment'
  params: {
    dnsServers: Sharedservice_vNet_dnsServers
     Location: Location
     Subnets: Sharedservice_vNet_Subnets
     vNetName: Sharedservice_vNet_Name
     Prefix: Sharedservice_vNet_Prefix
  }
  scope: resourceGroup(Sharedservice_ResourceGroup)
}

module CitrixPeering './Templates/Peering.bicep' = {
  name: 'CitrixvNetPeering'
  params: {
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    remoteResourceGroup: 'rg-${companyPrefix}-sharedservices-network-001'
    remoteVirtualNetworkName: 'vnet-${companyPrefix}-sharedservices-001'
    useRemoteGateways: true
    virtualNetworkName: CitrixvNet.outputs.name
  }
  dependsOn: [
    CitrixvNet
  ]
  scope: resourceGroup(Citrix_ResourceGroup)
}
module SharedservicePeering './Templates/Peering.bicep' = {
  name: 'SharedServicevNetPeering'
  params: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    allowVirtualNetworkAccess: true
    remoteResourceGroup: 'rg-${companyPrefix}-citrix-network-001'
    remoteVirtualNetworkName: 'vnet-${companyPrefix}-citrix-001'
    useRemoteGateways: false
    virtualNetworkName: SharedservicevNet.outputs.name
  }
  dependsOn: [
    CitrixPeering
  ]
  scope: resourceGroup(Sharedservice_ResourceGroup)
}
