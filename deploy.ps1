$tenantId = "<tenantId>"
$subscriptionId = "<subscriptionId>"

$settingsKV = @{

}

az login --tenant $tenantId
az account set --subscription $subscriptionId
$settingsKV|ConvertTo-Json -Compress|Out-File -FilePath .\setting.json
az webapp config appsettings set --resource-group $resourceGroupName --name $functionName --settings "@setting.json"
Remove-Item .\setting.json

$include = @("app.py","requirements.txt")
$pyfiles = Get-ChildItem -Path .\* -Include $include -Force
Compress-Archive -Path $pyfiles -DestinationPath .\pythonapp.zip -Force

az webapp deployment source config-zip --resource-group $resouceGroupName --name $webAppsName --src .\pythonapp.zip

Remove-Item .\pythonapp.zip