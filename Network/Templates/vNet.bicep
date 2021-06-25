param vNetName string 
param Prefix string 
param Subnets array
param Location string
param dnsServers array

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vNetName
  location: Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        Prefix
      ]
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
    subnets: [for Subnet in Subnets: {
      name: Subnet.Name
      properties: {
        addressPrefix: Subnet.Prefix
      }
    }]
  }
}
output name string = vnet.name
