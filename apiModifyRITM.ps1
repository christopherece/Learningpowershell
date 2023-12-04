
# Provide your credentials
$cred = Get-Credential


# ServiceNow instance details
$ServiceNowInstance = "aklcdev"

# ServiceNow instance Personal
$ServiceNowInstance = "dev185867"

# ServiceNow instance 
$baseUrl = New-ServiceNowSession -Url "${ServiceNowInstance}.service-now.com" -Credential $cred

#Get Tasks from RITM
#$ritmDetails = Get-ServiceNowRecord -ParentId RITM0341949
$ritmDetails = Get-ServiceNowRecord -Id RITM0341949

$ritmDetails.assigned_to.display_value
$ritm_sys_id = $ritmDetails.sys_id

# ServiceNow REST API URL for the specified RITM
$Url = "https://${ServiceNowInstance}.service-now.com/api/now/table/sc_req_item/$ritm_sys_id"


# JSON payload with the fields you want to modify
$Payload = @{
    assigned_to = "Chris Ancheta"  # Replace with the new value
    u_quick_view_notes = "ekePanuku User"
    sys_user_group = "Service Desk"
    short_description = "Send to Tlc"
    description = "Send To TLC for repair, waiting for PO"
    comments_and_work_notes =  "New Notes123456789"
    work_notes_list = "New Notes123456789"
    
   
} | ConvertTo-Json

# Make the HTTP request to update the task
$response = Invoke-RestMethod -Uri $Url -Method Patch -Credential $cred -Headers @{ "Content-Type" = "application/json" } -Body $Payload


$response.result

