$users=Import-CSV users.csv

Foreach ($i in $users) {
    $name = $i.FirstName+" "+$i.LastName
    $sam_name = $i.FirstName.ToLower()[0]+$i.LastName.ToLower()
    $upn_name = $i.FirstName.ToLower()+"."+$i.LastName.ToLower()+"@contoso.com"
    # to rozwiązanie nie jest dobre dla zagnieżdzeń ou
    # test czy dziala
    $path = "ou="+$i.Department+",dc=contoso,dc=com"
    $passwd = "P@ssword901"

    $user_exist = Get-ADUser -Filter "SamAccountName -eq '$sam_name'"

    If($user_exist -eq $null)
    {
        $ou_exist = Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$path'"

        If($ou_exist -eq $null){
            New-ADOrganizationalUnit -Name $i.Department -Path "dc=contoso,dc=com"
        }

        New-ADUser -Name $name -SamAccountName $sam_name -UserPrincipalName $upn_name -Path $path -PasswordNeverExpires $true -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText $passwd -Force) -Enabled $true
        Write-Host ("Message: "+$i.FirstName+" "+$i.LastName+"-ADDED") -ForegroundColor Green
    }
    Else
    {
        Write-Host ("WARNING: "+$i.FirstName+" "+$i.LastName+"------ALREADY EXIST") -ForegroundColor Yellow
    }
}