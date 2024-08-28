# ********************************************************************
# Ericsson Radio Systems AB                                     Module
# ********************************************************************
#
#
# (c) Ericsson Inc. 2015 - All rights reserved.
#
# The copyright to the computer program(s) herein is the property
# of Ericsson Inc. The programs may be used and/or copied only with
# the written permission from Ericsson Inc. or in accordance with the
# terms and conditions stipulated in the agreement/contract under
# which the program(s) have been supplied.
#
# ********************************************************************
# Name    : ManageAdhocUsers.psm1
# Date    : 20/08/2015
# Purpose : Management of Network Analytics Server Adhoc Enabled users



Import-Module ManageUsersUtility -Force -DisableNameChecking
Import-Module NetAnServerUtility -DisableNameChecking
Import-Module NetAnServerConfig -DisableNameChecking


$DRIVE = (Get-ChildItem Env:SystemDrive).value
$NETANSERV_HOME = "$($DRIVE)\Ericsson\NetAnServer"
$TOMCAT = "$($NETANSERV_HOME)\Server\7.9\tomcat"
$DEFAULT_FOLDER_DIR = "$($NETANSERV_HOME)\Features\Ad-HocEnabler\resources\folder"
$TEMP_DIR_PATH = "$($NETANSERV_HOME)\Features\Ad-HocEnabler\resources"

$ADHOC_LOG_DIR = "$($NETANSERV_HOME)\Logs\AdhocEnabler"
$global:configToolLogfile = "$ADHOC_LOG_DIR\$(get-date -Format 'yyyyMMdd_HHmmss')_configTool.log"

### Function:  Add-BusinessAuthor ###
#
#   Creates a new user and adds them to the Business Author group
#
# Arguments:
#       [string] $username - the user to create
#       [string] $password - the new users password 
#       [string] $platformPassword - the Network Analytics Server platform password
#
# Return Values:
#       [none]
# Throws:
#       None
#
function Add-BusinessAuthor() {    
    <#
        .SYNOPSIS
        Creates a Business Autor user.
        .DESCRIPTION
        Creates a new user and adds them to the 'Business Author' user group.
        Note: if the user already exists, Promote-UserToGroup cmdlet should be used.
        Please see Get-Help Promote-UserToGroup 
        .EXAMPLE
        Add-BusinessAuthor -username <username> -password <userpassword> -platformPassword <platformPassword>      
        .EXAMPLE
        Add-BusinessAuthor -u <username> -p <userpassword> -pp <platformPassword>   
        .EXAMPLE
        Add-BusinessAuthor  <username>  <userpassword>  <platformPassword>
        .PARAMETER userName
        The username for the new Business Author user
        .PARAMETER password
        The password for the new Business Author user
        .PARAMETER platformPassword
        The Network Analytics Server Platform password
    #>
    param(
        [parameter(mandatory=$true, HelpMessage="Enter the Business Author username")]
        [alias("u")]
        [string] $userName,
        [parameter(mandatory=$true, HelpMessage="Enter the Business Author password")]
        [alias("p")]
        [string] $password,
        [parameter(mandatory=$true, HelpMessage="Enter the Network Analytics Server Platform password")]
        [alias("pp")]
        [string] $platformPassword
     )

    Import-Module ManageUsersUtility -Force -DisableNameChecking
    $GROUP_NAME = "Business Author"

    try {
        $exists = Test-RequiredGroupExist -groupName $GROUP_NAME -platformPassword $platformPassword
    } catch {
        return "$($_.Exception.Message)"
    }

    if (-not $exists) {
        Write-Host "the required group '$($GROUP_NAME)' does not exist in Network Analytics Server."
        return
    }

    $isAdded = Add-User -username $userName -password $password -groupname $GROUP_NAME -platformPassword $platformPassword

    $response = ""
    if ($isAdded[0]) {
        $response += "The Business Author $($username) was successfully created "
    } else {
        $response += "Error creating Business Author $($username) `n$($isAdded[1])"
    }
    if ($isAdded[0]) {
    $isFolderCreated=Add-Folder $username $platformPassword
    if ($isFolderCreated[0]) {
        $response += "`nFolder for Business Author $($username) created in Custom Library"
        } else {
            $response += "`n$($isFolderCreated[1])"

            }
    }
     
    
    Write-Host $response
}



