type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y


app=($(az ad app create --display-name lz-aks-deploy --query "[appId,id]" -o tsv | tr ' ' "\n"))
spId=$(az ad sp create --id ${app[0]} --query id -o tsv )
subId=$(az account show --query id -o tsv)

az role assignment create --role owner --assignee-object-id  $spId --assignee-principal-type ServicePrincipal --scope /subscriptions/$subId/resourceGroups/az-k8s-hmjn-poc-rg
az role assignment create --role owner --assignee-object-id  $spId --assignee-principal-type ServicePrincipal --scope /subscriptions/daaad427-15a9-4542-9bdd-9d603751cab4/resourceGroups/dns-rg

# Create a new federated identity credential
az rest --method POST --uri "https://graph.microsoft.com/beta/applications/${app[1]}/federatedIdentityCredentials" --body "{\"name\":\"lz-aks-deploy-main-gh\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:pratiksharma-dev/lz-aks-deploy:ref:refs/heads/main\",\"description\":\"Access to branch main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

# Set Secrets
gh secret set --repo https://github.com/pratiksharma-dev/lz-aks-deploy AZURE_CLIENT_ID -b ${app[0]}
gh secret set --repo https://github.com/pratiksharma-dev/lz-aks-deploy AZURE_TENANT_ID -b $(az account show --query tenantId -o tsv)
gh secret set --repo https://github.com/pratiksharma-dev/lz-aks-deploy AZURE_SUBSCRIPTION_ID -b $subId
gh secret set --repo https://github.com/pratiksharma-dev/lz-aks-deploy USER_OBJECT_ID -b $spId