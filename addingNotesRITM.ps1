# Provide your credentials
$cred = Get-Credential

# ServiceNow instance details
$ServiceNowInstance = "aklcdev"

# Personal ServiceNow instance details
$ServiceNowInstance = "dev185867"

# ServiceNow instance information Personal Dev
$baseUrl = New-ServiceNowSession -Url "${ServiceNowInstance}.service-now.com" -Credential $cred

#Get Individual Properties
$ritmDetails = Get-ServiceNowRecord -Id RITM0341949 -Property 'short_description','sys_id','assigned_to','description'

#Get All Properties
$ritmSysID = $ritmDetails.sys_id

# ServiceNow REST API URL for the specified RITM
$notesUrl = "https://${ServiceNowInstance}.service-now.com/api/now/table/sys_journal_field?sysparm_limit=100&element_id=$ritmSysID&element=comments&sysparm_query=ORDERBYDESCsys_created_on"
#$notesUrl = "https://${ServiceNowInstance}.service-now.com/api/now/table/sys_journal_field?sysparm_query=number=$tasksysNumber&sysparm_include=true"

#fix for the query of Worknotes
$response = Invoke-RestMethod -Uri $notesUrl -Method Get -Credential $cred -Headers @{ "Content-Type" = "application/json" }

# Define the content of the new note (for POST request)
$newNoteContent = "This is a new note added via PowerShell."


# Make a POST request to add a new note to a specific record

$notesAddUrl = "https://${ServiceNowInstance}.service-now.com/api/now/table/sys_journal_field?sysparm_limit=100&element_id=$ritmSysID"

$requestBody  = @{
    "element_id" = $ritmSysID
    "comments"      = $newNoteContent
    "work_notes" = $newNoteContent
    # Add additional properties as needed
}

$requestjsonPayload = $requestBody | ConvertTo-Json

$response = Invoke-RestMethod -Uri $notesAddUrl -Method Post -Credential $cred -Headers @{ "Content-Type" = "application/json" } -Body $requestjsonPayload
# Display the response (optional)
$response.result


