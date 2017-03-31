#requires -version 5.0

using module ..\Classes\CBEPAPIComputerClass.psm1
using module ..\Classes\CBEPAPISessionClass.psm1

<#
        .SYNOPSIS
        This script takes in a computer name and gets the full computer info from CBEP
        .DESCRIPTION
        This script will get a computer from CBEP as long as the computer is not deleted. It looks for a computer name just as it appears in the console.
        For example, if your computers are all on a domain called DOMAINABC, the computer name would look like this: DOMAINABC\Computer1
        The input can accept wildcards if you don't want to add the full name OR if you want to get multiple computers with a common set of characters.
        .PARAMETER computerName
        The name of the computer you wish to get. Wildcards are accepted.
        .EXAMPLE
        C: <PS> .\CBEPAPIGetComputer.ps1 -computername *computer00*
        This will get any computer matching the characters with the wildcards before and after the string
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
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true
    )]
    [string[]]$computerName
)

# Start default session block
$Session = [CBEPSession]::new()
$sessionResult = $Session.Initialize()
If ($sessionResult.HttpStatus -ne '200'){
    return $sessionResult
}
# End default session block

$Computer = [CBEPComputer]::new()

$Computer.Get($computerName, $null, $Session)

Write-Output $Computer.computer