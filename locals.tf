locals {
  identities = toset([
    "runner",
    "docrunner",
    "control-plane",
  ])
  repo_pool_names = tomap({
    "https://github.com/Azure/terraform" : "terraform-azurerm-doc"
    "https://github.com/Azure/terraform-azurerm-hubnetworking" : "terraform-azure-hubnetworking"
    "https://github.com/Azure/terraform-azure-container-apps" : "terraform-azurerm-container-apps"
  })
  repo_pool_max_runners = tomap({
    "https://github.com/Azure/terraform-azurerm-avm-ptn-virtualwan": 14
    "https://github.com/Azure/terraform-azurerm-avm-res-compute-disk": 5
    "https://github.com/Azure/terraform-azurerm-avm-res-network-virtualnetwork": 5
    "https://github.com/Azure/terraform-azurerm-avm-res-cdn-profile": 8
    "https://github.com/Azure/terraform-azurerm-avm-res-storage-storageaccount": 5
  })
  // Please do not delete a repo name if the repo is no longer available, put deprecated repo in this list so subnet's order won't be changed.
  bypass_set = toset([
    "https://github.com/Azure/terraform-azurerm-avm-res-authorization-roleassignment",   # needs access at higher scopes than subscription
    "https://github.com/Azure/terraform-azurerm-avm-ptn-alz",
    "https://github.com/Azure/terraform-azurerm-avm-res-storage-storageaccounts", # Would be cancelled by 1es, need further investigation
#     "https://github.com/Azure/terraform-azurerm-avm-res-insights-component",
  ])
  regions = toset(["eastus", "eastus2", "westeurope"])
  repo_region = tomap({
    "https://github.com/Azure/terraform-azurerm-avm-ptn-virtualnetworkpeering": "westeurope",
    "https://github.com/Azure/terraform-azurerm-avm-res-insights-component": "eastus2",
    "https://github.com/lonegunmanb/avm-gh-app": "eastus2",
    "https://github.com/Azure/terraform-azurerm-avm-ptn-function-app-storage-private-endpoints": "eastus2",
    "https://github.com/Azure/terraform-azurerm-avm-res-compute-disk": "eastus2",
    "https://github.com/Azure/terraform-azurerm-avm-res-cache-redis": "eastus2",
    "https://github.com/Azure/terraform-azurerm-avm-res-search-searchservice": "eastus2",
    "https://github.com/Azure/terraform-azurerm-avm-res-logic-workflow": "eastus2",
    "https://github.com/Azure/terraform-azurerm-avm-ptn-policyassignment": "eastus2",
    "https://github.com/Azure/terraform-azurerm-avm-res-network-applicationsecuritygroup": "eastus2",
    "https://github.com/Azure/terraform-azurerm-avm-res-batch-batchaccount": "eastus2",
  })
  avm_res_mod_csv = file("${path.module}/Azure-Verified-Modules/docs/static/module-indexes/TerraformResourceModules.csv")
  avm_pattern_mod_csv = file("${path.module}/Azure-Verified-Modules/docs/static/module-indexes/TerraformPatternModules.csv")
  avm_res_mod_repos = [for i in csvdecode(local.avm_res_mod_csv) : i.RepoURL]
  avm_pattern_mod_repos = [for i in csvdecode(local.avm_pattern_mod_csv) : i.RepoURL]
  repos = [for r in concat([
    "https://github.com/Azure/terraform-azurerm-aks",
    "https://github.com/Azure/terraform-azurerm-compute",
    "https://github.com/Azure/terraform-azurerm-loadbalancer",
    "https://github.com/Azure/terraform-azurerm-network",
    "https://github.com/Azure/terraform-azurerm-network-security-group",
    "https://github.com/Azure/terraform-azurerm-postgresql",
    "https://github.com/Azure/terraform-azurerm-subnets",
    "https://github.com/Azure/terraform-azurerm-vnet",
    "https://github.com/Azure/terraform-azurerm-virtual-machine",
    "https://github.com/Azure/terraform",
    "https://github.com/Azure/terraform-azurerm-hubnetworking",
    "https://github.com/Azure/terraform-azurerm-openai",
    "https://github.com/Azure/terraform-azure-mdc-defender-plans-azure",
    "https://github.com/Azure/terraform-azurerm-database",
    "https://github.com/Azure/terraform-azure-container-apps",
    "https://github.com/Azure/terraform-azurerm-avm-res-storage-storageaccounts",
    "https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault",
    "https://github.com/WodansSon/terraform-azurerm-cdn-frontdoor",
    "https://github.com/Azure/avm-gh-app",
    "https://github.com/Azure/oneesrunnerscleaner",
    "https://github.com/Azure/terraform-azurerm-avm-res-sql-instancepool",
  ], local.valid_avm_repos) : r if !contains(local.bypass_set, r)]

  repo_names = {
    for r in distinct(local.repos) : r => length(reverse(split("/", r))[0]) >= 45 ? sha1(reverse(split("/", r))[0]) : reverse(split("/", r))[0]
  }
  repos_fw = [
#    "https://github.com/lonegunmanb/terraform-azurerm-aks",
  ]
  # repos that use GitOps to manage testing infrastructures, not for verified modules
  repos_with_backend = [
    "https://github.com/lonegunmanb/TerraformModuleTelemetryService"
  ]

  repo_index = { for k, v in {
    "https://github.com/Azure/terraform-azurerm-aks" : 0,
    "https://github.com/Azure/terraform-azurerm-compute" : 1,
    "https://github.com/Azure/terraform-azurerm-loadbalancer" : 2,
    "https://github.com/Azure/terraform-azurerm-network" : 3,
    "https://github.com/Azure/terraform-azurerm-network-security-group" : 4,
    "https://github.com/Azure/terraform-azurerm-postgresql" : 5,
    "https://github.com/Azure/terraform-azurerm-subnets" : 6,
    "https://github.com/Azure/terraform-azurerm-vnet" : 7,
    "https://github.com/Azure/terraform-azurerm-virtual-machine" : 8,
    "https://github.com/Azure/terraform" : 9,
    "https://github.com/Azure/terraform-azurerm-hubnetworking" : 10,
    "https://github.com/Azure/terraform-azurerm-openai" : 11,
    "https://github.com/Azure/terraform-azure-mdc-defender-plans-azure" : 12,
    "https://github.com/Azure/terraform-azurerm-database" : 13,
    "https://github.com/Azure/terraform-azure-container-apps" : 14,
    "https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault" : 15,
    "https://github.com/WodansSon/terraform-azurerm-cdn-frontdoor" : 16,
    "https://github.com/Azure/avm-gh-app" : 17,
    "https://github.com/Azure/oneesrunnerscleaner" : 18,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-aks-production" : 19,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-alz-management" : 20,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-avd-lza-insights" : 21,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-avd-lza-managementplane" : 22,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-bcdr-vm-replication" : 23,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-cicd-agents-and-runners" : 24,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-confidential-compute" : 25,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-function-app-storage-private-endpoints" : 26,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-hubnetworking" : 27,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-network-private-link-private-dns-zones" : 28,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-policyassignment" : 29,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-virtualnetworkpeering" : 30,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-virtualwan" : 31,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-vnetgateway" : 32,
    "https://github.com/Azure/terraform-azurerm-avm-res-app-containerapp" : 33,
    "https://github.com/Azure/terraform-azurerm-avm-res-app-managedenvironment" : 34,
    "https://github.com/Azure/terraform-azurerm-avm-res-automation-automationaccount" : 35,
    "https://github.com/Azure/terraform-azurerm-avm-res-avs-privatecloud" : 36,
    "https://github.com/Azure/terraform-azurerm-avm-res-batch-batchaccount" : 37,
    "https://github.com/Azure/terraform-azurerm-avm-res-cache-redis" : 38,
    "https://github.com/Azure/terraform-azurerm-avm-res-cdn-profile" : 39,
    "https://github.com/Azure/terraform-azurerm-avm-res-cognitiveservices-account" : 40,
    "https://github.com/Azure/terraform-azurerm-avm-res-compute-disk" : 41,
    "https://github.com/Azure/terraform-azurerm-avm-res-compute-hostgroup" : 42,
    "https://github.com/Azure/terraform-azurerm-avm-res-compute-proximityplacementgroup" : 43,
    "https://github.com/Azure/terraform-azurerm-avm-res-compute-sshpublickey" : 44,
    "https://github.com/Azure/terraform-azurerm-avm-res-compute-virtualmachine" : 45,
    "https://github.com/Azure/terraform-azurerm-avm-res-compute-virtualmachinescaleset" : 46,
    "https://github.com/Azure/terraform-azurerm-avm-res-containerinstance-containergroup" : 47,
    "https://github.com/Azure/terraform-azurerm-avm-res-containerregistry-registry" : 48,
    "https://github.com/Azure/terraform-azurerm-avm-res-databricks-workspace" : 49,
    "https://github.com/Azure/terraform-azurerm-avm-res-dbformysql-flexibleserver" : 50,
    "https://github.com/Azure/terraform-azurerm-avm-res-dbforpostgresql-flexibleserver" : 51,
    "https://github.com/Azure/terraform-azurerm-avm-res-desktopvirtualization-applicationgroup" : 52,
    "https://github.com/Azure/terraform-azurerm-avm-res-desktopvirtualization-hostpool" : 53,
    "https://github.com/Azure/terraform-azurerm-avm-res-desktopvirtualization-scalingplan" : 54,
    "https://github.com/Azure/terraform-azurerm-avm-res-desktopvirtualization-workspace" : 55,
    "https://github.com/Azure/terraform-azurerm-avm-res-documentdb-databaseaccount" : 56,
    "https://github.com/Azure/terraform-azurerm-avm-res-eventhub-namespace" : 57,
    "https://github.com/Azure/terraform-azurerm-avm-res-insights-component" : 58,
    "https://github.com/Azure/terraform-azurerm-avm-res-kusto-cluster" : 59,
    "https://github.com/Azure/terraform-azurerm-avm-res-loadtestservice-loadtest" : 60,
    "https://github.com/Azure/terraform-azurerm-avm-res-logic-workflow" : 61,
    "https://github.com/Azure/terraform-azurerm-avm-res-managedidentity-userassignedidentity" : 62,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-applicationgateway" : 63,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-applicationsecuritygroup" : 64,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-azurefirewall" : 65,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-bastionhost" : 66,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-ddosprotectionplan" : 67,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-dnsresolver" : 68,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-expressroutecircuit" : 69,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-firewallpolicy" : 70,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-loadbalancer" : 71,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-natgateway" : 72,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-networkinterface" : 73,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-networkmanager" : 74,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup" : 75,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-networkwatcher" : 76,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-privatednszone" : 77,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-privateendpoint" : 78,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-publicipaddress" : 79,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-routetable" : 80,
    "https://github.com/Azure/terraform-azurerm-avm-res-network-virtualnetwork" : 81,
    "https://github.com/Azure/terraform-azurerm-avm-res-operationalinsights-workspace" : 82,
    "https://github.com/Azure/terraform-azurerm-avm-res-recoveryservices-vault" : 83,
    "https://github.com/Azure/terraform-azurerm-avm-res-search-searchservice" : 84,
    "https://github.com/Azure/terraform-azurerm-avm-res-servicebus-namespace" : 85,
    "https://github.com/Azure/terraform-azurerm-avm-res-sql-instancepool" : 86,
    "https://github.com/Azure/terraform-azurerm-avm-res-sql-managedinstance" : 87,
    "https://github.com/Azure/terraform-azurerm-avm-res-sql-server" : 88,
    "https://github.com/Azure/terraform-azurerm-avm-res-sqlvirtualmachine-sqlvirtualmachine" : 89,
    "https://github.com/Azure/terraform-azurerm-avm-res-storage-storageaccount" : 90,
    "https://github.com/Azure/terraform-azurerm-avm-res-synapse-workspace" : 91,
    "https://github.com/Azure/terraform-azurerm-avm-res-web-hostingenvironment" : 92,
    "https://github.com/Azure/terraform-azurerm-avm-res-web-serverfarm" : 93,
    "https://github.com/Azure/terraform-azurerm-avm-res-web-site" : 94,
    "https://github.com/Azure/terraform-azurerm-avm-res-web-staticsite" : 95,
    "https://github.com/Azure/terraform-azurerm-avm-res-resources-resourcegroup": 96,
    "https://github.com/Azure/terraform-azurerm-avm-res-insights-scheduledqueryrule": 97,
    "https://github.com/Azure/terraform-azurerm-avm-ptn-network-routeserver": 98,

  } : k => tostring(v)}

  runner_network_whitelist = sort(distinct([
    # OneES
    "*.dev.cloudtest.microsoft.com",
    "*.ppe.cloudtest.microsoft.com",
    "*.prod.cloudtest.microsoft.com",
    "ctdevbuilds.azureedge.net",
    "ctppebuilds.azureedge.net",
    "ctprodbuilds.azureedge.net",
    "vstsagentpackage.azureedge.net",
    "cloudtestdev.queue.core.windows.net",
    "cloudtestppe.queue.core.windows.net",
    "cloudtestintch1.queue.core.windows.net",
    "cloudtestprod.queue.core.windows.net",
    "cloudtestprodstampbn2.queue.core.windows.net",
    "cloudtestprodch1.queue.core.windows.net",
    "cloudtestprodco3.queue.core.windows.net",
    "cloudtestprodsn2.queue.core.windows.net",
    "stage.diagnostics.monitoring.core.windows.net",
    "production.diagnostics.monitoring.core.windows.net",
    "gcs.prod.monitoring.core.windows.net",
    "server.pipe.aria.microsoft.com",
    "azure.archive.ubuntu.com",
    "www.microsoft.com",

    "packages.microsoft.com",
    "ppa.launchpad.net",
    "dl.fedoraproject.org",
    "registry-1.docker.io",
    "auth.docker.io",
    "download.docker.com",
    "packagecloud.io",
    // 2.2 Needed by Azure DevOps agent: https://learn.microsoft.com/en-us/azure/devops/organizations/security/allow-list-ip-url?view=azure-devops&tabs=IP-V4
    "dev.azure.com",
    "*.services.visualstudio.com",
    "*.vsblob.visualstudio.com",
    "*.vssps.visualstudio.com",
    "*.visualstudio.com",
    # Github services
    "github.com",
    "api.github.com",
    "*.actions.githubusercontent.com",
    "raw.githubusercontent.com",
    "codeload.github.com",
    "actions-results-receiver-production.githubapp.com",
    "objects.githubusercontent.com",
    "objects-origin.githubusercontent.com",
    "github-releases.githubusercontent.com",
    "github-registry-files.githubusercontent.com",
    "*.blob.core.windows.net",
    "*.pkg.github.com",
    "ghcr.io",
    # Container registry
    "mcr.microsoft.com",
    "*.mcr.microsoft.com",
    "registry.hub.docker.com",
    "production.cloudflare.docker.com",
    "registry-1.docker.io",
    "auth.docker.io",
    # Golang
    "*.golang.org",
    "cloud.google.com",
    "go.opencensus.io",
    "golang.org",
    "gopkg.in",
    "k8s.io",
    "*.k8s.io",
    "storage.googleapis.com",
    # Terraform
    "registry.terraform.io",
    "releases.hashicorp.com",
    # Provision script
    "tfmod1esscript.blob.core.windows.net",
    # Azure service
    "graph.microsoft.com",
    "management.core.windows.net",
    "management.azure.com",
    "login.microsoftonline.com",
    "*.aadcdn.msftauth.net",
    "*.aadcdn.msftauthimages.net",
    "*.aadcdn.msauthimages.net",
    "*.logincdn.msftauth.net",
    "login.live.com",
    "*.msauth.net",
    "*.aadcdn.microsoftonline-p.com",
    "*.microsoftonline-p.com",
    "*.portal.azure.com",
    "*.hosting.portal.azure.net",
    "*.reactblade.portal.azure.net",
    "management.azure.com",
    "*.ext.azure.com",
    "*.graph.windows.net",
    "*.graph.microsoft.com",
    "*.account.microsoft.com",
    "*.bmx.azure.com",
    "*.subscriptionrp.trafficmanager.net",
    "*.signup.azure.com",
    "*.asazure.windows.net",
    "*.azconfig.io",
    "*.aad.azure.com",
    "*.aadconnecthealth.azure.com",
    "ad.azure.com",
    "adf.azure.com",
    "api.aadrm.com",
    "api.loganalytics.io",
    "api.azrbac.mspim.azure.com",
    "*.applicationinsights.azure.com",
    "appservice.azure.com",
    "*.arc.azure.net",
    "asazure.windows.net",
    "bastion.azure.com",
    "batch.azure.com",
    "catalogapi.azure.com",
    "catalogartifact.azureedge.net",
    "changeanalysis.azure.com",
    "cognitiveservices.azure.com",
    "config.office.com",
    "cosmos.azure.com",
    "*.database.windows.net",
    "datalake.azure.net",
    "dev.azure.com",
    "dev.azuresynapse.net",
    "digitaltwins.azure.net",
    "learn.microsoft.com",
    "elm.iga.azure.com",
    "venthubs.azure.net",
    "functions.azure.com",
    "gallery.azure.com",
    "go.microsoft.com",
    "help.kusto.windows.net",
    "identitygovernance.azure.com",
    "iga.azure.com",
    "informationprotection.azure.com",
    "kusto.windows.net",
    "learn.microsoft.com",
    "logic.azure.com",
    "marketplacedataprovider.azure.com",
    "marketplaceemail.azure.com",
    "media.azure.net",
    "monitor.azure.com",
    "mspim.azure.com",
    "network.azure.com",
    "purview.azure.com",
    "quantum.azure.com",
    "rest.media.azure.net",
    "search.azure.com",
    "servicebus.azure.net",
    "servicebus.windows.net",
    "shell.azure.com",
    "sphere.azure.net",
    "azure.status.microsoft",
    "storage.azure.com",
    "storage.azure.net",
    "*.storage.azure.com",
    "*.storage.azure.net",
    "vault.azure.net",
    "*.vault.azure.net",
    # Service for examples
    "api.bigdatacloud.net",
    "ipv4.seeip.org",
    "ifconfig.me",
    "api.ipify.org",
    # For debugger
#    "*.docker.com",
#    "aka.ms",
  ]))
}

