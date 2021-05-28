param location string = resourceGroup().location
param vmname string
param vmsize string
@allowed([
  'Basic'
  'Standard'
])
param publicIpAddressSku string
param osDiskType string
param adminUsername string
@secure()
param adminPassword string

//network card
var networkInterfaceName = '${vmname}-interface'
var publicIpName = '${vmname}-ip'
var nsgName = '${vmname}-nsg'
var vnetName = '${vmname}-vnet'
var vnetPrefixes = [
  '10.0.0.0/16'
]
var subnetName = 'default'
var vnetSubnets = [
  {
    name: subnetName
    properties: {
      addressPrefix: '10.0.0.0/24'
    }
  }
]

var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', nsgName)
var vnetId = resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', vnetName)
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource simplevm_networkcard 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpName)
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    simplevm_nsg
    simplevm_network
    simplevm_ip
  ]
}

resource simplevm_nsg 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 300
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange:'22'
        }
      }
    ]
  }
}

resource simplevm_network 'Microsoft.Network/virtualNetworks@2019-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetPrefixes
    }
    subnets: vnetSubnets
  }
}

resource simplevm_ip 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpAddressSku
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource simplevm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmname
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmsize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: simplevm_networkcard.id
        }
      ]
    }
    osProfile: {
      computerName: vmname
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output adminUsername string = adminUsername
