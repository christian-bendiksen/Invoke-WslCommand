# Invoke-WslCommand.
# Run stuff from WSL within Powershell.
# Ex. cat, grep, etc.
function global:Invoke-WslCommand {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )

    # Convert Windows paths to WSL-compatible paths
    $convertedArgs = foreach ($arg in $Arguments) {
        if ($arg.StartsWith('-')) {
            # Pass flags as-is
            $arg
        }
        else {
            try {
                # Resolve path if possible
                $resolvedPath = (Resolve-Path -LiteralPath $arg -ErrorAction Stop).Path

                # Check for Windows-style drive letter
                if ($resolvedPath -match '^([A-Za-z]):\\') {
                    $driveLetter = $matches[1].ToLower()
                    $unixPath = $resolvedPath `
                        -replace '^[A-Za-z]:\\', "/mnt/$driveLetter/" `
                        -replace '\\', '/'
                    
                    # Return quoted path to handle spaces and special chars
                    "'$unixPath'"
                }
                else {
                    # Non-standard paths are returned unchanged, quoted
                    "'$arg'"
                }
            }
            catch {
                # If resolution fails, pass the original argument quoted
                "'$arg'"
            }
        }
    }

    # Join arguments safely
    $escapedArgs = $convertedArgs -join ' '

    # Invoke WSL command with converted and escaped arguments
    if ([string]::IsNullOrWhiteSpace($escapedArgs)) {
        wsl bash -i -c "$Command"
    }
    else {
        wsl bash -i -c "$Command $escapedArgs"
    }
}
