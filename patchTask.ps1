
# Provide your credentials
$cred = Get-Credential


# ServiceNow instance details
$ServiceNowInstance = "aklcdev"

# ServiceNow instance Personal
$ServiceNowInstance = "dev185867"

# ServiceNow instance 
$baseUrl = New-ServiceNowSession -Url "${ServiceNowInstance}.service-now.com" -Credential $cred

$ritmTasks = Get-ServiceNowRecord -Table 'task' -ParentId 'RITM0341634'
$taskNumberSysId = $ritmTasks.sys_id[0] #FirstTask Index 0

# Specify the sys_id of the sc_task record you want to modify
$scTaskSysId = $taskNumberSysId

# ServiceNow REST API URL for the specified task
$Url = "https://${ServiceNowInstance}.service-now.com/api/now/table/task/$scTaskSysId"

# JSON payload with the fields you want to modify
$Payload = @{
    assign_to = "Chris Ancheta"
    description = "Edited Description"  # Replace with the new value
    short_description = "This is New Short Description123"
    comments_and_work_notes =  "New Notes"
    work_notes = "New Notes"
   
} | ConvertTo-Json

# Make the HTTP request to update the task
$response = Invoke-RestMethod -Uri $Url -Method Patch -Credential $cred -Headers @{ "Content-Type" = "application/json" } -Body $Payload


$response.result
