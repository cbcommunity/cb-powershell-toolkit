#requires -version 5.0

using module ..\Classes\CBEPAPIFileClass.psm1
using module ..\Classes\CBEPAPISessionClass.psm1

<#
        .SYNOPSIS
        This script takes in a hash and an optional name and creates a file ban rule in CBEP
        .DESCRIPTION
        This script is intented for use in the CB Protection Powershell Toolkit. It will globally ban any hash given using a file rule.
        .PARAMETER hash
        [string] - This variable can be either an MD5 hash or SHA256 hash
        .PARAMETER name
        [string] - This is the name of the file or any other name you choose to mark the hash rule
        .EXAMPLE
        C: <PS> .\CBEPAPIBanFileHash -hash 1234567891234567890 -name FileBan1
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
    [parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
    )]
    [string]$hash,
    [parameter(
        Mandatory = $false,
        ValueFromPipeline =$true
    )]
    [string]$name
)

If (!$name){
    $name = $hash
}

# Start default session block
$Session = [CBEPSession]::new()
$sessionResult = $Session.Initialize()
If ($sessionResult.HttpStatus -ne '200'){
    return $sessionResult
}
# End default session block

$File = [CBEPFile]::new()
$File.CreateRule('0', $name, $null, '3', $null, $null, $null, $null, $null, $hash, '7')