### Function:  Add-BusinessAnalyst ###
#
#   Creates a new user and adds them to the Business Analyst group
#
# Arguments:
#       [string] $username - the user to create
#       [string] $password - the new users password 
#       [string] $platformPassword - the Network Analytics Server platform password
#
# Return Values:
#       [none]
# Throws:
#       None
#
function Add-BusinessAnalyst() {
    <#
        .SYNOPSIS
        Creates a Business Analyst user.
        .DESCRIPTION
        Creates a new user and adds them to the 'Business Analyst' user group.
        Note: if the user already exists, Promote-UserToGroup cmdlet should be used.
        Please see: Get-Help Promote-UserToGroup 
        .EXAMPLE
        Add-BusinessAnalyst -username <username> -password <userpassword> -platformPassword <platformPassword>      
        .EXAMPLE
        Add-BusinessAnalyst -u <username> -p <userpassword> -pp <platformPassword>   
        .EXAMPLE
        Add-BusinessAnalyst  <username>  <userpassword>  <platformPassword>
        .PARAMETER userName
        The username for the new Business Analyst user
        .PARAMETER password
        The password for the new Business Analyst user
        .PARAMETER platformPassword
        The Network Analytics Server Platform password
    #>
    param(
        [parameter(mandatory=$true, HelpMessage="Enter the Business Analyst username")]
        [alias("u")]
        [string] $userName,
        [parameter(mandatory=$true, HelpMessage="Enter the Business Analyst password")]
        [alias("p")]
        [string] $password,
        [parameter(mandatory=$true, HelpMessage="Enter the Network Analytics Server Platform password")]
        [alias("pp")]
        [string] $platformPassword
     )
    Import-Module ManageUsersUtility -Force -DisableNameChecking
    $GROUP_NAME = "Business Analyst"


    try {
        $exists = Test-RequiredGroupExist -groupName $GROUP_NAME -platformPassword $platformPassword
    } catch {
        return "$($_.Exception.Message)"
    }

    if (-not $exists) {
        Write-Host "the required group '$($GROUP_NAME)' does not exist in Network Analytics Server."
        return
    }

    $isAdded = Add-User -username $userName -password $password -groupname $GROUP_NAME -platformPassword $platformPassword

    $response = ""
    if ($isAdded[0]) {
        $response += "The Business Analyst $($username) was successfully created"
    } else {
        $response += "Error creating Business Analyst $($username) `n$($isAdded[1])"
    }
    if ($isAdded[0]) {
    $isFolderCreated=Add-Folder $username $platformPassword
    if ($isFolderCreated[0]) {
        $response += "`nFolder for Business Analyst $($username) created in Custom Library"
        } else {
                $response += "`n$($isFolderCreated[1])"
            }
    }
    
    Write-Host $response
}



