$tenantId = "<tenantId>"
$subscriptionId = "<subscriptionId>"
$resourceGroupName = "<resourceGroupName>"
$webAppsName = "<webAppsName>"
$applicationInsightsConnectionString = "<applicationInsightsConnectionString>"
$azureOpenAIEndpoint = "<azureOpenAIEndpoint>"
$azureOpenAIApiKey = "<azureOpenAIApiKey>"
$azureOpenAIModelName = "<azureOpenAIModelName>"
$OpenAIApiVersion = "2024-07-01-preview"

$settingsKV = @{
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = $applicationInsightsConnectionString
    "AZURE_OPENAI_ENDPOINT" = $azureOpenAIEndpoint 
    "AZURE_OPENAI_API_KEY" = $azureOpenAIApiKey
    "AZURE_OPENAI_MODEL_NAME" = $azureOpenAIModelName
    "OPENAI_API_VERSION" = $OpenAIApiVersion
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
}

az login --tenant $tenantId
az account set --subscription $subscriptionId
$settingsKV|ConvertTo-Json -Compress|Out-File -FilePath .\setting.json
az webapp config appsettings set --resource-group $resourceGroupName --name $webAppsName --settings "@setting.json"
Remove-Item .\setting.json

az webapp config set --resource-group $resourceGroupName --name $webAppsName --startup-file "python -m streamlit run app.py --server.port 8000 --server.address 0.0.0.0"

$include = ("app.py","requirements.txt")
$pyfiles = Get-ChildItem -Path .\* -Include $include -Force
Compress-Archive -Path $pyfiles -DestinationPath .\pythonapp.zip -Force
Compress-Archive -Path '.streamlit\' -DestinationPath .\pythonapp.zip -Update

az webapp deploy --resource-group $resourceGroupName --name $webAppsName --type "zip" --src-path .\pythonapp.zip

Remove-Item .\pythonapp.zip