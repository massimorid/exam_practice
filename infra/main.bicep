param userAlias string = 'mridella'
param keyVaultName string = '${userAlias}-kv'
param location string = resourceGroup().location
param containerRegistryName string
param appServicePlanName string 
param appServiceContainerBackendName string

//Deploy Key VaulT
module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    name: keyVaultName
  }
}

module containerRegistry 'modules/container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    name: containerRegistryName
  }
}

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    skuName: 'B1'
  }
}

//Deploy App Service Container
module appServiceContainer 'modules/azure-webapp.bicep' = {
  name: 'appServiceContainer'
  params: {
    location: location
    name: appServiceContainerBackendName
    kind: 'app'
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/backend:latest'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      WEBSITES_PORT: '8080'
      ENV: 'development'
    }
    dockerRegistryServerUrl: 'https://${containerRegistryName}.azurecr.io'
    dockerRegistryServerUserName: containerRegistry.outputs.acrUsername
    dockerRegistryServerPassword: containerRegistry.outputs.acrPassword0
  }
}
