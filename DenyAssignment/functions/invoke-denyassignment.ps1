function Invoke-DenyAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true)]
        [string]$JsonBody,

        [Parameter(Mandatory = $false)]
        [switch]$WhatIf
    )

    # Parse the JSON to extract the deny assignment ID
    try {
        $denyAssignmentObject = $JsonBody | ConvertFrom-Json
        $denyAssignmentId = $denyAssignmentObject.name
    }
    catch {
        Write-Error "Failed to parse JSON or extract deny assignment ID: $_"
        return
    }

    # Construct the URL
    $apiVersion = "2024-07-01-preview"
    $url = "https://management.azure.com/subscriptions/$SubscriptionId/providers/Microsoft.Authorization/denyAssignments/$denyAssignmentId`?api-version=$apiVersion"

    Write-Verbose "Creating deny assignment with ID: $denyAssignmentId"
    Write-Verbose "URL: $url"

    if ($WhatIf) {
        Write-Host "What if: Would create deny assignment with ID $denyAssignmentId in subscription $SubscriptionId" -ForegroundColor Yellow
        Write-Host "Request URL: $url" -ForegroundColor Yellow
        Write-Host "Request body: $JsonBody" -ForegroundColor Yellow
        return
    }

    try {
       
            Write-Verbose "Using Az PowerShell module for authentication"
            $response = Invoke-AzRestMethod -Method PUT -Uri $url -Payload $JsonBody
            
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
                Write-Host "Successfully created deny assignment (response code: $($response.StatusCode))"
                return $response.Content
            }
            else {
                Write-Host "Failed to create deny assignment. Status code: $($response.StatusCode). Error: $($response.Content)"
                return $response.Content
            }
        
    }
    catch {
        Write-Error "Error creating deny assignment: $_"
        throw
    }
}

# Export function when the script is dot-sourced
Export-ModuleMember -Function Invoke-DenyAssignment