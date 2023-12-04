    
    #Import-Module ActiveDirectory

    # adminPword and Default User Pword
    $credDefault = Get-Content -Path "C:\temp\admchris.txt"
    $DefaultPassword = Get-Content -Path "C:\temp\DefaultPassword.txt"

    $adminUserExists = $false

    # Keep asking for admin user until a valid one is provided
    while (-not $adminUserExists) {
        # Type Admin first before you can create a user
        $admuser = Read-Host "Enter admin"
        

        if ([string]::IsNullOrEmpty($admuser)) {
            [System.Windows.Forms.MessageBox]::Show("Username is required.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        } 
        else {
            # Check if the admin user exists
            $superAdmin = Get-ADGroupMember -Identity "Super_Admin_User" | Where-Object { $_.objectClass -eq 'user' } | Select-Object -ExpandProperty SamAccountName
            if ($superAdmin -eq $admuser) {
                $adminUserExists = $true
            } else {
                [System.Windows.Forms.MessageBox]::Show("Admin user '$admuser' does not exist. Please enter a valid admin user.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    }

    
    $secure_string_pwd = $credDefault | ConvertTo-SecureString -Key ("5;35;252;158;235;108;124;141;141;229;206;208;152;150;48;88;102;85;159;140;76;119;24;228;113;0;180;157;189;94;245;93".split(";"))

    # Create PSCredential object if both username and password are provided correctly
    $credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $admuser, $secure_string_pwd

    do {
        
        # Prompt for user input
        $userName = Read-Host "Enter User Name"
        

        if (Get-ADUser -Filter {SamAccountName -eq $userName }){
        [System.Windows.Forms.MessageBox]::Show("Username Already Exist.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    
        } else {
            # Get DC name
            $profileShare = (Get-ADDomain).DnsRoot

            #User Details
            $firstName = Read-Host "Enter User First Name"
            $lastName = Read-Host "Enter User Last Name"
            $userDescription = Read-Host "Enter User Description"
            # Get all OUs
            $ous = Get-ADOrganizationalUnit -Filter * | Select-Object Name

            # Display OUs with numbered options
            Write-Host "List of Organizational Units:"
            for ($i = 0; $i -lt $ous.Count; $i++) {
                Write-Host "$($i+1). $($ous[$i].Name)"
            }

            $ouSelection = Read-Host "Enter the number of the OU you want to select for the new user"
            
            # Validate user input
            if ($ouSelection -match '^\d+$' -and $ouSelection -ge 1 -and $ouSelection -le $ous.Count) {
                    $selectedOU = $ous[$ouSelection - 1].Name
   
                    # Use $selectedOU in the -Path parameter of New-ADUser command
                    New-ADUser -Credential $credentials -SamAccountName "${userName}" `
                        -Server "balaydalakay.local" `
                        -Name "${userName}" `
                        -Path "OU=$selectedOU,DC=balaydalakay,DC=local" `
                        -GivenName "${firstName}" `
                        -Surname "${lastName}" `
                        -UserPrincipalName "${userName}@aklc.govt.nz" `
                        -AccountPassword (ConvertTo-SecureString -AsPlainText '${DefaultPassword}' -Force) `
                        -Description $userDescription `
                        -ChangePasswordAtLogon $true `
                        -EmployeeID "${employeeID}" `
                        -Enabled $true `
                        -DisplayName "${firstName} ${lastName}" `
                        -ProfilePath "${profileShare}\${userName}" `
                        -City "Auckland"`
                        -OtherAttributes @{'Info'="${changeNo} - User Created"}

        
                        [System.Windows.Forms.MessageBox]::Show("Success, User Added to AD!", "Success", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)

                        break

                } else {
                    Write-Host "Invalid selection. Please enter a valid number."
                }

        

        }


    } while ($true)
