$users = Import-CSV users.csv
$ou = Import-CSV organizationunits.csv
$groups = Import-CSV groups.csv
$folders = Import-CSV folders.csv
#$folders = Get-Content './folders.json' | Out-String | ConvertFrom-Json

$contoso = "dc=contoso,dc=com"
$companyName = "Company"
$company = "ou=" + $companyName + "," + $contoso
$rootDir = $folders[0].FullPath
$passwd = "P@ssword901"
$shareName = "company_data"

New-ADOrganizationalUnit -Name $companyName -Path $contoso

foreach ($i in $ou) {
    New-ADOrganizationalUnit -Name $i.OuName -Path $company
}

foreach ($i in $groups) {
    $path = "ou=" + $i.Department + "," + $company
    New-ADGroup -Name $i.GroupName -SamAccountName $i.GroupName -GroupCategory Security -GroupScope Universal -Path $path
}

# dotąd działa ________________________________________________________
Foreach ($i in $users) {
    $name = $i.FirstName + " " + $i.LastName
    $sam_name = $i.FirstName.ToLower()[0] + $i.LastName.ToLower()
    $upn_name = $i.FirstName.ToLower() + "." + $i.LastName.ToLower() + "@contoso.com"
    $path = "ou=" + $i.OuName + "," + $company
    
    New-ADUser -Name $name -SamAccountName $sam_name -UserPrincipalName $upn_name -Path $path -PasswordNeverExpires $true -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText $passwd -Force) -Enabled $true
    Add-ADGroupMember -Identity $i.GroupName -Members $sam_name
}

foreach ($i in $folders) {
    New-Item -ItemType Directory -Path $i.FullPath
    # to nie działa
    # if(!$i.FullC1) {
    #     New-SMBShare -Name $i.FolderName -Path $i.FullPath -FullAccess $1.FullC1
    # }
}
New-SmbShare -Name $shareName -Path $rootDir -ReadAccess EveryOne