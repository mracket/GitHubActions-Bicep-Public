param companyPrefix string = 'bicep'

module citrixcloudconnector './Templates/CitrixCloudConnector.bicep' = {
  name: 'CitrixCloudConnector'
  params: {
    availabilitySetName: 'as-citrix-001'
    availabilitySetPlatformFaultDomainCount: 2
    availabilitySetPlatformUpdateDomainCount: 5
    CCVMPrefix: 'vm-ctx-cc'
    domainFQDN: 'citrixlab.dk'
    domainJoinUserName: 'domainjoin'
    domainJoinUserPassword: 'InsertPassword'
    location: resourceGroup().location
    OS: 'Server2019'
    ouPath: 'InsertOUPath'
    SubnetName: 'snet-citrix-vm-001'
    virtualMachineCount: 2
    VMPassword: 'InsertPassword'
    VMSize: 'Standard_B2ms'
    VMUserName: 'azureadmin'
    vNetName: 'vnet-${companyPrefix}-citrix-001'
    vNetResourceGroup: 'rg-${companyPrefix}-citrix-network-001'
  }
}
