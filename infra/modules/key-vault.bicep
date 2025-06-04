param name string
param location string = resourceGroup().location
param roleAssignments array = []

// This variable contains a dictionary of Key Vault role assignments
var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  'Key Vault Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  )
  'Key Vault Certificates Officer': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'a4417e6f-fecd-4de8-b567-7b0420556985'
  )
  'Key Vault Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f25e0fa2-a7c8-4377-a976-54943a77a395'
  )
  'Key Vault Crypto Officer': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
  )
  'Key Vault Crypto Service Encryption User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'e147488a-f6f5-4113-8e2d-b22465e65bf6'
  )
  'Key Vault Crypto User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '12338af0-0e69-4776-bea7-57ae8d297424'
  )
  'Key Vault Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '21090545-7ca7-4776-b22c-e363652d74d2'
  )
  'Key Vault Secrets Officer': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  )
  'Key Vault Secrets User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '4633458b-17de-408a-b874-0445c86b69e6'
  )
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Role Based Access Control Administrator (Preview)': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
  )
  'User Access Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  )
}

// This variable adds some default role assignments to Key Vault
var keyVaultRoleAssignments = union(roleAssignments, [
  {
    principalId: '68666a98-1b2d-4d1d-96fb-b1e8abc4e30d' // BCSAI2024-DEVOPS-PROFESSORS-SP
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
  {
    principalId: '25d8d697-c4a2-479f-96e0-15593a830ae5' // BCSAI2024-DEVOPS-STUDENTS-A-SP
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
  {
    principalId: '37841ca3-42b3-4aed-b215-44d6f5dcb57d' // BCSAI2024-DEVOPS-STUDENTS-B-SP
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
  {
    principalId: '1fee20df-1b46-48ed-bc43-a7d0fe35c97f' // BCSAI2024-DEVOPS-RETAKERS-SP
    roleDefinitionIdOrName: 'Key Vault Secrets User'
    principalType: 'ServicePrincipal'
  }
  {
    principalId: 'fcfa69a8-e29f-4583-964e-a16920f6e4f6' // BCSAI2024-DEVOPS-PROFESSORS
    roleDefinitionIdOrName: 'Key Vault Administrator'
    principalType: 'Group'
  }
  {
    principalId: 'a03130df-486f-46ea-9d5c-70522fe056de' // BCSAI2024-DEVOPS-STUDENTS-A
    roleDefinitionIdOrName: 'Key Vault Administrator'
    principalType: 'Group'
  }
  {
    principalId: 'daa3436a-d1fb-44fe-b34b-053db433cdb7' // BCSAI2024-DEVOPS-STUDENTS-B
    roleDefinitionIdOrName: 'Key Vault Administrator'
    principalType: 'Group'
  }
  {
    principalId: '92f48d29-2ae1-41e3-b83e-e95e39950343' // BCSAI2024-DEVOPS-RETAKERS
    roleDefinitionIdOrName: 'Key Vault Administrator'
    principalType: 'Group'
  }
])

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  properties: {
    enabledForDeployment: true
    enableRbacAuthorization: true
    enableSoftDelete: false
    enabledForTemplateDeployment: true
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}

resource keyVault_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (keyVaultRoleAssignment, index) in (keyVaultRoleAssignments ?? []): {
    name: guid(keyVault.id, keyVaultRoleAssignment.principalId, keyVaultRoleAssignment.roleDefinitionIdOrName)
    properties: {
      roleDefinitionId: builtInRoleNames[?keyVaultRoleAssignment.roleDefinitionIdOrName] ?? keyVaultRoleAssignment.roleDefinitionIdOrName
      principalId: keyVaultRoleAssignment.principalId
      description: keyVaultRoleAssignment.?description
      principalType: keyVaultRoleAssignment.?principalType
      condition: keyVaultRoleAssignment.?condition
      conditionVersion: !empty(keyVaultRoleAssignment.?condition) ? (keyVaultRoleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: keyVaultRoleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: keyVault
  }
]
