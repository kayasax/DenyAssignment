function Remove-DenyAssignment {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Subscription')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'Subscription')]
        [string]$SubscriptionId,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Scope')]
        [ValidatePattern('^/providers/Microsoft.Management/managementGroups/|/subscriptions/|/resourceGroups/')]
        [string]$Scope,
        
        [Parameter(Mandatory = $true)]
        [string]$DenyAssignmentId,
        
        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = "2024-07-01-preview"
    )
    
    # Construct the URL based on parameter set
    $baseUrl = if ($PSCmdlet.ParameterSetName -eq 'Subscription') {
        "https://management.azure.com/subscriptions/$SubscriptionId"
    } else {
        "https://management.azure.com$Scope"
    }
    
    $url = "$baseUrl/providers/Microsoft.Authorization/denyAssignments/$DenyAssignmentId`?api-version=$ApiVersion"
    
    Write-Verbose "Preparing to delete deny assignment: $DenyAssignmentId"
    Write-Verbose "URL: $url"
    
    # Check if the user wants to proceed
    $target = if ($PSCmdlet.ParameterSetName -eq 'Subscription') {
        "Deny Assignment $DenyAssignmentId in subscription $SubscriptionId"
    } else {
        "Deny Assignment $DenyAssignmentId in scope $Scope"
    }

    if ($PSCmdlet.ShouldProcess($target, "Delete")) {
        try {
            $response = Invoke-AzRestMethod -Method DELETE -Uri $url
            
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
                Write-Verbose "Successfully deleted deny assignment"
                return [PSCustomObject]@{
                    DenyAssignmentId = $DenyAssignmentId
                    Scope = if ($PSCmdlet.ParameterSetName -eq 'Subscription') { "/subscriptions/$SubscriptionId" } else { $Scope }
                    StatusCode = $response.StatusCode
                    Success = $true
                    Message = "Deny assignment successfully deleted"
                }
            }
            else {
                Write-Error "Failed to delete deny assignment. Status code: $($response.StatusCode). Error: $($response.Content)"
                return [PSCustomObject]@{
                    DenyAssignmentId = $DenyAssignmentId
                    Scope = if ($PSCmdlet.ParameterSetName -eq 'Subscription') { "/subscriptions/$SubscriptionId" } else { $Scope }
                    StatusCode = $response.StatusCode
                    Success = $false
                    Message = "Failed to delete deny assignment"
                    ErrorDetails = $response.Content
                }
            }
        }
        catch {
            Write-Error "Error deleting deny assignment: $_"
            return [PSCustomObject]@{
                DenyAssignmentId = $DenyAssignmentId
                Scope = if ($PSCmdlet.ParameterSetName -eq 'Subscription') { "/subscriptions/$SubscriptionId" } else { $Scope }
                Success = $false
                Message = "Error deleting deny assignment"
                ErrorDetails = $_.Exception.Message
            }
        }
    }
}

Export-ModuleMember -Function Remove-DenyAssignment