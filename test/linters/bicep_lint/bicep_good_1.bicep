param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'example-plan'
  location: location
  sku: {
    name: 'F1'
  }
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: 'example-webapp'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}