### Function: Invoke-PromoteUserToGroup ###
#
#    Promotes a currently existing user to the specified group
#
# Arguments:
#       [switch] $BusinessAuthor | $BusinessAnalyst
#       [string] $username - the user to promote
#       [string] $platformPassword - the Network Analytics Server platform password
#
# Return Values:
#       [none]
# Throws:
#       None
#
Function Invoke-PromoteUserToGroup() {
    <#
        .SYNOPSIS
        Promotes a user to another group
        .DESCRIPTION
        Promotes an existing user to either the 'Business Analyst' or 'Business Author' group.
        Once promoted a user will be present in both the original group and the newly added
        group. 

        The following promotion paths are supported:

        Consumer -> Business Author 
        Consumer -> Business Analyst
        Business Author -> Business Analyst

        Note: 
        Business Analyst -> Business Author is not supported. The Business Analyst group contains all
        privileges provided by the Business Author group.

        .EXAMPLE
        Promote a user to the 'Business Author' Group
        Invoke-PromoteUserToGroup -BusinessAuthor -username <username> -platformPassword <platformPassword>
        .EXAMPLE
        Promote a user to the 'Business Author' Group
        Invoke-PromoteUserToGroup -BusinessAuthor -u <username> -pp <platformPassword>
        .EXAMPLE
        Promote a user to the 'Business Analyst' Group
        Invoke-PromoteUserToGroup -BusinessAnalyst -username <username> -platformPassword <platformPassword>
        .EXAMPLE
        Promote a user to the 'Business Analyst' Group
        Invoke-PromoteUserToGroup -BusinessAnalyst -u <username> -pp <platformPassword>         
        .PARAMETER userName
        The username of the user to promote
        .PARAMETER platformPassword
        The Network Analytics Server Platform password
    #>
    param(
        [parameter(mandatory=$false, HelpMessage="The 'Business Author' group ", Position=1)]
        [switch] $BusinessAuthor, 
        [parameter(mandatory=$false, HelpMessage="The 'Business Analyst' group ", Position=1)]
        [switch] $BusinessAnalyst,
        [parameter(mandatory=$true, HelpMessage="Enter the username who is being promoted ", Position=2)]
        [alias("u")]
        [string] $username,
        [parameter(mandatory=$true, HelpMessage="Enter the Network Analytics Server Platform password", Position=3)]
        [alias("pp")]
        [string] $platformPassword
    )
    Import-Module ManageUsersUtility -Force -DisableNameChecking
    $group = ""

    if ($BusinessAuthor) {
        $group = "Business Author"
    }

    if ($BusinessAnalyst) {
        $group = "Business Analyst"
    }

    if ((-not $BusinessAnalyst) -and (-not $BusinessAuthor)) {
        Write-Host "You must supply the required switch: -BusinessAnalyst or -BusinessAuthor`nPlease see Get-Help Invoke-PromoteUserToGroup -Examples "
        return
    }

    if (($BusinessAnalyst) -and ($BusinessAuthor)) {
        Write-Host "You must supply a single required switch: -BusinessAnalyst or -BusinessAuthor`nPlease see Get-Help Invoke-PromoteUserToGroup -Examples "
        return
    }

    $exists = Test-RequiredGroupExist -groupName $group -platformPassword $platformPassword

    if (-not $exists) {
        Write-Host "The required group '$($GROUP_NAME)' does not exist in Network Analytics Server."
        return
    }

    $user = Invoke-ListUsers -pp $platformPassword | Where-Object { $_.USERNAME -eq $username }

    if ( -not $user) {
        Write-Host "User $username does not exist, please create this user before promoting attempting to promote them.`n"
        return
    }

    if ($user.GROUP.Contains($group)) {
        Write-Host "User $username is already a member of the group $group"
        return
    }

    ## If is not a promotion ##
    if (($user.GROUP -eq "Business Analyst") -and $BusinessAuthor) {
        Write-Host "User '$($username)' is already a member of the 'Business Analyst' group. The 'Business Analyst' group contains all privileges provided by the 'Business Author' group."
        return
    }
    $flag=0
    if (($user.GROUP.Contains("Consumer")) -and (-NOT(($user.GROUP.Contains("Business Author"))))) {
        
        $flag=1;
        
    }

    $isAdded = Add-UserToGroup -username $username -platformPassword $platformPassword -groupName $group

    if ($isAdded[0]) {
        Write-Host "User $username added to group $group"
    } else {
        return "$($isAdded[1])"
    }

    if(($flag -eq 1) -and ($isAdded[0])) {

        $isFolderCreated=Add-Folder $username $platformPassword
        if ($isFolderCreated[0]) {
            Write-Host "Folder for  $($username) created in Custom Library"
            } else {
                return "$($isFolderCreated[1])"
            }

    }

}

