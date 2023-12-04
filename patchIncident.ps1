
# Provide your credentials
$cred = Get-Credential


# ServiceNow instance details
$ServiceNowInstance = "aklcdev"

# ServiceNow instance Personal
$ServiceNowInstance = "dev185867"

# ServiceNow instance 
$baseUrl = New-ServiceNowSession -Url "${ServiceNowInstance}.service-now.com" -Credential $cred

#Get Individual Properties (can be all)
$incDetails = Get-ServiceNowRecord -Id INC0474552 -Property 'short_description','sys_id','assigned_to','description'

#Get unique sys_id
$incidentSysID = $incDetails.sys_id

# ServiceNow REST API URL for the specified RITM
$notesUrl = "https://${ServiceNowInstance}.service-now.com/api/now/table/incident/${incidentSysID}?sysparm_limit=10&sysparm_display_value=true"

#fix for the query of Worknotes Need to have Header
$response = Invoke-RestMethod -Uri $notesUrl -Method Get -Credential $cred -Headers @{ "Content-Type" = "application/json" }

# Define the content of the new note (for POST request)
$newNoteContent = "This is a new note added via PowerShell again."


# Make a POST request to add a new note to a specific record

$requestBody  = @{
    "comments"      = "This is a new note added via PowerShell3" #notes seen by end user
    "short_description" = "This is a short description"   
     "description" = "This is a New Descripttion from Powershell"
     "u_quick_view_notes" = "This is the quick view notes"
     "work_notes" = "This is a work Note"
     "assignment_group" = "Service Desk"
     
     
    
    # Add additional properties as needed
}

$requestjsonPayload = $requestBody | ConvertTo-Json

$response = Invoke-RestMethod -Uri $notesUrl -Method Patch -Credential $cred -Headers @{ "Content-Type" = "application/json" } -Body $requestjsonPayload
# Display the response (optional)
$response.result


