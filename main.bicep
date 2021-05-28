//main file

param location string = resourceGroup().location

//storage account parameters
param storageName string = 'storage${uniqueString(resourceGroup().id)}'
param conatiners array = [
  'scripts'
  'inovices'
]
param storageGeoRedundant bool = false

module storage 'storage/storage.bicep' = {
  name: 'storageDeploy'
  params: {
    storageName: storageName
    storageType: storageGeoRedundant ? 'Standard_GRS' : 'Standard_LRS'
    containers: conatiners
    location: location
  }
}

output urls string = storage.outputs.storageId
