# Get-WslShell: Detects and caches the user's preferred WSL shell
function Get-WslShell {
    if ($env:WSL_PREFERRED_SHELL) {
        return $env:WSL_PREFERRED_SHELL
    }

    $shell = (wsl -e sh -c 'echo $SHELL' 2>$null).Trim()
    if ([string]::IsNullOrWhiteSpace($shell)) {
        $shell = "/bin/bash"
    }

    $env:WSL_PREFERRED_SHELL = $shell
    return $shell
}

# Invoke-WslCommand: Run wsl commands from powershell
function global:Invoke-WslCommand {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )

    # Set the user Wsl shell
    $userShell = Get-WslShell

    $rawCommand = $Command + ' ' + ($Arguments -join ' ')

    if ($rawCommand -like '*->*') {
        # User has written a piped commando '->'
        $segments = $rawCommand -split '\s*->\s*'

        $convertedSegments = foreach ($segment in $segments) {
            $parts = $segment -split '\s+'
            if ($parts.Count -eq 0) { continue }

            $cmd = $parts[0]
            $args = @()
            if ($parts.Count -gt 1) {
                $args = $parts[1..($parts.Count - 1)]
            }

            $convertedArgs = foreach ($arg in $args) {
                if ($arg.StartsWith('-')) {
                    $arg
                }
                else {
                    try {
                        $resolvedPath = (Resolve-Path -LiteralPath $arg -ErrorAction Stop).Path
                        if ($resolvedPath -match '^([A-Za-z]):\\') {
                            $driveLetter = $matches[1].ToLower()
                            $unixPath = $resolvedPath `
                                -replace '^[A-Za-z]:\\', "/mnt/$driveLetter/" `
                                -replace '\\', '/'
                            "'$unixPath'"
                        } else {
                            "'$arg'"
                        }
                    } catch {
                        "'$arg'"
                    }
                }
            }

            "$cmd $($convertedArgs -join ' ')"
        }

        $bashCommand = $convertedSegments -join ' | '
        wsl -e $userShell -i -c "$bashCommand"
        return
    }

    # No piped command
    $convertedArgs = foreach ($arg in $Arguments) {
        if ($arg.StartsWith('-')) {
            $arg
        }
        else {
            try {
                $resolvedPath = (Resolve-Path -LiteralPath $arg -ErrorAction Stop).Path
                if ($resolvedPath -match '^([A-Za-z]):\\') {
                    $driveLetter = $matches[1].ToLower()
                    $unixPath = $resolvedPath `
                        -replace '^[A-Za-z]:\\', "/mnt/$driveLetter/" `
                        -replace '\\', '/'
                    "'$unixPath'"
                }
                else {
                    "'$arg'"
                }
            }
            catch {
                "'$arg'"
            }
        }
    }

    $escapedArgs = $convertedArgs -join ' '

    if ([string]::IsNullOrWhiteSpace($escapedArgs)) {
        wsl -e $userShell -i -c "$Command"
    }
    else {
        wsl -e $userShell -i -c "$Command $escapedArgs"
    }
}
