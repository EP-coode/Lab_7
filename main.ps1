$users=Import-CSV users.csv
$ou=Import-CSV organizationunits.csv
$groups=Import-CSV groups.csv
$folders=Import-CSV folders.csv
#$folders = Get-Content './folders.json' | Out-String | ConvertFrom-Json

$contoso = "dc=contoso,dc=com"
$companyName = "Company"
$company = "ou=" + $companyName + ","+$contoso
$rootDir = "C:\company_data\"
$passwd = "P@ssword901"

New-ADOrganizationalUnit -Name $companyName -Path $contoso

foreach ($i in $ou) {
    New-ADOrganizationalUnit -Name $i.OuName -Path $company
}

foreach ($i in $groups) {
    $path = "ou="+$i.Department+","+$company
    New-ADGroup -Name $i.GroupName -SamAccountName $i.GroupName -GroupCategory Security -GroupScope Universal -Path $path
}

# dotąd działa ________________________________________________________
Foreach ($i in $users) {
    $name = $i.FirstName+" "+$i.LastName
    $sam_name = $i.FirstName.ToLower()[0]+$i.LastName.ToLower()
    $upn_name = $i.FirstName.ToLower()+"."+$i.LastName.ToLower()+"@contoso.com"
    $path = "ou="+$i.OuName+","+$company
    $

    $user_exist = Get-ADUser -Filter "SamAccountName -eq '$sam_name'"

    If($user_exist -eq $null)
    {
        $ou_exist = Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$path'"

        If($ou_exist -eq $null){
            New-ADOrganizationalUnit -Name $i.Department -Path $company
        }

        New-ADUser -Name $name -SamAccountName $sam_name -UserPrincipalName $upn_name -Path $path -PasswordNeverExpires $true -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText $passwd -Force) -Enabled $true
        Write-Host ("Message: "+$i.FirstName+" "+$i.LastName+"-ADDED") -ForegroundColor Green
    }
    Else
    {
        Write-Host ("WARNING: "+$i.FirstName+" "+$i.LastName+"------ALREADY EXIST") -ForegroundColor Yellow
    }
}

New-SmbShare -Name "company_data" -Path $rootDir -FullAccess EveryOne
foreach ($i in $folders) {
    New-Item -ItemType Directory -Path $i.FullPath
}