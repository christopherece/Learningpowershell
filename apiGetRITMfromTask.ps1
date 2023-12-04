
# Provide your credentials
$cred = Get-Credential


# ServiceNow instance details
$ServiceNowInstance = "aklcdev"

# ServiceNow instance Personal
$ServiceNowInstance = "dev185867"

# ServiceNow instance 
$baseUrl = New-ServiceNowSession -Url "${ServiceNowInstance}.service-now.com" -Credential $cred

# ServiceNow instance information Personal Dev
$baseUrl = New-ServiceNowSession -Url "${ServiceNowInstance}.service-now.com" -Credential $cred
#Get RITM from TASK
$taskDetail = Get-ServiceNowRecord -Table task -Filter ('number','-eq','SCTASK0785182')
#get sys_id
$tasksys_id = $taskDetail.sys_id

$parentRITM = $taskDetail.parent.display_value


#UsingAPI to get Parent RITM
$tasksysNumber = "SCTASK0785182"


# ServiceNow REST API URL for Task using SCTASKxxxxx
$Url = "https://${ServiceNowInstance}.service-now.com/api/now/table/sc_task?sysparm_query=number=$tasksysNumber&sysparm_include=true"

# Make the HTTP request to get the task
$response = Invoke-RestMethod -Uri $Url -Method Get -Credential $cred -Headers @{ "Content-Type" = "application/json" }
#optional to check
$response.result


# Check if the task was found
if ($response.result.Count -eq 1) {
    $ritmSysID = $response.result[0].request_item.value  #get the Parent Value sys_id of ther RITM
    
    # Construct the REST API URL to get the RITM details
    $ritmUrl = "https://aklcdev.service-now.com/api/now/table/sc_req_item/$ritmSysID"
    
    # Make a GET request to the ServiceNow API
    $ritmResponse = Invoke-RestMethod -Uri $ritmUrl -Method Get -Credential $cred
    
    # Check if the RITM was found
    if ($ritmResponse.result) {
        $ritmNumber = $ritmResponse.result.number
        Write-Host "RITM Number: $ritmNumber"
    } else {
        Write-Host "RITM not found"
    }
} else {
    Write-Host "Task not found"
}

