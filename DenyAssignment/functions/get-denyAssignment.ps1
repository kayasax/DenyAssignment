function Get-DenyAssignment {
    [CmdletBinding(DefaultParameterSetName = 'Subscription')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Subscription')]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Scope')]
        [ValidatePattern('^/providers/Microsoft.Management/managementGroups/|/subscriptions/|/resourceGroups/')]
        [string]$Scope,
        
        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2024-07-01-preview",
        
        [Parameter(Mandatory = $false)]
        [switch]$Raw
    )

    # Construct the URL based on parameter set
    $baseUrl = if ($PSCmdlet.ParameterSetName -eq 'Subscription') {
        "https://management.azure.com/subscriptions/$SubscriptionId"
    } else {
        "https://management.azure.com$Scope"
    }
    
    $url = "$baseUrl/providers/Microsoft.Authorization/denyAssignments?api-version=$ApiVersion"

    Write-Verbose "Querying deny assignments for $($PSCmdlet.ParameterSetName): $($PSCmdlet.ParameterSetName -eq 'Subscription' ? $SubscriptionId : $Scope)"
    Write-Verbose "URL: $url"

    try {
        $response = Invoke-AzRestMethod -Method GET -Uri $url
        
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
            Write-Verbose "Successfully retrieved deny assignments"
            # Convert the JSON string to PowerShell objects
            $result = $response.Content | ConvertFrom-Json
            
            # Return raw result if requested
            if ($Raw) {
                return $result
            }
            
            # Process and expand the values for better output
            if ($result.value -and $result.value.Count -gt 0) {
                Write-Verbose "Processing $($result.value.Count) deny assignments"
                
                # Return expanded objects with relevant properties
                return $result.value | ForEach-Object {
                    [PSCustomObject]@{
                        Name = $_.name
                        Id = $_.id
                        Type = $_.type
                        DenyAssignmentName = $_.properties.denyAssignmentName
                        Description = $_.properties.description
                        Scope = ($_.id -split '/providers/Microsoft.Authorization/denyAssignments')[0]
                        Principals = $_.properties.principals
                        ExcludePrincipals = $_.properties.excludePrincipals
                        Actions = $_.properties.permissions.actions
                        NotActions = $_.properties.permissions.notActions
                        DataActions = $_.properties.permissions.dataActions
                        NotDataActions = $_.properties.permissions.notDataActions
                        DoNotApplyToChildScopes = $_.properties.doNotApplyToChildScopes
                        IsSystemProtected = $_.properties.isSystemProtected
                        RawObject = $_  # Include the raw object for reference
                    }
                }
            }
            else {
                Write-Verbose "No deny assignments found in the subscription"
                return @()
            }
        }
        else {
            Write-Error "Failed to retrieve deny assignments. Status code: $($response.StatusCode). Error: $($response.Content)"
            return $response.Content
        }
    }
    catch {
        Write-Error "Error retrieving deny assignments: $_"
        throw
    }
}

Export-ModuleMember -Function Get-DenyAssignment

