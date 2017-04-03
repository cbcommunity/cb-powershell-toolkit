#requires -version 5.0

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

# This class is for creating a file object that can hold both local and global file information
# It also includes methods for manipulating this information
class CBEPFile{
    [system.object]$fileCatalog
    [system.object]$fileInstance

    # Parameters required:  $fileCatalogId - this is the ID of a file in the catalog
    #                       $session - this is a session object from the CBEPSession class
    # This method will use an open session to ask for a get query on the api
    [void] GetCatalog ([string]$fileCatalogId, [system.object]$session){
        $urlQueryPart = "/fileCatalog?q=id:" + $fileCatalogId
        $tempFile = $session.get($urlQueryPart)
        If ($this.fileCatalog){
            $i = 0
            While ($i -lt $this.fileCatalog.length){
                If ($this.fileCatalog[$i].id -eq $tempFile.id){
                    $this.fileCatalog[$i] = $tempFile
                    return
                }
                $i++
            }
        }
        $this.fileCatalog += $tempFile
    }

    # Parameters required:  $fileCatalogId - this is the ID of a file in the catalog
    #                       $computerId - this is the ID of a computer that the file is on
    #                       $session - this is a session object from the CBEPSession class
    # This method will use an open session to ask for a get query on the api
    [void] GetInstance ([string]$fileCatalogId, [string]$computerId, [system.object]$session){
        $urlQueryPart = "/fileInstance?q=fileCatalogId:" + $fileCatalogId + "&q=computerId:" + $computerId
        $tempFile = $session.get($urlQueryPart)
        If ($this.fileInstance){
            $i = 0
            While ($i -lt $this.fileInstance.length){
                If ($this.fileInstance[$i].id -eq $tempFile.id){
                    $this.fileInstance[$i] = $tempFile
                    return
                }
                $i++
            }
        }
        $this.fileInstance += $tempFile
    }

    # Parameters required:  $fileCatalogId - this is the ID of a file in the catalog
    #                       $computerId - this is the ID of a computer that the file is on
    #                       $session - this is a session object from the CBEPSession class
    # This method will use an open session to update the request with a post call to the api
    [void] UpdateLocal ([string]$fileInstanceId, [system.object]$session){
        If ($this.fileInstance){
            $urlQueryPart = "/fileInstance?q=id:" + $fileInstanceId
            $i = 0
            While ($i -lt $this.fileInstance.length){
                If ($this.fileInstance[$i].id -eq $fileInstanceId){
                    $jsonObject = ConvertTo-Json -InputObject $this.fileInstance[$i]
                    $this.fileInstance[$i] = $session.post($urlQueryPart, $jsonObject)
                }
                $i++
            }
        }
    }

    # Parameters required:  $fileCatalogId - this is the ID of a file in the catalog
    #                       $session - this is a session object from the CBEPSession class
    # This method will use an open session to update the request with a post call to the api
    [void] UpdateGlobal ([string]$fileCatalogId, [system.object]$session){
        If ($this.fileCatalog){
            $urlQueryPart = "/fileCatalog?q=id:" + $fileCatalogId
            $i = 0
            While ($i -lt $this.fileCatalog.length){
                If ($this.fileCatalog[$i].id -eq $fileCatalogId){
                    $jsonObject = ConvertTo-Json -InputObject $this.fileCatalog[$i]
                    $this.fileCatalog[$i] = $session.post($urlQueryPart, $jsonObject)
                }
                $i++
            }
        }
    }

    # Parameters required:  $fileCatalogId - this is the ID of a file in the catalog
    #                       $computerId - this is the ID of a computer that the file is on
    #                       $session - this is a session object from the CBEPSession class
    # This method will modify the variable to mark a local file as approved
    [void] GrantLocal ([string]$fileInstanceId, [system.object]$session){
        ($this.fileInstance | Where-Object {$_.id -eq $fileInstanceId}).localState = 2
        $this.UpdateLocal($fileInstanceId, $session)
    }

    # Parameters required:  $fileCatalogId - this is the ID of a file in the catalog
    #                       $computerId - this is the ID of a computer that the file is on
    #                       $session - this is a session object from the CBEPSession class
    # This method will modify the variable to mark a local file as unapproved
    [void] RevokeLocal ([string]$fileInstanceId, [system.object]$session){
        ($this.fileInstance | Where-Object {$_.id -eq $fileInstanceId}).localState = 1
        $this.UpdateLocal($fileInstanceId, $session)
    }

    # Parameters required:  $fileCatalogId - this is the ID of a file in the catalog
    #                       $computerId - this is the ID of a computer that the file is on
    #                       $session - this is a session object from the CBEPSession class
    # This method will modify the variable to mark a local file as banned
    [void] BlockLocal ([string]$fileInstanceId, [system.object]$session){
        ($this.fileInstance | Where-Object {$_.id -eq $fileInstanceId}).localState = 3
        $this.UpdateLocal($fileInstanceId, $session)
    }

