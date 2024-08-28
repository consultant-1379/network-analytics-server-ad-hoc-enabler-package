# ********************************************************************
# Ericsson Radio Systems AB                                     MODULE
# ********************************************************************
#
#
# (c) Ericsson Radio Systems AB 2016 - All rights reserved.
#
# The copyright to the computer program(s) herein is the property
# of Ericsson Radio Systems AB, Sweden. The programs may be used 
# and/or copied only with the written permission from Ericsson Radio 
# Systems AB or in accordance with the terms and conditions stipulated 
# in the agreement/contract under which the program(s) have been 
# supplied.
#
# ********************************************************************
# Name    : ProductVersion.psm1
# Date    : 19/01/2016
# Purpose : Utility functions for the Adhoc-Enabler
#


### Function:  Get-AdhocEnablerDataFromFile ###
#
# Arguments:
#       [string] $adhocEnablerXmlFile
#
# Return Values:
#       [array]
# Throws: None

function Get-AdhocEnablerDataFromFile() {
    param(
        [string]$adhocEnablerXmlFile
    )

    $xmlHashTable = @{}


    if(-not (Test-Path $adhocEnablerXmlFile)) {
        return @($False, "feature-release.xml not found at path: $($adhocEnablerXmlFile)")
    }

    $build = $adhocEnablerXmlFile.split(".")[-2]                                                   
    $xmlHashTable['BUILD'] = $build

    $xmlHashTable['RSTATE'] = $xmlHashTable.BUILD -replace "\d+$"
    [xml]$xmlContent = Get-Content $adhocEnablerXmlFile 
    $xmlContent.SelectNodes("//text()") | Foreach { $xmlHashTable[$_.ParentNode.ToString()] = $_.Value }
    return @($True, $xmlHashTable)
}