// ---------------------------------------------------------------------------
// Common parameters for all modules
// ---------------------------------------------------------------------------

@minLength(1)
@maxLength(24)
@description('The name of your project')
param projectName string

@minLength(1)
@maxLength(10)
@description('The name of the environment')
param environment string

@description('The Azure region where all resources will be created')
param location string = resourceGroup().location

@description('Tags for the resources')
param tags object = {}

// ---------------------------------------------------------------------------
// Resource-specific parameters
// ---------------------------------------------------------------------------

@description('Database options')
param options object = {}

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

var type = contains(options, 'type') ? options.type : 'NoSQL'
var kind = type == 'MongoDB' ? 'MongoDB' : 'GlobalDocumentDB'
// TODO: tier: free, serverless, standard

// ---------------------------------------------------------------------------
var maxLengthProjectName = 20
var maxLengthEnvironment = 6
var maxLengthUid = 10

var shortProjectName = length(projectName) > maxLengthProjectName ? substring(projectName, 0, maxLengthProjectName) : projectName
var shortEnvironment = length(environment) > maxLengthEnvironment ? substring(environment, 0, maxLengthEnvironment) : environment
var uid = substring(uniqueString(resourceGroup().id, projectName, environment, location), 0, maxLengthUid)

// Construct the name ensuring it doesn't exceed 50 characters
var cosmosDbName = 'db-${shortProjectName}-${shortEnvironment}-${uid}'

// Azure Cosmos DB
// https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts?pivots=deployment-language-bicep
resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: cosmosDbName
  location: location
  tags: tags
  kind: kind
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    // enableMultipleWriteLocations: false
    // enableFreeTier: false
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: location
        // isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    backupPolicy: {
      type: 'Continuous'
    }
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output databaseName string = cosmosDb.name
