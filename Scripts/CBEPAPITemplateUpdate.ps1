#requires -version 5.0

using module ..\Classes\CBEPAPIComputerClass.psm1
using module ..\Classes\CBEPAPITemplateClass.psm1
using module ..\Classes\CBEPAPISessionClass.psm1

<#
        .SYNOPSIS
        This script is designed to be used with a VDI environment to automate template updates.
        .DESCRIPTION
        This script uses the CB Protection API to automate the deletion and creation of templates so that child machines start up with the most recent catalog and have the most recent file list in CBEP.
        In order to accomplish this, the target "golden image" needs to be fully synchronized and needs to be powered off. Once that is done, the script will delete the old template and create
        a new one based on the powered off computer.
        .PARAMETER computerName
        [string] - This is the name of your "golden image" machine
        .PARAMETER timeout
        [system.int32] - This is the time in minutes that the script should wait for the machine to be ready to convert to a template. The defaut value is 1 minute.
        .EXAMPLE
        C: <PS> .\CBEPAPITemplateUpdate.ps1 -computerName GOLDEN_IMAGE -timeout 5
        .NOTES
        CB PowerShell Toolkit v2.0
        Copyright (C) 2017 Thomas Brackin

        Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction,
        including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
        and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
        
        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
        IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
        ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

Param(
    [Parameter(
        Mandatory=$true,
        ValueFromPipeline=$true
    )]
    [string[]]$computerName
    [Parameter(
    )]
    [system.int32]$timeout = 1
)

# Start default session block
$Session = [CBEPSession]::new()
$sessionResult = $Session.Initialize()
If ($sessionResult.HttpStatus -ne '200'){
    return $sessionResult
}
# End default session block

$timespan = New-TimeSpan -Minutes $timeout
$Computer = [CBEPComputer]::new()
$Template = [CBEPTemplate]::new()

$Computer.Get($computerName, $null, $session)

If ($Computer.computer.length -gt 1){
    Write-Error -Message ("Multiple computers with the same name detected. Please remediate and try again.")
    Return
}

# While the computer is connected or not fully synced, or we have not hit our timeout, update our information about it
$stopWatch = [Diagnostics.Stopwatch]::StartNew()
While ($stopWatch.ElapsedMilliseconds -lt $timespan.TotalMilliseconds){
    If (!($Computer.computer.connected -eq "True")){
        Break
    }
    Start-Sleep -Seconds 25
    $Computer.Get($null, $Computer.computer.Id, $session)
}

If ($Computer.computer.connected -eq "True"){
    Write-Error -Message ("Target computer is still connected.")
    Return
}
If ($Computer.computer.syncPercent -lt '100'){
    Write-Error -Message ("Target computer is not fully syncronized.")
    Return
}

$Template.Get($null, $Computer.computer.templateComputerId, $session)
$Template.Delete($Template.template.Id, $session)
$Computer.Convert($Computer.computer.Id, $session)
$Template.Get($null, $Computer.computer.Id, $session)

Write-Output $Template.template