# ********************************************************************
# Ericsson Radio Systems AB                                     SCRIPT
# ********************************************************************
#
# (c) Ericsson Inc. 2017 - All rights reserved.
#
# The copyright to the computer program(s) herein is the property
# of Ericsson Inc. The programs may be used and/or copied only with
# the written permission from Ericsson Inc. or in accordance with the
# terms and conditions stipulated in the agreement/contract under
# which the program(s) have been supplied.
#
# ********************************************************************
# Name    : AdhocEnablerExtractUpgrade.ps1
# Purpose : #  Installation script for Enabling Adhoc Capability
#             
# Usage   : AdHocEnablerExtractUpgrade.ps1 ([string] $PlatformPassword)
#           
#---------------------------------------------------------------------------------
param ( 
    [Parameter(Mandatory=$true,HelpMessage="Enter the Network Analytics Server Platform password")]
    [alias("pp")] 
    [String]$platformPass,
    [switch]$FORCE
)


$adminShell = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if(-not $adminShell) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    break
}

if($FORCE){

. $PSScriptRoot/AdHocEnablerExtractInstall.ps1 -pp $platformPass -Force
}else{

. $PSScriptRoot/AdHocEnablerExtractInstall.ps1 -pp $platformPass

}