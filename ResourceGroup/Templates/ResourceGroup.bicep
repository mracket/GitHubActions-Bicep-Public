targetScope = 'subscription'
param Location string
param ResourceGroups array

resource resourcegroups 'Microsoft.Resources/resourceGroups@2021-01-01' = [for ResourceGroup in ResourceGroups: {
  location: Location
  name: ResourceGroup
}]
