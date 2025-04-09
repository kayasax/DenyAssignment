function Invoke-DenyAssignment {
    [CmdletBinding(DefaultParameterSetName = 'Subscription')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Subscription')]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Scope')]
        [ValidatePattern('^/providers/Microsoft.Management/managementGroups/|/subscriptions/|/resourceGroups/')]
        [string]$Scope,
        
        [Parameter(Mandatory = $true)]
        [string]$JsonBody,
        
        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2024-07-01-preview"
    )
    
    try {
        # Parse the JSON to extract the deny assignment ID
        $denyAssignmentObject = $JsonBody | ConvertFrom-Json
        $denyAssignmentId = $denyAssignmentObject.name
    }
    catch {
        Write-Error "Failed to parse JSON or extract deny assignment ID: $_"
        return
    }

    # Construct the URL based on parameter set
    $baseUrl = if ($PSCmdlet.ParameterSetName -eq 'Subscription') {
        "https://management.azure.com/subscriptions/$SubscriptionId"
    } else {
        "https://management.azure.com$Scope"
    }
    
    $url = "$baseUrl/providers/Microsoft.Authorization/denyAssignments/$denyAssignmentId`?api-version=$ApiVersion"
    
    Write-Verbose "Creating deny assignment with ID: $denyAssignmentId"
    Write-Verbose "URL: $url"
    
    try {
        # Use Az module for authentication
        $response = Invoke-AzRestMethod -Method PUT -Uri $url -Payload $JsonBody
        
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
            Write-Verbose "Successfully created deny assignment"
            return $response.Content | ConvertFrom-Json
        }
        else {
            Write-Error "Failed to create deny assignment. Status code: $($response.StatusCode). Error: $($response.Content)"
            return $response.Content
        }
    }
    catch {
        Write-Error "Error creating deny assignment: $_"
        throw
    }
}

Export-ModuleMember -Function Invoke-DenyAssignment