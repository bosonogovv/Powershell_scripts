$defaultPath = "\\UNC\Path"

#userList - переменная хранящая объекты учетных записей в ad, с флагом отключена#
$userList = Get-ADUser -Filter * -Properties Enabled, SID -SearchBase "<OU=deleted,DC=msft,DC=com>"  | Where-Object -Property Enabled -eq $False

#Проходимся по всем найденым объектам и выводим последние 4 символа из их SID.
$userList | ForEach-Object {
    $userName = $_.SamAccountName
    $id = $_.sid.value.Substring($_.SID.Value.Length-4)
    try {
        New-Item -Path $defaultPath$userName'-'$id -ItemType Directory -ErrorAction Stop
    }
    catch {
        Write-Host "INFO: Folder $defaultPath$username-$id may already exist, or some error happen..." -ForegroundColor Yellow
    }
    try {
        Get-ADPrincipalGroupMembership -Identity $userName | Select-Object name | Out-File $defaultPath$username'-'$id\'Group.txt' -Append
    }
    catch {
        Write-Host "ERROR: An error occurred while creating file Group for $username-$id!!!" -ForegroundColor Red
    }
    Get-AdPrincipalGroupMembership -Identity $userName | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $userName
}


if ($LASTEXITCODE -eq 0) {Write-Host "SUCCESS: Script done!" -ForegroundColor Green} else {Write-Host "ERROR: An error occurred while running the script. Exit code - $LASTEXITCODE"}