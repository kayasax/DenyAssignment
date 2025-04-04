# Add debug output to see what's happening
Write-Verbose "PSScriptRoot: $PSScriptRoot"

$internalFunctionsPath = "$PSScriptRoot/internal/functions"
Write-Verbose "Looking for internal functions in: $internalFunctionsPath"
$internalFunctions = Get-ChildItem -Path $internalFunctionsPath -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue
Write-Verbose "Found $($internalFunctions.Count) internal function files"
foreach ($file in $internalFunctions) {
    Write-Verbose "Importing internal function file: $($file.FullName)"
    . $file.FullName
}

$functionsPath = "$PSScriptRoot/functions"
Write-Verbose "Looking for functions in: $functionsPath"
$functions = Get-ChildItem -Path $functionsPath -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue
Write-Verbose "Found $($functions.Count) function files"
foreach ($file in $functions) {
    Write-Verbose "Importing function file: $($file.FullName)"
    . $file.FullName
}

$scriptsPath = "$PSScriptRoot/internal/scripts"
Write-Verbose "Looking for scripts in: $scriptsPath"
$scripts = Get-ChildItem -Path $scriptsPath -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue
Write-Verbose "Found $($scripts.Count) script files"
foreach ($file in $scripts) {
    Write-Verbose "Importing script file: $($file.FullName)"
    . $file.FullName
}

# Explicitly export all functions
Write-Verbose "Exporting functions: New-DenyAssignment, Invoke-DenyAssignment, Get-DenyAssignment"
Export-ModuleMember -Function New-DenyAssignment, Invoke-DenyAssignment, Get-DenyAssignment