### Function:   Build-LibraryPackage ###
#
#   Creates a Network Analytics Server Folder element ready for import by config utility.
#   The library once imported will be named as the $foldername parameter
#
# Arguments:
#      [string] $foldername - The name of the new folder element
#      
# Return Values:
#       [list] 
#       [0] [boolean] successful 
#       [1] [string] package name - the zipped file name e.g. file.part0.zip
#       [2] [string] absolute path to package
#
# Throws: None
#
Function Invoke-LibraryPackageCreation() {
    param (
        [string] $foldername
    )

    $metaDataFile = Get-FolderMetaDataFile
    $buildDir = Get-Directory -dirname "build"
    $stageDir = Get-Directory -dirname "stage"

    if( -not $buildDir[0] -or -not $stageDir[0]) {
        return @($False, "Error creating Directories:`n$($buildDir[1])`n$($stageDir[1])")
    }

    if( -not $metaDataFile[0]) {
        return @($False, "$($metaDataFile[1])")
    }

    $tempBuildDir = $buildDir[1]
    $tempStageDir = $stageDir[1]

    [xml]$metaXml = gc $metaDataFile[1]
    $libraryElementXMLSchema = $metaXml.'library-item'
    $folderXmlSchema = $metaXml.'library-item'.children.'library-item'
 
    $libraryElementXMLSchema.created = "2016-10-28T00:00:00.000+00:00"
    $libraryElementXMLSchema.modified = "2016-10-28T00:00:00.000+00:00"

    $libraryAcl= $metaXml.'library-item'.children.'library-item'.acl.permission.principal

    foreach ($acl in $libraryAcl) {
        if($acl.type -eq "user") {
            $acl.name ="$($foldername)@SPOTFIRE"
        }
        if($acl.type -eq "group") {
            $acl.name ="Consumer@SPOTFIRE"
        }

    }

    $folderXmlSchema.title = "$($foldername)"
    $folderXmlSchema.'created-by' = "Installer"
    $folderXmlSchema.'modified-by' = "Installer"
    $folderXmlSchema.created = "2016-10-28T00:00:00.000Z"  
    $folderXmlSchema.modified = "2016-10-28T00:00:00.000Z"
    $folderXmlSchema.accessed = "2016-10-28T00:00:00.000Z"

    $outFile = "$($tempBuildDir)\meta-data.xml"

    try {
        $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
        $sw = New-Object System.IO.StreamWriter($outFile, $false, $utf8WithoutBom)
        $metaXMl.Save($sw)
    } catch {
        return @($False, "Error Saving meta-data.xml file")        
    } finally {
        $sw.Close()
    }

    echo $null >> "$($tempBuildDir)\lastfileindicator"
    echo $null >> "$($tempBuildDir)\expectlastfileindicator"

    #zip all files
    $foldername = $foldername -replace " ",""
    $zipFileName = "$($folderName).part0.zip"
    $absolutePath = "$($tempStageDir)\$($zipFileName)"

    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($tempBuildDir, $absolutePath)

    return @($True, $zipFileName, $absolutePath)
}

### Function:   Get-FolderMetaDataFile ###
#
#   Returns a template meta-data.xml of a library folder element
#
# Arguments:
#      [none]
#      
# Return Values:
#       [list] [0] boolean [1] [string] 
# Throws: None
#
Function Get-FolderMetaDataFile() {
    
    $metaDataFile = "$($DEFAULT_FOLDER_DIR)\meta-data.xml"
    
    if (Test-FileExists $metaDataFile) {
        return @($True, $metaDataFile)
    } else {
        return @($False, "The required meta-data.xml was not found at $($metaDataFile)")
    }
}

