targetScope = 'subscription'
param Location string = 'WestEurope'
param companyPrefix string = 'bicep'

var ResourceGroups = [  
  'rg-${companyPrefix}-sharedservices-network-001'
  'rg-${companyPrefix}-sharedservices-vm-001'
  'rg-${companyPrefix}-citrix-network-001'
  'rg-${companyPrefix}-citrix-vm-001'
  'rg-${companyPrefix}-citrix-workers-001'  
]

module resourceGroups 'Templates/ResourceGroup.bicep' = {
  name: 'DeployResourceGroups'
  params: {
    Location: Location
    ResourceGroups: ResourceGroups
  }
  scope: subscription()
}
