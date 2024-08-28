# ********************************************************************
# Ericsson Radio Systems AB                                     MODULE
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
# Name    : FeatureUtility.psm1
# Date    : 17/08/2015
# Purpose : User Managemnt 
#
# Usage   : See methods below
#           
#

Import-Module Logger



$logger = Get-Logger($LoggerNames.Install)

### Function:  Get-CommandArguments ###
#
#   Function returns the required [string] arguments for 
#   the config.bat utility where the key is the command type.
#   e.g. create-user. Returns null if key is not found.
#
# Arguments:
#       [string] $key,
#       [hashtable] $map
#
# Return Values:
#       [boolean]
# Throws: None
#
Function Get-CommandArguments() {
      param(
        [Parameter(Mandatory=$true)] [string] $key, 
        [Parameter(Mandatory=$true)] [hashtable] $map

    )

    $configArgs = Switch ($key) {

        create-user {
            $logger.logInfo("Using Arguments: create-user")
            return "create-user -t $($map.platformPassword) -u $($map.username) -p $($map.userPassword)"
        }
        add-member{
            $logger.logInfo("Using Arguments: ")
            return "add-member -t $($map.platformPassword) -g $($map.groupname) -u $($map.username)" 
         }
        list-users{
            $logger.logInfo("Using Arguments: ")
            return "list-users -t $($map.platformPassword)" 
         }
         delete-user{
            $logger.logInfo("Using Arguments: ")
            return "delete-user -t $($map.platformPassword) -u $($map.username)"
         }
        default {
            $logger.logWarning("No argument available for $key")
            $null
        }
    }
    return $configArgs
}


