# ********************************************************************
# Ericsson Radio Systems AB                                     SCRIPT
# ********************************************************************
#
#
# (c) Ericsson Inc. 2016 - All rights reserved.
#
# The copyright to the computer program(s) herein is the property
# of Ericsson Inc. The programs may be used and/or copied only with
# the written permission from Ericsson Inc. or in accordance with the
# terms and conditions stipulated in the agreement/contract under
# which the program(s) have been supplied.
#
# ********************************************************************
# Name    : AdhocEnabler.ps1
# Date    : 18/08/2015
# Purpose : # Installation script for Enabling Adhoc Capability and Install TSSS TERR Server
#    
#
# Usage   : AdhocEnabler ([string] $PlatformPassword)
#           

#----------------------------------------------------------------------------------
#  Following parameters must not be modified
#----------------------------------------------------------------------------------
param ( 
        [Parameter(Mandatory=$true,HelpMessage="Enter the Network Analytics Server Platform password")]
        [alias("pp")] 
        [String]$platformPassword,
        [alias("f")] 
        [Boolean]$FORCE
    )

$install_date = get-date -format "yyyyMMdd_HHmmss"
$DRIVE = (Get-ChildItem Env:SystemDrive).value
$installParams = @{}
$installParams.Add('installDir', ($DRIVE) + "\Ericsson\NetAnServer")
$installParams.Add('installResourceDir', ($DRIVE) + "\Ericsson\tmp\Resources")          
$installParams.Add('logDir', $installParams.installDir + "\Logs\AdhocEnabler") 
$installParams.Add('setLogName', 'AdhocEnabler.log')          
$installParams.Add('PSModuleDir', $installParams.installDir + "\Modules")    
$installParams.Add('moduleDir', "$PSScriptRoot\modules")
$installParams.Add('resourceDir', "$PSScriptRoot\resources\groups")
$installParams.Add('folderResourceDir', "$PSScriptRoot\resources\")
$installParams.Add('groupTemplate', $installParams.resourceDir +"\adhocgroups.txt")
$installParams.Add('featureVersion', $installParams.installDir +"\Features\Ad-HocEnabler")
$installParams.Add('customLib', $installParams.featureVersion +"\resources\library\custom.part0.zip")

$exePath = ($DRIVE) + "\Ericsson\tmp\adhoc\extracted\Software\TSSS_7.5.0_win_x86_64.exe"
$tsssHFZip = ($DRIVE) + "\Ericsson\tmp\adhoc\TSSS_HotFixes-7.5.0.zip"
$tsssAdHocPath = ($DRIVE) + "\Ericsson\tmp\adhoc"
$tsssHFPath = $tsssAdHocPath+"\TIB_sf_statsvcs_7.5.0_HF-003_win_x86_64\TerrEngine.zip"
$tsssHFWarPath = $tsssAdHocPath+"\TIB_sf_statsvcs_7.5.0_HF-003_win_x86_64\SplusServer.war.7.5.0-HF-003"
$configFilePath = ($DRIVE) + "\Ericsson\tmp\adhoc\extracted\resources\config\StatisticalServices.txt"
$argList = @('-f',$configFilePath)
$tsssServiceName = "TSSS75StatisticalServices"
$terrEngineZip = ($DRIVE) + "\Ericsson\NetAnServer\StatisticalServices\data\binaries\TerrEngine.zip"
$backupterrEngineZip = ($DRIVE) + "\Ericsson\NetAnServer\StatisticalServices\data\binaries\TerrEngine.bak"
$terrEngine42 = ($DRIVE) + "\Ericsson\NetAnServer\StatisticalServices\data\binaries"
$terrEngineFolder = ($DRIVE) + "\Ericsson\NetAnServer\StatisticalServices\engines\Terr"
$webappservicebackup = ($DRIVE) + "\Ericsson\NetAnServer\StatisticalServices\tomcat\webapps\StatisticalServices.war.bak"
$webappservice = ($DRIVE) + "\Ericsson\NetAnServer\StatisticalServices\tomcat\webapps\StatisticalServices.war"
$webappservicedir = ($DRIVE) + "\Ericsson\NetAnServer\StatisticalServices\tomcat\webapps\StatisticalServices"





#----------------------------------------------------------------------------------
#  Set PSModulePath and Copy modules
#----------------------------------------------------------------------------------

if(-not $env:PSModulePath.Contains($installParams.PSModuleDir)){
    $PSPath = $env:PSModulePath + ";"+$installParams.PSModuleDir
    [Environment]::SetEnvironmentVariable("PSModulePath", $PSPath, "Machine")
    $env:PSModulePath = $PSPath
}

$loc = Get-Location

Import-Module Logger
Import-Module NetAnServerUtility -DisableNameChecking
Import-Module ManageUsersUtility -DisableNameChecking
Import-Module FeatureInstaller -Force -DisableNameChecking
Import-Module ZipUnZip -DisableNameChecking



try {
    $checkPassword=Invoke-ListUsers -pp $platformPassword
} catch {
    Write-Host "$($_.Exception.Message)" -ForegroundColor Red
    return 
}

try{
    RoboCopy $installParams.moduleDir $installParams.PSModuleDir /E | Out-Null
}catch {
    Write-Host "ERROR Copying modules to $($installParams.installDir)." -Foreground Red
    return 
}

Import-Module ManageGroups -DisableNameChecking
Import-Module ManageAdhocUsers -Force -DisableNameChecking
Import-Module PlatformVersion -DisableNameChecking

if ( -not (Test-Path $installParams.logDir)) {
    New-Item $installParams.logDir -Type Directory | Out-Null
}
if ( -not (Test-Path $installParams.featureVersion)) {
    New-Item $installParams.featureVersion -Type Directory -ErrorAction SilentlyContinue| Out-Null
}

$global:logger = Get-Logger("Install_AdhocEnabler")
$logger.setLogDirectory($installParams.logDir)
$logger.setLogName($installParams.setLogName)

    try {
        Copy-Item -Path "$PSScriptRoot\..\feature*xml" -Destination $installParams.featureVersion -Recurse -Force  -ErrorAction Stop
        } catch {
        $logger.logInfo("ERROR copying release information  to $($installParams.featureVersion)")
        }


    $adhocData =  Get-AdhocEnablerDataFromFile (Get-Item "$PSScriptRoot\..\feature-release*xml").FullName
    if($adhocData[0]){
        $logger.logInfo("Data returned from feature-release.xml")
        $allData = Get-PlatformVersionsFromDB $platformPassword 
        
        $newProductID = $adhocData[1]['PRODUCT-ID']
        $newBuild = $adhocData[1]['BUILD']
        $logger.logInfo("------------------------------------------------------", $True)
        $logger.logInfo("|     Product to be installed: $newProductID  $newBuild", $True)
		$logger.logInfo("|     Testing for installed platform versions...", $True)
		$platformDetails = Get-PlatformVersions | Where-Object -FilterScript { $_.'PRODUCT-ID'.trim() -eq 'CNA4032940' }
		if(-not $platformDetails) {
		$logger.logError($MyInvocation, $platformDetails)
		$logger.logError($MyInvocation, "An error has occurred in getting Platform Version. Please refer to log for details. Exiting", $True)
		Exit
		}
		if($platformDetails.RSTATE -ge 'R5A')
		{
		  $platformValid=$True
		}else{
		  $platformValid=$False
		}
		

        $canInstall =  Test-ShouldAdhocEnablerBeInstalled $newProductID $newBuild $PlatformPassword 
        
        if($FORCE -and $platformValid){
            $canInstall = @($True, $canInstall[1])
        }

        if($canInstall[0] -and $canInstall[1].BUILD){
            $logger.logInfo("|     Product " + $($canInstall[1].'PRODUCT-ID').trim() + " build version " + $($canInstall[1].BUILD).trim() + " currently installed.", $True)
        }

        if(!($canInstall[0])){ 
            $logger.logInfo("|     Product " + $($canInstall[1].'PRODUCT-ID').trim() + " build version " + $($canInstall[1].BUILD).trim() + " is already installed.", $True)         
            $logger.logInfo("|     $newBuild is the same or older than the installed version. The script will now exit.", $True)
            $logger.logInfo("------------------------------------------------------", $True) 
            Set-Location $loc
            Exit
        }
		if(!$platformValid){ 
                    
            $logger.logInfo("|     As this package requires version R5A or greater of CNA4032940 the script will now exit.", $True)
            $logger.logInfo("------------------------------------------------------", $True) 
            Set-Location $loc
            Exit
        }


    }else{
        $logger.logError($MyInvocation, "Data not returned from feature-release.xml: $adhocData[1]", $True)
        Exit
    }

    try {
        Copy-Item -Path $installParams.folderResourceDir -Destination $installParams.featureVersion -Recurse -Force  -ErrorAction Stop
        } catch {
        $logger.logInfo("ERROR copying Resource to $($installParams.featureVersion)")
        }
         $username=Get-AdminUserName $platformPassword
         $childcreated=Invoke-ImportLibraryElement -element $installParams.customLib -username $username -password $platformPassword -conflict "KEEP_NEW" -destination "/"    

Function Main() {
         param(
     [array]$canInstall
     )
    
    if($FORCE){
        $logger.logWarning("|     AdhocEnabler Package installation executed with -FORCE", $True)
    }

    $logger.logInfo("|     Creating Business Author and Business Analyst groups", $True)
    $isCreated = Add-Groups $installParams.groupTemplate  $platformPassword
    if ($isCreated[0]) {
        $logger.logInfo("|     Setting up licences for Business Author and Business Analyst groups", $True)
        $isSet=Set-Licence $platformPassword
        if ($isSet[0]) {
        $logger.logInfo("|     Business Author and Business Analyst licences set successfully", $True)
        } else {
        MyExit($isSet[1])
        }
        $logger.logInfo("|     Business Author and Business Analyst Groups created successfully", $True)
        Install-TSSS
        Hot-Fixes
        $logger.logInfo("|     Network Analytics Server Ad-Hoc Enabler Package successfully installed", $True)
        $logger.logInfo("------------------------------------------------------", $True)
        
        #Update Platform feature version in DB
        if($canInstall[0]){ 

            if($canInstall[1] ){
                 $updateplatform = Update-PlatformStatus $canInstall[1] $platformPassword 
            }
            $addData = Add-PlatformVersionToDB $adhocData[1] $platformPassword 
            
        }

    } else {
           AdHocExit($isCreated[1])
    }  
}

#----------------------------------------------------------------------------------
#  Exit Function to Log error and terminate.
#----------------------------------------------------------------------------------
Function AdHocExit($errorString) {
    $logger.logError($MyInvocation, "Installation of Network Analytics Server Adhoc Enabler failed to create Business Author and Business Analyst Groups due to $errorString", $True)
    Exit
}

### Function: Install-TSSS ###
#
#   Install TSSS TERR Server 
#
# Arguments:
#       None
# Return Values:
#       None
#

Function Install-TSSS {
    
    if (!(Test-Path $exePath)) {
         $logger.logError($MyInvocation,"Installing Network Analytics Statistical Services. $exePath not found.", $True)
         Exit
    }
    
    $status = Test-ServiceExists $tsssServiceName
    
    if($status) {
        $logger.logInfo( "|     Network Analytics Statistical Services already Installed", $True)    
    } else {
        
        try {
            $logger.logInfo("|     Starting Network Analytics Statistical Services Installation", $True)
            $process = Start-Process -FilePath $exePath -ArgumentList $argList -Wait -ErrorAction Stop
            $isRunning = Test-ServiceRunning "$($tsssServiceName)"
			
			while(-Not $isRunning){
				Start-Sleep -s 10
				$isRunning = Test-ServiceRunning "$($tsssServiceName)"
				$logger.logInfo("|     Waiting for service to start", $False)
				}
			$logger.logInfo("|     Network Analytics Statistical Services successfully installed", $True)
			
        } catch {
           $logger.logError($MyInvocation, "Error installing Network Analytics Statistical Services", $True)
           Exit 
        } 
    }
}
### Function: Hot-Fixes ###
#
#   Install TSSS Hot-Fix 
#
# Arguments:
#       None
# Return Values:
#       None
#
Function Hot-Fixes{
    

       
        try {
            $logger.logInfo("|     Installing Network Analytics Statistical Services HotFixes", $True)
            Unpack-Zip $tsssHFZip -Destination $tsssAdHocPath  | Out-Null
			$isRunning = Test-ServiceRunning "$($tsssServiceName)"
			if($isRunning){
            Stop-Service -Name "$($tsssServiceName)"  -ErrorAction stop -WarningAction SilentlyContinue
			$logger.logInfo("|    Stop Service called", $False)
			}
			while($isRunning){
				Start-Sleep -s 10
				$isRunning = Test-ServiceRunning "$($tsssServiceName)"
				$logger.logInfo("|     Service is still running", $False)
				}
			Move-Item $webappservice  -Destination $webappservicebackup -Force
            Remove-Item -Recurse -Force $webappservicedir	
			Copy-Item $tsssHFWarPath -Destination $webappservice -Force
            Move-Item $terrEngineZip -Destination $backupterrEngineZip -Force
            Copy-Item $tsssHFPath -Destination $terrEngine42 -Force
            Remove-Item -Recurse -Force $terrEngineFolder
            Start-Service -Name "$($tsssServiceName)" -ErrorAction stop
            $logger.logInfo("|     Network Analytics Statistical Services HotFixes installed", $True)
        }catch {
            $errorMessage = $_.Exception.Message
            $logger.logError($MyInvocation,"HotFixes installation failed :  $errorMessage ", $True)
        }
    
}
Function Unpack-Zip($file, $destination) {

    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    foreach($item in $zip.items()) {
        $shell.Namespace($destination).copyhere($item,0x14)
    }
}


Main $canInstall