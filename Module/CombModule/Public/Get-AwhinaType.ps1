function Get-AwhinaType {
        #Get Parameters
        param (
            # Parameter help description
            [Parameter(Mandatory=$true)]
            [string]$userInput
        )

        $cred = Get-AdminCredential
        $userInput = $userInput
        # ServiceNow instance details
        $ServiceNowInstance = "aklcdev"
        # ServiceNow instance 
        New-ServiceNowSession -Url "${ServiceNowInstance}.service-now.com" -Credential $cred

    # Check the prefix of the typed string using switch
    switch -Wildcard ($userInput) {
        'RITM*' {
            Get-Ritm $userInput
            break
            }
        'INC*' {
            Get-Incident $userInput
            break        

                }
        'SCTA*' {
            Get-Taskno $userInput
            break
        }
        default {
            Write-Host "No matching switch case for the given string."
            # Add default actions here
            break
        }
    }

}


function Get-Ritm($userInput){
    
        $ritmDetails = Get-ServiceNowRecord -Id $userInput
        $ritm_sys_id = $ritmDetails.sys_id

   

        # ServiceNow REST API URL for the specified RITM
        #$notesUrl = "https://${ServiceNowInstance}.service-now.com/api/now/table/sc_req_item/${ritm_sys_id}"
        # Specify HTTP method
        #$method = "patch"

        # Define the content of the new note (for PATCH request)
        $assigned_to = Read-Host "Enter Assigned To"
        $newShortDesc = Read-Host "Enter New Short Description"
        $comments = Read-Host "Enter Quick View Notes"
        $description = Read-Host "Enter Description"
        $assignment_group = Read-Host "Enter Assignment Group"

        # JSON payload with the fields you want to modify
        $requestBody = @{
            "assigned_to" = $assigned_to
            "assignment_group" = $assignment_group
            "short_description" = $newShortDesc
            "description" = $description
            "comments" = $comments
            }

        #TryServiceNow Module
        Update-ServiceNowRecord -Table 'Incident' -ID $ritm_sys_id -InputData $requestBody
           
        
        #$requestjsonPayload = $requestBody | ConvertTo-Json

         # Make the HTTP request to update the RITM
        #$response = Invoke-RestMethod -Uri $notesUrl -Method $method -Credential $cred -Headers @{ "Content-Type" = "application/json" } -Body $requestjsonPayload

        #$response.result
    }

    function Get-Incident ($userInput) {
           
        #Get Individual Properties (can be all)
        $incDetails = Get-ServiceNowRecord -Id $userInput -Property 'short_description','sys_id','assigned_to','description'
        #Get unique sys_id
        $userInput = $incDetails.sys_id
       # ServiceNow REST API URL for Task using SCTASKxxxxx 
        $notesUrl = "https://${ServiceNowInstance}.service-now.com/api/now/table/incident/${userInput}?sysparm_limit=10&sysparm_display_value=true"
        
        # Define the content of the new note (for POST request)
        $newComments = Read-Host "Enter New Comments (Seen by User)"
        $newShortDesc = Read-Host "Enter New Short Description"
        $quick_view_notes = Read-Host "Enter Quick View Notes"
        $description = Read-Host "Enter Description"
        $assignment_group = Read-Host "Enter Assignment Group"
    
        $requestBody  = @{
            "comments" = $newComments #notes seen by end user
            "short_description" = $newShortDesc
             "description" = $description
             "u_quick_view_notes" = $quick_view_notes
             "work_notes" = $quick_view_notes
             "assignment_group" = $assignment_group 
             "assigned_to" = "Chris Ancheta"
            
            # Add additional properties as needed
        }
            $requestjsonPayload = $requestBody | ConvertTo-Json
        
            $response = Invoke-RestMethod -Uri $notesUrl -Method Patch -Credential $cred -Headers @{ "Content-Type" = "application/json" } -Body $requestjsonPayload
        
            $response.result
            Write-Host "Changes Has been Made to the incident $IncidentNumber"
                    
    }   

    function Get-Taskno ($userInput) {
                  
        #Get Individual Properties (can be all)
        $TaskDetail = Get-ServiceNowRecord -Id $userInput -Property 'short_description','sys_id','assigned_to','description'
        #Get unique sys_id
        $taskSysID = $TaskDetail.sys_id

        #Get Parent RITM
        $parentRITM = Get-ParentRITMByTask($userInput)
        Write-Host " The PArent RITM is : $parentRITM"

       # ServiceNow REST API URL for Task using SCTASKxxxxx 
        $notesUrl = "https://${ServiceNowInstance}.service-now.com/api/now/table/task/${taskSysID}"
        
        # Define the content of the new note (for PATCH request)
        $newComments = Read-Host "Enter New Comments (Seen by User)"
        $newShortDesc = Read-Host "Enter New Short Description"
        $quick_view_notes = Read-Host "Enter Quick View Notes"
        $description = Read-Host "Enter Description"
        $assignment_group = Read-Host "Enter Assignment Group"
    
        $requestBody  = @{
            "comments" = $newComments #notes seen by end user
            "short_description" = $newShortDesc
             "description" = $description
             "u_quick_view_notes" = $quick_view_notes
             "work_notes" = $quick_view_notes
             "assignment_group" = $assignment_group 
             "assigned_to" = "Chris Ancheta"
            
            # Add additional properties as needed
        }
        $requestjsonPayload = $requestBody | ConvertTo-Json
    
        $response = Invoke-RestMethod -Uri $notesUrl -Method Patch -Credential $cred -Headers @{ "Content-Type" = "application/json" } -Body $requestjsonPayload
        
        return $response
        
    }   


#Get PArent RITM
function Get-ParentRITMByTask ($userInput){
    
    #Get RITM from TASK
    $taskDetail = Get-ServiceNowRecord -Table task -Filter ('number','-eq', $userInput)
    $parentRITM = $taskDetail.parent.display_value
    return $parentRITM

}
# Example usage
#Get-ParentRITMByTaskSysID -taskSysID "your_task_sys_id"