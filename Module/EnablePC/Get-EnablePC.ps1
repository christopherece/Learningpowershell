function Get-EnablePC{
    param (
         # Parameter help description
         [Parameter(Mandatory=$true)]
         [string]$pcNumber,
         [Parameter(Mandatory=$true)]
         [string]$incidentNumber
    )

    # Get ServiceNow admin credentials
    $cred = Get-AdminCredential
    # ServiceNow details
    $ServiceNowInstance = "dev185867"
    $incidentNumber = $incidentNumber
    $pcNumber = $pcNumber
    New-ServiceNowSession -Url "${ServiceNowInstance}.service-now.com" -Credential $cred
    
    
    # Assuming you have a function to get the computer's DistinguishedName based on its name
    $computerDN = Get-ADComputer -Filter { Name -eq $pcNumber } | Select-Object -ExpandProperty DistinguishedName
    $targetOU = "OU=EnabledPC,DC=balaydalakay,DC=local"
    # Get incident details from ServiceNow
    $incidentDetails = Get-IncidentDetails -incidentNumber $incidentNumber
    $date = Get-Date
    $incidentDescriptionTobeAdded = "Device re-enabled $date - $($incidentDetails.number))"

    # Move/Activate and set Description of the computer to the specified OU
    Set-ADComputer -Identity $computerDN -Enabled $true
    Set-ADComputer -Identity $computerDN -Description $incidentDescriptionTobeAdded
    Move-ADObject -Identity $computerDN -TargetPath $targetOU


    Write-Output "PC Activated and Moved to Correct OU. Incident Description copied to PC Description."



}


# Function to get incident details from ServiceNow
function Get-IncidentDetails {
    param (
        [string]$incidentNumber
    )
    New-ServiceNowSession -Url "${ServiceNowInstance}.service-now.com" -Credential $cred

    $incident = Get-ServiceNowRecord -Table Incident -Filter ('number', '-eq', $incidentNumber)

    return $incident
}



