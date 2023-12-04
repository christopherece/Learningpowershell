# The path to CSV file
$csvPath = "C:\PS\friends.csv"

# Import user data from the CSV file
$userData = Import-Csv -Path $csvPath
$credMaster = Get-Content -Path "C:\temp\admchris.txt"

#Get Admin Cred to execute the Script
$secure_string_pwd = $credMaster | ConvertTo-SecureString -key ("5;35;252;158;235;108;124;141;141;229;206;208;152;150;48;88;102;85;159;140;76;119;24;228;113;0;180;157;189;94;245;93".split(";")) 
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "admchris", $secure_string_pwd

# Loop through the CSV data and create user accounts
foreach ($user in $userData) {
    # Define user properties from CSV columns
    $userProperties = @{
        Credential = $credentials
        SamAccountName = $user.SamAccountName
        Name = $user.Name
        Path = "OU=Friends_WifiAccess, DC=balaydalakay, DC=local"
        GivenName = $user.GivenName
        Surname = $user.Surname
        UserPrincipalName = $user.SamAccountName + "@" + (Get-ADDomain).DnsRoot
        AccountPassword = ConvertTo-SecureString -AsPlainText $user.AccountPassword -Force
        Description = $user.Description
        ChangePasswordAtLogon = $true 
        EmployeeID = $user.EmployeeID  # Need to understand how to generate Employee ID???
        Enabled = $true
        DisplayName = $user.DisplayName
        ProfilePath = (Get-ADDomain).DnsRoot + "\" + $user.SamAccountName
        City = $user.City
        # OtherAttributes @{'Info'="${changeNo} - User Created"}
    }

    # Create the new AD user using the data from the CSV and the credentials
    #New-ADUser @userProperties -Credential $credentials

    New-ADUser @userProperties
}
