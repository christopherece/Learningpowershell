<# 
.NAME
    Gui in creating AD user
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = New-Object System.Drawing.Point(300,250)
$Form.text = "Form"
$Form.TopMost = $false

# Centered Title
$titleLabel = New-Object system.Windows.Forms.Label
$titleLabel.text = "Create AD User"
$titleLabel.AutoSize = $true
$titleLabel.width = 200
$titleLabel.height = 20
$titleLabel.location = New-Object System.Drawing.Point(30, 5)
$titleLabel.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',12)
$Form.Controls.Add($titleLabel)

$lblfname = New-Object system.Windows.Forms.Label
$lblfname.text = "Firstname"
$lblfname.AutoSize = $true
$lblfname.width = 60
$lblfname.height = 20
$lblfname.location = New-Object System.Drawing.Point(30, 30)
$lblfname.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Form.Controls.Add($lblfname)

$fname = New-Object system.Windows.Forms.TextBox
$fname.multiline = $false
$fname.width = 150
$fname.height = 20
$fname.location = New-Object System.Drawing.Point(120, 30)
$fname.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Form.Controls.Add($fname)

$lbllname = New-Object system.Windows.Forms.Label
$lbllname.text = "Lastname"
$lbllname.AutoSize = $true
$lbllname.width = 60
$lbllname.height = 20
$lbllname.location = New-Object System.Drawing.Point(30, 70)
$lbllname.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Form.Controls.Add($lbllname)

$lname = New-Object system.Windows.Forms.TextBox
$lname.multiline = $false
$lname.width = 150
$lname.height = 20
$lname.location = New-Object System.Drawing.Point(120, 70)
$lname.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Form.Controls.Add($lname)

$lbldesc = New-Object system.Windows.Forms.Label
$lbldesc.text = "Description"
$lbldesc.AutoSize = $true
$lbldesc.width = 70
$lbldesc.height = 20
$lbldesc.location = New-Object System.Drawing.Point(30, 110)
$lbldesc.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Form.Controls.Add($lbldesc)

$descript = New-Object system.Windows.Forms.TextBox
$descript.multiline = $false
$descript.width = 150
$descript.height = 20
$descript.location = New-Object System.Drawing.Point(120, 110)
$descript.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Form.Controls.Add($descript)


$btnSubmit = New-Object system.Windows.Forms.Button
$btnSubmit.text = "Submit"
$btnSubmit.width = 80
$btnSubmit.height = 30
$btnSubmit.location = New-Object System.Drawing.Point(50, 150)
$btnSubmit.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Form.Controls.Add($btnSubmit)

# Close Button
$btnClose = New-Object system.Windows.Forms.Button
$btnClose.text = "Close"
$btnClose.width = 80
$btnClose.height = 30

# Adjusted position to align with other elements
$btnClose.location = New-Object System.Drawing.Point(140, 150)
$btnClose.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$btnClose.Add_Click({
    $Form.Close()
})

$Form.Controls.Add($btnClose)
$Form.controls.AddRange(@($lblfname, $fname, $lbllname, $lname, $lbldesc, $descript, $btnSubmit ))


$btnSubmit.Add_Click({

    $userName = $fname.Text
    $userLastName = $lname.Text
    $userDescription = $descript.Text

    if (-not $userName -or -not $userLastName) {
        [System.Windows.Forms.MessageBox]::Show("Username and Lastname is required.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } 
    else {
       
    $credDefault = Get-Content -Path "C:\temp\admchris.txt"
    $DefaultPassword = Get-Content -Path "C:\temp\DefaultPassword.txt"

    # Try to convert the content from $credDefault to a secure string
    $secure_string_pwd = $credDefault | ConvertTo-SecureString -Key ("5;35;252;158;235;108;124;141;141;229;206;208;152;150;48;88;102;85;159;140;76;119;24;228;113;0;180;157;189;94;245;93".split(";"))

    # Create PSCredential object if both username and password are provided correctly
    $credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "admchris", $secure_string_pwd

        

    # Get DC name
    $profileShare = (Get-ADDomain).DnsRoot

    new-aduser -Credential $credentials -SamAccountName "${userName}" `
        -Server "balaydalakay.local" `
        -Name "${userName}" `
        -Path "OU=TestOU,DC=balaydalakay, DC=local" `
        -GivenName "${userName}" `
        -Surname "${userLastName}" `
        -UserPrincipalName "${userName}@aklc.govt.nz" `
        -AccountPassword (ConvertTo-SecureString -AsPlainText '${DefaultPassword}' -Force) `
        -Description $userDescription `
        -ChangePasswordAtLogon $true `
        -EmployeeID "${employeeID}" `
        -Enabled $true `
        -DisplayName "${userName} ${userLastName}" `
        -ProfilePath "${profileShare}\${userName}" `
        -City "Auckland"`
        -OtherAttributes @{'Info'="${changeNo} - User Created"}

        [System.Windows.Forms.MessageBox]::Show("Success, User Added to AD!", "Success", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)

        $lname.text = ""
        $fname.Text = ""
        $descript.text = ""
        

        }

    
    })

    

[void]$Form.ShowDialog()