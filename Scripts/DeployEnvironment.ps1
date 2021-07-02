param (
   $ConfigFile = "..\GithubActionsBlog\Configuration\Variables.json"
)
  
# Get JSON content from file
$Config = Get-Content -Raw -Path $ConfigFile | ConvertFrom-Json
Get-AzContext 
# Create resource groups
foreach ($ResourceGroup in $Config.ResourceGroups) {
   $TestResourceGroup = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue
   
   If($TestResourceGroup.Length -eq 0) {
      New-AzResourceGroup -Name $ResourceGroup -Location $Config.location
   }    
}

$SharedSubnets = @()
foreach ($subnet in $($Config.SharedService_vNet.Subnets)) {
   $SharedSubnets += @{
      Name = $subnet.SubnetName
      Prefix = $subnet.SubnetPrefix
   }
}
# Shared service vNet Creation
$SharedServicevNetParams = New-Object -TypeName hashtable 
$SharedServicevNetParams['vNetName']    = $Config.SharedService_vNet.Name
$SharedServicevNetParams['location']    = $Config.Location
$SharedServicevNetParams['Prefix']      = $Config.SharedService_vNet.vNetPrefix
$SharedServicevNetParams['dnsServers']  = $Config.SharedService_vNet.vNetDNSServers 
$SharedServicevNetParams['Subnets']     = $SharedSubnets
New-AzResourceGroupDeployment -Name "vNet" -ResourceGroupName $($Config.SharedService_vNet.ResourceGroup) -Mode Incremental -TemplateFile ..\GithubActionsBlog\Network\Templates\vNet.bicep -TemplateParameterObject $SharedServicevNetParams 

# Citrix vNet Creation
$CitrixSubnets = @()
foreach ($subnet in $($Config.Citrix_vNet.Subnets)) {
   $CitrixSubnets += @{
      Name = $subnet.SubnetName
      Prefix = $subnet.SubnetPrefix
   }
}
$CitrixvNetParams = New-Object -TypeName hashtable 
$CitrixvNetParams['vNetName']    = $Config.Citrix_vNet.Name
$CitrixvNetParams['location']    = $Config.Location
$CitrixvNetParams['Prefix']      = $Config.Citrix_vNet.vNetPrefix
$CitrixvNetParams['dnsServers']  = $Config.Citrix_vNet.vNetDNSServers 
$CitrixvNetParams['Subnets']     = $CitrixSubnets
New-AzResourceGroupDeployment -Name "vNet" -ResourceGroupName $($Config.Citrix_vNet.ResourceGroup) -Mode Incremental -TemplateFile ..\GithubActionsBlog\Network\Templates\vNet.bicep -TemplateParameterObject $CitrixvNetParams 

# Create virtual network gateway
$VNGParams = New-Object -TypeName hashtable 
$VNGParams['virtualNetworkGatewayName']   = $Config.VPN.VirtualNetworkGateway.virtualNetworkGatewayName
$VNGParams['VirtualNetworkName']          = $Config.VPN.VirtualNetworkGateway.VirtualNetworkName
$VNGParams['SubnetName']                  = $Config.VPN.VirtualNetworkGateway.SubnetName
$VNGParams['sku']                         = $Config.VPN.VirtualNetworkGateway.sku
$VNGParams['rgName']                      = $Config.VPN.VirtualNetworkGateway.ResourceGroup
$VNGParams['PublicIpAddressName']         = $Config.VPN.VirtualNetworkGateway.PublicIpAddressName
$VNGParams['gatewayType']                 = $Config.VPN.VirtualNetworkGateway.gatewayType
$VNGParams['enableBGP']                   = $Config.VPN.VirtualNetworkGateway.enableBGP
$VNGParams['location']                    = $Config.location
$VNG = New-AzResourceGroupDeployment -Name "VNG" -ResourceGroupName $($Config.VPN.VirtualNetworkGateway.ResourceGroup) -Mode Incremental -TemplateFile ..\GithubActionsBlog\Network\Templates\VirtualNetworkGateway.bicep -TemplateParameterObject $VNGParams 

