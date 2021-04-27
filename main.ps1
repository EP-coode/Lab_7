
$users=Import-CSV users.csv
Foreach ($i in $users) {
    Write-Host ($i.FirstName+" "+$i.LastName)
    New-ADUser -Name ($i.FirstName+" "+$i.LastName) -SamAccountName ($i.FirstName.ToLower()[0]+$i.LastName.ToLower()) -UserPrincipalName ($i.FirstName.ToLower()+"."+$i.LastName.ToLower()+"@contoso.com") -Path ("ou="+$i.Department+",dc=contoso,dc=com") -PasswordNeverExpires $true -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "P@ssword901" -Force) -Enabled $true
}