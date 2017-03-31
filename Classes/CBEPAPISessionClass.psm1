#requires -version 5

<#
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

# This class is for creating a session object that holds the relevant session data for the api connection
# It also includes the methods for a GET and PUSH on the Restful API call
class CBEPSession{
    [system.object]$apiHeader = @{}
    [string]$apiUrl
    [securestring]$apiKey

    # Parameters required: none
    # Returns: Object - The response code information from the test connection to the session
    # This method will save the session information needed to access the api
    # Check to make sure the config has been run
    # This will pull in the json with the encrypted values, decrypt, and create a session from them
    # It also clears up the memory from the decryption process
    [system.object] Initialize (){
        try{
            $apiConfigTemp = ConvertFrom-Json "$(get-content $(Join-Path $env:localappdata "CBConfig\CBEPApiConfig.json"))"
        }
        catch{
            return $null
        }

        # Decrypt url and create variable
        $Marshal = [System.Runtime.InteropServices.Marshal]
        $BstrUrl = $Marshal::SecureStringToBSTR(($apiConfigTemp.url | ConvertTo-SecureString))      
        $urlTemp = $Marshal::PtrToStringAuto($BstrUrl)
        $this.apiUrl = "https://$urlTemp/api/bit9platform/v1"

        # Convert encrypted api key to a secure string and save to a variable
        $this.apiKey = ConvertTo-SecureString $apiConfigTemp.key

        # Free encrypted variables from memory
        $Marshal::ZeroFreeBSTR($BstrUrl)
        
        # Test the session start
        $tempResponse = @{}
        try{
            $tempRequest = Invoke-WebRequest $this.apiUrl
            $tempResponse.Add("Message", "Test successful")
            $tempResponse.Add("HttpStatus", $tempRequest.StatusCode)
            $tempResponse.Add("HttpDescription", $tempRequest.StatusDescription)
        }
        catch{
            $statusCode = $_.Exception.Response.StatusCode.value__
            $statusDescription = $_.Exception.Response.StatusDescription
            $tempResponse.Add("Message", "Test failed")
            $tempResponse.Add("HttpStatus", $statusCode)
            $tempResponse.Add("HttpDescription", $statusDescription)
        }
        return $tempResponse
        # Test the session end
    }

    # Parameters required:  $urlQueryPart - the query part of the API call based on the API documentation
    # Returns:              $responseObject - the object that is returned from the API GET call
    # This method will do a get query on the api
    [system.object] Get ([string]$urlQueryPart){
        $tempResponse = @{}
        
        # Unencrypt the secure string for the key and create a header object
        $Marshal = [System.Runtime.InteropServices.Marshal]
        $this.apiHeader.'X-Auth-Token' = $Marshal::PtrToStringAuto($Marshal::SecureStringToBSTR($this.apiKey))

        try{
            $responseObject = Invoke-RestMethod -Headers $this.apiHeader -Method Get -Uri ($this.apiUrl + $urlQueryPart)
        }
        catch{
            $statusCode = $_.Exception.Response.StatusCode.value__
            $statusDescription = $_.Exception.Response.StatusDescription
            $tempResponse.Add("Message", "Problem with the GET call")
            $tempResponse.Add("Query", $urlQueryPart)
            $tempResponse.Add("HttpStatus", $statusCode)
            $tempResponse.Add("HttpDescription", $statusDescription)
            $responseObject = $tempResponse
        }

        # Null out the unencrypted header
        $this.apiHeader = @{}

        return $responseObject
    }

    # Parameters required:  $urlQueryPart - the query part of the API call based on the API documentation
    # Returns:              $responseFile - the file that is returned from the API GET call
    # This method will do a get query on the api
    [System.IO.FileInfo] GetFile ([string]$urlQueryPart){
        $tempResponse = @{}
        [System.IO.FileInfo]$responseFile = $null
        
        # Unencrypt the secure string for the key and create a header object
        $Marshal = [System.Runtime.InteropServices.Marshal]
        $this.apiHeader.'X-Auth-Token' = $Marshal::PtrToStringAuto($Marshal::SecureStringToBSTR($this.apiKey))

        $responseFile = Invoke-RestMethod -Headers $this.apiHeader -Method Get -Uri ($this.apiUrl + $urlQueryPart)

        # Null out the unencrypted header
        $this.apiHeader = @{}

        return $responseFile
    }

    # Parameters required:  $urlQueryPart - the query part of the API call based on the API documentation
    # Returns:              $responseObject - the object that is returned from the API POST call
    # This method will do a post query to the api
    [system.object] Post ([string]$urlQueryPart, [system.object]$jsonObject){
        $tempResponse = @{}

        # Unencrypt the secure string for the key and create a header object
        $Marshal = [System.Runtime.InteropServices.Marshal]
        $this.apiHeader.'X-Auth-Token' = $Marshal::PtrToStringAuto($Marshal::SecureStringToBSTR($this.apiKey))

        try{
            $responseObject = Invoke-RestMethod -Headers $this.apiHeader -Method Post -Uri ($this.apiUrl + $urlQueryPart) -Body $jsonObject -ContentType 'application/json'
        }
        catch{
            $statusCode = $_.Exception.Response.StatusCode.value__
            $statusDescription = $_.Exception.Response.StatusDescription
            $tempResponse.Add("Message", "Problem with the POST call")
            $tempResponse.Add("Query", $urlQueryPart)
            $tempResponse.Add("HttpStatus", $statusCode)
            $tempResponse.Add("HttpDescription", $statusDescription)
            $responseObject = $tempResponse
        }

        # Null out the unencrypted header
        $this.apiHeader = @{}

        return $responseObject
    }

    # Parameters required:  $urlQueryPart - the query part of the API call based on the API documentation
    # Returns:              $responseObject - the object that is returned from the API POST call
    # This method will do a post query to the api
    [system.object] Put ([string]$urlQueryPart, [system.object]$jsonObject){
        $tempResponse = @{}

        # Unencrypt the secure string for the key and create a header object
        $Marshal = [System.Runtime.InteropServices.Marshal]
        $this.apiHeader.'X-Auth-Token' = $Marshal::PtrToStringAuto($Marshal::SecureStringToBSTR($this.apiKey))

        try{
            $responseObject = Invoke-RestMethod -Headers $this.apiHeader -Method Put -Uri ($this.apiUrl + $urlQueryPart) -Body $jsonObject -ContentType 'application/json'
        }
        catch{
            $statusCode = $_.Exception.Response.StatusCode.value__
            $statusDescription = $_.Exception.Response.StatusDescription
            $tempResponse.Add("Message", "Problem with the PUT call")
            $tempResponse.Add("Query", $urlQueryPart)
            $tempResponse.Add("HttpStatus", $statusCode)
            $tempResponse.Add("HttpDescription", $statusDescription)
            $responseObject = $tempResponse
        }

        # Null out the unencrypted header
        $this.apiHeader = @{}

        return $responseObject
    }
}