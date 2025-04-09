function New-DenyAssignment {
    [CmdletBinding(DefaultParameterSetName = 'Subscription')]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$ExcludePrincipals,
        
        [Parameter(Mandatory = $true)]
        [string[]]$Actions,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Subscription')]
        [string]$SubscriptionId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Scope')]
        [ValidatePattern('^/providers/Microsoft.Management/managementGroups/|/subscriptions/|/resourceGroups/')]
        [string]$Scope,

        [Parameter(Mandatory = $false)]
        [string]$Name = [System.Guid]::NewGuid().ToString(),
        
        [Parameter(Mandatory = $false)]
        [string]$DenyAssignmentName = "Test",
        
        [Parameter(Mandatory = $false)]
        [string]$Description = "Test"
    )
    
    # Process exclude principals
    $formattedExcludePrincipals = @()
    foreach ($id in $ExcludePrincipals) {
        $formattedExcludePrincipals += @{
            id = $id
            #type = "User"
        }
    }
    
    # Create the JSON structure
    $denyAssignment = @{
        name = $Name
        properties = @{
            condition = $null
            conditionVersion = $null
            denyAssignmentName = $DenyAssignmentName
            description = $Description
            doNotApplyToChildScopes = $false
            excludePrincipals = $formattedExcludePrincipals
            isSystemProtected = $false
            permissions = @(
                @{
                    actions = $Actions
                    dataActions = @()
                    notActions = @()
                    notDataActions = @()
                }
            )
            principals = @(
                @{
                    id = "00000000-0000-0000-0000-000000000000"
                    type = "SystemDefined"
                }
            )
        }
        type = "Microsoft.Authorization/denyAssignments"
    }
    
    # Convert to JSON
    $json = $denyAssignment | ConvertTo-Json -Depth 10

    # Call Invoke-DenyAssignment with appropriate parameters
    if ($PSCmdlet.ParameterSetName -eq 'Subscription') {
        Invoke-DenyAssignment -SubscriptionId $SubscriptionId -JsonBody $json
    }
    else {
        Invoke-DenyAssignment -Scope $Scope -JsonBody $json
    }
}