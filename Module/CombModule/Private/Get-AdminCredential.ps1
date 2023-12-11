function Get-AdminCredential(){
    $admuser = "svc_access_AutomationDev"
    $credDefault = Get-Content -Path "C:\temp\aklcdev.txt"
    $secure_string_pwd = $credDefault | ConvertTo-SecureString -Key ("5;35;252;158;235;108;124;141;141;229;206;208;152;150;48;88;102;85;159;140;76;119;24;228;113;0;180;157;189;94;245;93".split(";"))
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $admuser, $secure_string_pwd
    return $cred
}