    # Parameters required:  $fileCatalogId - this is the ID of a file in the catalog
    #                       $session - this is a session object from the CBEPSession class
    # This method will modify the variable to mark a global file as approved
    [void] GrantGlobal ([string]$fileCatalogId, [system.object]$session){
        ($this.fileCatalog | Where-Object {$_.id -eq $fileCatalogId}).fileState = 2
        $this.UpdateGlobal($fileCatalogId, $session)
    }

    # Parameters required:  $fileCatalogId - this is the ID of a file in the catalog
    #                       $session - this is a session object from the CBEPSession class
    # This method will modify the variable to mark a global file as unapproved
    [void] RevokeGlobal ([string]$fileCatalogId, [system.object]$session){
        ($this.fileCatalog | Where-Object {$_.id -eq $fileCatalogId}).fileState = 1
        $this.UpdateGlobal($fileCatalogId, $session)
    }

    # Parameters required:  $fileCatalogId - this is the ID of a file in the catalog
    #                       $session - this is a session object from the CBEPSession class
    # This method will modify the variable to mark a global file as banned
    [void] BlockGlobal ([string]$fileCatalogId, [system.object]$session){
        ($this.fileCatalog | Where-Object {$_.id -eq $fileCatalogId}).fileState = 3
        $this.UpdateGlobal($fileCatalogId, $session)
    }

    # Parameters required: $session - this is a session object from the CBEPSession class
    # Parameters optional: $fileCatalogId	-	Id of fileCatalog entry associated with this fileRule. Can be 0 if creating/modifying rule based on hash or file name
    #                      $name	-	Name of this rule
    #                      $description	-	Description of this rule
    #                      $fileState	-	File state for this rule. Can be one of: 1=Unapproved, 2=Approved, 3=Banned
    #                      $reportOnly	-	Set to true to create a report-only ban. Note: fileState has to be set to 1 (unapproved) before this flag can be set
    #                      $reputationApprovalsEnabled	-	True if reputation approvals are enabled for this file
    #                      $forceInstaller	-	True if this file is forced to act as installer, even if product detected it as 'not installer'
    #                      $forceNotInstaller	-	True if this file is forced to act as 'not installer', even if product detected it as installer
    #                      $policyIds	-	List of IDs of policies where this rule applies. Value should be empty if this is a global rule
    #                      $hash	-	Hash associated with this rule. This parameter is not required if fileCatalogId is supplied
    #                      $platformFlags	-	Set of platform flags where this file rule will be valid. combination of: 1 = Windows, 2 = Mac, 4 = Linux
    # This method will create a new rule for a file based on the information given
    [void] CreateRule ([string]$fileCatalogId, [string]$name, [string]$description, [string]$fileState, [string]$reportOnly, [string]$reputationApprovalsEnabled, [string]$forceInstaller, [string]$forceNotInstaller, [string]$policyIds, [string]$hash, [string]$platformFlags, [system.object]$session){
        [system.object]$fileRule = @{}
        $fileRule.fileCatalogId = $fileCatalogId
        $fileRule.name = $name
        $fileRule.description = $description
        $fileRule.fileState = $fileState
        $fileRule.reportOnly = $reportOnly
        $fileRule.reputationApprovalsEnabled = $reputationApprovalsEnabled
        $fileRule.forceInstaller = $forceInstaller
        $fileRule.forceNotInstaller = $forceNotInstaller
        $fileRule.policyIds = $policyIds
        $fileRule.hash = $hash
        $fileRule.platformFlags = $platformFlags

        $urlQueryPart = "/fileRule"
        $jsonObject = ConvertTo-Json -InputObject $fileRule
        $session.post($urlQueryPart, $jsonObject)
    }

    # Parameters required: $session - this is a session object from the CBEPSession class 
    # Parameters optional: $computerId - Id of computer from which to upload the file. If 0, system will find best computer to get the file from
    #                      $fileCatalogId - Id of fileCatalog entry for file to upload
    #                      $priority - Upload priority in range [-2, 2], where 2 is highest priority. Default priority is 0
    #                      $uploadStatus - Status of upload. Status of upload in progress can be changed to 5 (Cancelled). Any upload can be changed to 6 (Deleted)
    # This method will pull a file from a computer to the CBEP server. It also has the capability of cancelling and deleting the upload based on modifying upload status
    [system.object] Upload ([system.int32]$computerId, [system.int32]$fileCatalogId, [system.int32]$priority, [system.int32]$uploadStatus, [system.object]$session){
        [system.object]$fileUploadRequest = @{}
        $fileUploadRequest.computerId = $computerId
        $fileUploadRequest.fileCatalogId = $fileCatalogId
        $fileUploadRequest.priority = $priority
        $fileUploadRequest.uploadStatus = $uploadStatus

        $urlQueryPart = "/fileUpload"
        $jsonObject = ConvertTo-Json -InputObject $fileUploadRequest
        return $session.post($urlQueryPart, $jsonObject)
    }

    # Parameters required: $uploadId - id of a requested fileUpload
    #                      $session - this is a session object from the CBEPSession class
    # This method will download a file from the CBEP server and return it
    [System.IO.FileInfo] Download ([system.int32]$uploadId, [system.object]$session){
        $urlQueryPart = "/fileUpload/" + $uploadId + "?downloadFile=True"
        return $session.getFile($urlQueryPart)
    }
}