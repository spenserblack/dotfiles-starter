<#
.SYNOPSIS
    Register a file for the dotfiles repository.
.DESCRIPTION
    Register a file for the dotfiles repository.
.PARAMETER Path
    The path to the file to register.
.PARAMETER Suffix
    The suffix to append to the registered file.
.EXAMPLE
    register.ps1 -Path $Profile
.EXAMPLE
    register.ps1 -Path $Profile -Suffix Profile
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$Suffix = ""
)

$Suffix = $args[0]
$Dotfiles = $PSScriptRoot
$Destination = "$Dotfiles\registered$Suffix.txt"

# If the file to register does not exist, throw an error.
if (-not (Test-Path $Path)) {
    throw "File not found: $Path"
}

# The filename relative to $HOME
$RelativePath = $Path -replace [regex]::Escape("$HOME\"), ""
# If user used "~", replace it
$RelativePath = $RelativePath -replace "^~\\", ""
$RelativePath = $RelativePath -replace "^~/", ""

# NOTE: Normalize to "/"
$RelativePath = $RelativePath -replace "\\", "/"

# NOTE: Skip the file if it's already registered
if (Select-String -Path $Destination -Pattern "^$RelativePath$") {
    Write-Error "Already registered: $RelativePath"
    return
}

# NOTE: Since Windows doesn't usually have symlinks, we'll just copy the file
Copy-Item -Path "$Path" -Destination "$Dotfiles/$RelativePath"
Add-Content -Path "$Destination" -Value "$RelativePath"
Get-Content -Path "$Destination" | Sort-Object -InputObject "$Destination" | Set-Content -Path "$Destination"
git.exe -C "$Dotfiles" add "$Dotfiles/$RelativePath" "$Destination"
git.exe -C "$Dotfiles" commit -m "Register $RelativePath"