# Create local network gateway
$LNGParams = New-Object -TypeName hashtable 
$LNGParams['addressPrefixes'] = $Config.VPN.LocalNetworkGateway.LocalAddressPrefixes
$LNGParams['gatewayIpAddress']         = $Config.VPN.LocalNetworkGateway.LocalGatewayPublicIP
$LNGParams['localNetworkGatewayName']  = $Config.VPN.LocalNetworkGateway.LocalGatewayName
$LNGParams['location']                 = $Config.location
$LNG = New-AzResourceGroupDeployment -Name "LNG" -ResourceGroupName $($Config.VPN.LocalNetworkGateway.ResourceGroup) -Mode Incremental -TemplateFile ..\GithubActionsBlog\Network\Templates\LocalNetworkGateway.bicep -TemplateParameterObject $LNGParams 

# Create VPN connection
$CNTParams = New-Object -TypeName hashtable 
$CNTParams['connectionName']           = $Config.VPN.Connection.connectionName
$CNTParams['connectionType']           = $Config.VPN.Connection.connectionType
$CNTParams['enableBgp']                = $Config.VPN.Connection.enableBgp
$CNTParams['location']                 = $Config.location
$CNTParams['sharedKey']                = $Config.VPN.Connection.sharedKey
$CNTParams['localNetworkGatewayId']    = $LNG.Outputs['lngid'].value
$CNTParams['virtualNetworkGatewayId']  = $VNG.Outputs['vngid'].value
New-AzResourceGroupDeployment -Name "CNT" -ResourceGroupName $($Config.VPN.Connection.ResourceGroup) -Mode Incremental -TemplateFile ..\GithubActionsBlog\Network\Templates\Connection.bicep -TemplateParameterObject $CNTParams 

# Create Citrix Cloud Connectors
$CCParams = New-Object -TypeName hashtable 
$CCParams['availabilitySetName']                                           = $Config.CloudConnectors.availabilitySetName
$CCParams['availabilitySetPlatformFaultDomainCount']                       = $Config.CloudConnectors.availabilitySetPlatformFaultDomainCount
$CCParams['availabilitySetPlatformUpdateDomainCount']                      = $Config.CloudConnectors.availabilitySetPlatformUpdateDomainCount
$CCParams['CCVMPrefix']                                                    = $Config.CloudConnectors.CCVMPrefix
$CCParams['domainFQDN']                                                    = $Config.CloudConnectors.domainFQDN
$CCParams['domainJoinUserName']                                            = $Config.CloudConnectors.domainJoinUserName
$CCParams['domainJoinUserPassword']                                        = $Config.CloudConnectors.domainJoinUserPassword
$CCParams['location']                                                      = $Config.location
$CCParams['OS']                                                            = $Config.CloudConnectors.OS
$CCParams['ouPath']                                                        = $Config.CloudConnectors.ouPath
$CCParams['SubnetName']                                                    = $Config.CloudConnectors.SubnetName
$CCParams['virtualMachineCount']                                           = $Config.CloudConnectors.virtualMachineCount
$CCParams['VMSize']                                                        = $Config.CloudConnectors.VMSize
$CCParams['vNetName']                                                      = $Config.CloudConnectors.vNetName
$CCParams['VMUserName']                                                    = $Config.CloudConnectors.VMUserName
$CCParams['vNetResourceGroup']                                             = $Config.CloudConnectors.vNetResourceGroup
$CCParams['VMPassword']                                                    = $Config.CloudConnectors.VMPassword
New-AzResourceGroupDeployment -Name "CitrixCloudConnectors" -ResourceGroupName $($Config.CloudConnectors.ResourceGroup) -Mode Incremental -TemplateFile ..\GithubActionsBlog\VirtualMachine\Templates\CitrixCloudConnector.bicep -TemplateParameterObject $CCParams