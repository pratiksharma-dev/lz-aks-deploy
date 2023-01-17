# Create Resource Group
az group create -l EastUS -n az-k8s-hmjn-poc-rg

# Deploy template with in-line parameters
az deployment group create -g az-k8s-hmjn-poc-rg  --template-uri https://github.com/Azure/AKS-Construction/releases/download/0.9.7/main.json --parameters `
	resourceName=az-k8s-hmjnpoc `
	upgradeChannel=stable `
	agentCountMax=20 `
	custom_vnet=true `
	vnetAksSubnetAddressPrefix=10.240.0.0/24 `
	enable_aad=true `
	AksDisableLocalAccounts=true `
	enableAzureRBAC=true `
	adminPrincipalId=$(az ad signed-in-user show --query id --out tsv) `
	registries_sku=Premium `
	acrPushRolePrincipalId=$(az ad signed-in-user show --query id --out tsv) `
	imageNames="['k8s.gcr.io/external-dns/external-dns:v0.11.0']" `
	privateLinks=true `
	keyVaultIPAllowlist="['24.16.43.12/32']" `
	openServiceMeshAddon=true `
	enablePrivateCluster=true `
	fileCSIDriver=false `
	diskCSIDriver=false `
	dnsZoneId=/subscriptions/daaad427-15a9-4542-9bdd-9d603751cab4/resourceGroups/dns-rg/providers/Microsoft.Network/privateDnsZones/poc-aks.com `
	keyVaultAksCSI=true `
	keyVaultCreate=true `
	keyVaultOfficerRolePrincipalId=$(az ad signed-in-user show --query id --out tsv) `
	fluxGitOpsAddon=true `
	networkPluginMode=Overlay `
	ebpfDataplane=cilium

# Private cluster, so use command invoke
az aks command invoke -g az-k8s-hmjn-poc-rg -n aks-az-k8s-hmjnpoc  --command "curl -sL https://github.com/Azure/AKS-Construction/releases/download/0.9.7/postdeploy.sh  | bash -s -- -r https://github.com/Azure/AKS-Construction/releases/download/0.9.7 \
	-p ingress=nginx \
	-p dnsZoneId=/subscriptions/daaad427-15a9-4542-9bdd-9d603751cab4/resourceGroups/dns-rg/providers/Microsoft.Network/privateDnsZones/poc-aks.com \
	-p KubeletId=$(az aks show -g az-k8s-hmjn-poc-rg -n aks-az-k8s-hmjnpoc --query identityProfile.kubeletidentity.clientId -o tsv) \
	-p TenantId=$(az account show --query tenantId -o tsv) \
	-p certEmail=pratik.s.sharma@outlook.com \
	-p acrName=$(az acr list -g az-k8s-hmjn-poc-rg --query [0].name -o tsv) \
	-p monitor=oss \
	-p enableMonitorIngress=true
"
echo "hello"



