param location string
param storageName string
param storageType string
param containers array

resource hqstorageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageType
  }
}


resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' =  [ for contName in containers: {
  name: '${hqstorageaccount}/default/${contName}'
}]

output storageId string = hqstorageaccount.properties.primaryEndpoints.blob
