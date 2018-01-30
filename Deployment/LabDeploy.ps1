Write-Host "Lab deployment starting...."
#Install SQL components
Install-Module -Name SqlServer -Scope CurrentUser

#Prompt for Azure credentials
Login-AzureRmAccount

#configurations - FILL OUT WITH DESIRED VALUES
$dir = "D:\ADFLab-Master\Deployment"        #Working directory of where your LabDeploy.ps1 file is located
$resourceGroupName = "adflab-test"          #Name of Azure resource group to deploy the lab resrouces to, will create if it does not exist
$location = "East US 2"                     #Geo location of resource group, resources will use this as well
$labNamePrefix = "adflab"                   #prefix to append on to unique names such as SQLServer and Storage account
$sqlUsername = "labadmin"                   #SqlServer admin account
$sqlPassword = "L@bP@ss01"                  #SqlServer admin password
$logicAppEmail = "user@domain.com"          #O365 Account to send emails for lab
$subscriptionName = "Microsoft Engagements" #Name of subscription to use for deployment

#Set subscription
Get-AzureRmSubscription –SubscriptionName $subscriptionName | Select-AzureRmSubscription

#local variables
$RGnotExist = 0

#set working directory
Set-Location $dir

#check if resource group exist
Get-AzureRmResourceGroup -Name $resourceGroupName -ev RGnotExist -ea 0
if ($RGnotExist)
{
    #create resource group
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}

#deploy ARM template
$ARMOutput = New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile LabARM.json -labNamePrefix $labNamePrefix -sqlUsername $sqlUsername -sqlPassword $sqlPassword -logicAppEmail $logicAppEmail

#ARM template outputs
$storageName = $ARMOutput.Outputs.storageName.value
$sqlServerName =  $ARMOutput.Outputs.sqlServerName.value

#get storage account reference
#$storageAccount = Get-AzureRMStorageAccount -ResourceGroupName $resourceGroupName -AccountName $storageName
Set-AzureRmCurrentStorageAccount -StorageAccountName $storageName -ResourceGroupName $resourceGroupName

#create containers
"input output blobsource backups".Split()| New-AzureStorageContainer -Permission Container

#upload files to blobsource container
Set-AzureStorageBlobContent -File "Files\blobsource\AcftRef.txt" -Container "blobsource" -Blob "AcftRef.txt" -Force
Set-AzureStorageBlobContent -File "Files\blobsource\DimDate.csv" -Container "blobsource" -Blob "DimDate.csv" -Force
Set-AzureStorageBlobContent -File "Files\blobsource\MASTER201612.csv" -Container "blobsource" -Blob "MASTER201612.csv" -Force

#upload files to input container
Set-AzureStorageBlobContent -File "Files\input\FAAMerge.hql" -Container "input" -Blob "FAAMerge.hql" -Force
Set-AzureStorageBlobContent -File ".\Files\input\FAAMaster\FAAmaster.txt" -Container "input" -Blob "FAAmaster\FAAmaster.txt" -Force
Set-AzureStorageBlobContent -File ".\Files\input\FAAaircraft\FAAaircraft.txt" -Container "input" -Blob "FAAaircraft\FAAaircraft.txt" -Force

#upload bacpacs to backups container for SQL Import
Set-AzureStorageBlobContent -File "Files\backups\AirlinePerformance-OLTP.bacpac" -Container "backups" -Blob "AirlinePerformance-OLTP.bacpac" -Force
Set-AzureStorageBlobContent -File ".\Files\backups\AirlinePerformance-ODS.bacpac" -Container "backups" -Blob "AirlinePerformance-ODS.bacpac" -Force

#restore DBs to sql server
$importRequest = New-AzureRmSqlDatabaseImport -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -DatabaseName "AirlinePerformance-OLTP" `
    -DatabaseMaxSizeBytes "262144000" `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey $(Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -StorageAccountName $storageName).Value[0] `
    -StorageUri "http://$storageName.blob.core.windows.net/backups/AirlinePerformance-OLTP.bacpac" `
    -Edition "Standard" `
    -ServiceObjectiveName "S3" `
    -AdministratorLogin $sqlUsername `
    -AdministratorLoginPassword $(ConvertTo-SecureString -String $sqlPassword -AsPlainText -Force)

New-AzureRmSqlDatabaseImport -ResourceGroupName $resourceGroupName `
    -ServerName $sqlServerName `
    -DatabaseName "AirlinePerformance-ODS" `
    -DatabaseMaxSizeBytes "262144000" `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey $(Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -StorageAccountName $storageName).Value[0] `
    -StorageUri "http://$storageName.blob.core.windows.net/backups/AirlinePerformance-ODS.bacpac" `
    -Edition "Standard" `
    -ServiceObjectiveName "S3" `
    -AdministratorLogin $sqlUsername `
    -AdministratorLoginPassword $(ConvertTo-SecureString -String $sqlPassword -AsPlainText -Force)

#Get external IP for Azure firewall via web client call
$wc=New-Object net.webclient
$myIP = $wc.downloadstring("http://checkip.dyndns.com") -replace "[^\d\.]"

#add current ip to SQL firewall rule
New-AzureRMSqlServerFirewallRule -ServerName $sqlServerName -FirewallRuleName "LabUserFirewall" -StartIpAddress $myIP -EndIpAddress $myIP -ResourceGroupName $resourceGroupName

#login creation for Azure DB
Invoke-Sqlcmd  -Query "CREATE LOGIN DWLoadUser WITH PASSWORD = '$sqlPassword'" -ServerInstance "$sqlServerName.database.windows.net" -Database "master" -Username $sqlUsername -Password $sqlPassword

#schema creation for Azure DW DB
Invoke-Sqlcmd -inputFile "CreateAzureDW.sql" -ServerInstance "$sqlServerName.database.windows.net" -Database "AirlinePerformance-DW" -Username $sqlUsername -Password $sqlPassword

#loop until OLTP restore is done before marking done
$importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
Write-Host "OLTP DB Restoring..."
while ($importStatus.Status -eq "InProgress")
{
    $importStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
    Write-Host -NoNewLine "."
    Start-Sleep -s 60
}
 Write-Host "Lab deployment complete!"
