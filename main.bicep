//main file

param location string = resourceGroup().location

//storage account parameters
param storageName string = 'storage${uniqueString(resourceGroup().id)}'
param conatiners array = [
  'scripts'
  'inovices'
]
param storageGeoRedundant bool = false

//vm parameters
param vmname string = 'simplevm'
@secure()
param adminPassword string
param adminUsername string = 'domi10052'
param osDiskType string = 'Premium_LRS'
param vmsize string = 'Standard_B1ms'

module storage 'storage/storage.bicep' = {
  name: 'storageDeploy'
  params: {
    storageName: storageName
    storageType: storageGeoRedundant ? 'Standard_GRS' : 'Standard_LRS'
    containers: conatiners
    location: location
  }
}

module vm 'compute/simplevm.bicep' = {
  name: vmname
  params: {
    adminPassword: adminPassword
    location: location
    adminUsername:adminUsername
    osDiskType: osDiskType
    publicIpAddressSku: 'Basic'
    vmname: vmname
    vmsize: vmsize
  }
}

output urls string = storage.outputs.storageId