### Function:   Get-Directory ###
#
#   Creates a new instance of the named directory. Deletes recursively the directory if it 
#   already exists. The named directory will be created in the following path:
#       C:\Ericsson\NetAnServer\FeatureInstaller\resources
#
# Arguments:
#      [string] $dirname - The name of the directory to create
#      
# Return Values:
#       [list] [0] boolean [1] [string] 
# Throws: None
#
Function Get-Directory() {
    param(
        [string] $dirname
    )

    $dir = "$($TEMP_DIR_PATH)\$($dirname)"

    if(Test-Path $dir){
        Remove-Item $dir -Force -Recurse
    }
    
    try {
        New-Item $dir -type directory -ErrorAction Stop | Out-Null
        return @($True, $dir)
    } catch {
        return @($False, "Error creating $dir")
    }
}

### Function:   Invoke-ImportLibraryElement ###
#
#   Prompts the user for a Network Analytics Server Administrator Username
#   and the Network Analytics Server Platform Password.
#
# Arguments:
#      [string] $element - The element to import (e.g. information package, Analysis Package)
#      [string] $username - The Network Analytics Server Admin username
#      [string] $password - The Network Analytics Server Platform password
#      [string] $destination (optional) - The location to import the element to
#
# Return Values:
#       [boolean]
# Throws: None
#
Function Invoke-ImportLibraryElement() {
    param(
        [Parameter(Mandatory=$true)]
        [string] $element,
        [Parameter(Mandatory=$true)]
        [string] $username,
        [Parameter(Mandatory=$true)]
        [string] $password,
        [string] $conflict,
        [string] $destination = "/Custom Library"
    )
    
    #required parameters for Get-Arguments and Use-ConfigTool
    $params = @{}
    $params.libraryLocation = $element   #absolute path of zip to install
    $params.administrator = $username    #Network Analytics Server Administrator
    $params.configToolPassword = $password   #Network Analytics Server Platform Password
    $params.tomcatDir = "$($TOMCAT)\bin\"   #Tomcat bin directory

    #NetAnServerConfig.Get-Arguments
     $configToolParams = "import-library-content -t $($params.configToolPassword) -p $($params.libraryLocation) -m $conflict -u $($params.administrator)"


    if(-not $configToolParams) {
        return @($False, "Error importing Library Element $element`n 
            NetAnServerUtility.Get-Arguments returned $configToolParams")    
    }

    if ($destination) {
        $configToolParams = "$($configToolParams) -l `"$($destination)`""  
    }

    #NetAnServerConfig.Use-ConfigTool
    $isImported = Use-ConfigTool $configToolParams $params $configToolLogfile
    return $isImported
}

### Function:   Get-AdminUserName ###
#
#  Used to get Admin username 
#
# Arguments:
#      [string] $password - Platform Password
#      
# Return Values:
#       Username for admin  
# Throws: None
#
Function Get-AdminUserName() {
    param(
        [Parameter(Mandatory=$true)]
        [string] $password
        )
    $adminName=Get-Users $password -all | % { if($_.Group -eq "Administrator") {return $_} } |Select-Object -first 1
    return $adminName.USERNAME
}

### Function:   Add-Folder ###
#
#   Prompts the user for a Network Analytics Server Administrator Username
#   and the Network Analytics Server Platform Password.
#
# Arguments:
#      [string] $foldername - Ad-hoc Username for which folder needs to be created in Custom Library 
#      [string] $password - The Network Analytics Server Platform password
#
# Return Values:
#       [boolean]
# Throws: None
#
Function Add-Folder() {
    param(
        [string] $folderName,
        [string] $password
        )

    $username=Get-AdminUserName $password
    $folderPath=Invoke-LibraryPackageCreation $folderName
    if($folderPath[0]) {
        $childcreated=Invoke-ImportLibraryElement -element $folderPath[2] -username $username -password $password -conflict "KEEP_BOTH"
        if($childcreated[0]) {
            return @($True,"Successfully created folder")
        }
    } else {
        return @($False,"Failed to Create Folder Package for $folderName with error $($folderPath[1])")
        }


}