# ********************************************************************
# Ericsson Radio Systems AB                                     MODULE
# ********************************************************************
#
#
# (c) Ericsson Radio Systems AB 2015 - All rights reserved.
#
# The copyright to the computer program(s) herein is the property
# of Ericsson Radio Systems AB, Sweden. The programs may be used 
# and/or copied only with the written permission from Ericsson Radio 
# Systems AB or in accordance with the terms and conditions stipulated 
# in the agreement/contract under which the program(s) have been 
# supplied.
#
# ********************************************************************
# Name    : ManageGroups.psm1
# Date    : 18/08/2015
# Purpose : Module Used for Managing Groups of Network Analytics Server
#

Import-Module Logger
Import-Module NetAnServerConfig
Import-Module NetAnServerUtility

$DRIVE = (Get-ChildItem Env:SystemDrive).value
$NETANSERV_HOME = "$($DRIVE)\Ericsson\NetAnServer"
$TOMCAT = "$($NETANSERV_HOME)\Server\7.9\tomcat"

$businessAuthorLicenseList= @(
 '"Spotfire.Dxp.WebAnalyzer"',
 '"Spotfire.Dxp.Metrics"',
 '"Spotfire.Dxp.EnterprisePlayer" -f "openFile,saveDXPFile,saveToLibrary"'
 )
 $businessAnalystLicenseList=@(
 '"Spotfire.Dxp.Extensions"',
 '"Spotfire.Dxp.Professional"',
 '"Spotfire.Dxp.InformationModeler"',
 '"Spotfire.Dxp.Administrator" -f "libraryAdministration"'
 )

$ADHOC_LOG_DIR = "$($NETANSERV_HOME)\Logs\AdhocEnabler"
$global:configToolLogfile = "$ADHOC_LOG_DIR\$(get-date -Format 'yyyyMMdd_HHmmss')_configTool.log"





### Function:  Add-Groups ###
#
#    Adds Business Author and Business Analyst Ad-HOC Groups
#
# Arguments:
#       [string] $groupstemplate 
#       [string] $platformpassword
# Return Values:
#       [array]
# Throws: None
#  
Function Add-Groups() {
    param(
        [string] $groupstemplate,
        [string] $platformpassword
    )

    $logger.logInfo("Add Groups called")

    if (-not (Test-FileExists $groupstemplate)) {

        return @($False, "The required file was not found at $($groupstemplate)")
    } else {

        #required parameters for Get-Arguments and Use-ConfigTool
        $params = @{}
        $params.netanserverGroups = $groupstemplate   #absolute path of groups file which needs to be imported. 
        $params.configToolPassword = $platformpassword   #Network Analytics Server Platform Password
        $params.tomcatDir = "$($TOMCAT)\bin\"   #Tomcat bin directory

        #NetAnServerConfig.Get-Arguments
        $configToolParams = Get-Arguments "import-groups" $params

        if(-not $configToolParams) {

            $logger.logError($MyInvocation, "NetAnServerUtility.Get-Arguments returned $configToolParams", $False)
            return @($False, "Error in importing Groups")    
        }

        #NetAnServerConfig.Use-ConfigTool
        $isImported = Use-ConfigTool $configToolParams $params $global:configToolLogfile
        if(-not $isImported) {
            $logger.logError($MyInvocation, "NetAnServerUtility.Use-ConfigTool returned $configToolParams", $False)
            return @($False, "Error in importing Groups")

        }
        else {
            return @($True, "Import Successful")
            
        }
    }
	 
}


### Function:  Set-Licence ###
#
#    Sets licence for  Business Author and Business Analyst Ad-HOC Groups
#
# Arguments:
#              [string] $platformpassword
# Return Values:
#       [array]
# Throws: None
#  
Function Set-Licence(){
    param(
        [string] $platformpassword
	)

    $groupName= 'Business Author'
	$licenseConfigStages = @('set-license')
	$params = @{}
	$params.configToolPassword = $platformpassword   #Network Analytics Server Platform Password
	$params.tomcatDir = "$($TOMCAT)\bin\"   #Tomcat bin directory
	$isUpdated = Update-License $params $licenseConfigStages $businessAuthorLicenseList $groupName
		if ($isUpdated) {
            $logger.logInfo(" Business Author licence successfully set")
            
        } else {
            $logger.logError($MyInvocation, "Failed to set Business Author licence", $False)
            return @($False, "Failed to set Business Author licence")
        }
	$groupName= 'Business Analyst'
    $isUpdated = Update-License $params $licenseConfigStages $businessAnalystLicenseList $groupName
	
		if ($isUpdated) {
            $logger.logInfo(" Business Analyst licence successfully set")
            
        } else {
            $logger.logError($MyInvocation, "Failed to set Business Analyst licence", $False)
            return @($False, "Failed to set Business Analyst licence")

   }
   return @($TRUE, "Set Business Author and Business Analyst licence Successful")
   }