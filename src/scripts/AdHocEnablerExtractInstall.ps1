# ********************************************************************
# Ericsson Radio Systems AB                                     SCRIPT
# ********************************************************************
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
# Name    : AdhocEnablerExtractInstall.ps1
# Purpose : #  Installation script for Enabling Adhoc Capability
#             
# Usage   : AdHocEnablerExtractInstall.ps1 ([string] $PlatformPassword)
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

#----------------------------------------------------------------------------------
#  Following parameters must not be modified
#----------------------------------------------------------------------------------
$adHocEnabler = "adhoc-enabler-bundle.exe"
$tsssSoftware = "TSSS-7.5.0.zip"
$adHocEnablerExeDir = "$PSScriptRoot"
$deployDir = "$PSScriptRoot\extracted"
$modulesDir = $deployDir+"\Modules"
$encrptedFile = "$deployDir\$tsssSoftware"
$uncoveredZipFile ="$PSScriptRoot\adhoc-enabler-bundle.zip"
$adHocEnablerExeArgs ="/t:$adHocEnablerExeDir /q:a"
$adHocInstallScript = "$deployDir\Install_AdhocEnabler.ps1"
$licenseTimeout = 15000   #15 seconds
Import-Module ZipUnzip -DisableNameChecking

$originalEnvPath = $env:PSModulePath
$env:PSModulePath = $env:PSModulePath + ";"+$modulesDir

$files = @($encrptedFile)

Function Main{

    If (!(Test-Path $adHocEnablerExeDir\$adHocEnabler)) {
        Write-Host "Error installing AdHoc Enabler Bundle. $adHocEnabler not found." -ForegroundColor Red
        Exit
    }
    Check-Ip
    try {
        $checkPassword=Invoke-ListUsers -pp $platformPass
    } catch {
        Write-Host "$($_.Exception.Message)" -ForegroundColor Red
        return 
    }
    $callExe = Start-Exe
    If($callExe[0] -eq $false){
        Write-Host $callExe[1]
        Exit  
    }else {
        Write-Host $callExe[1]
    }
    
    If(Test-Path $deployDir){
       $unzip = Unzip-File $uncoveredZipFile $deployDir -wait
    }Else{
        $dir = New-Item -ItemType directory -Path $deployDir -Force
        $unzip = Unzip-File $uncoveredZipFile $deployDir -wait
    }
    
    $decryptResult = Decrypt-TSSS
    if($decryptResult[0]) {
        Write-Host $decryptResult[1]
    } Else {
       Write-Host $decryptResult[1]
      }
   RunInstallScript $platformPass $FORCE   
    
}

Function Start-Exe {

    Try {
        
        Write-Host "Searching for a valid license..."

        $codeCoverproc = Start-Process $adHocEnabler -WorkingDirectory $adHocEnablerExeDir -ArgumentList $adHocEnablerExeArgs -PassThru

        If(-not $codeCoverproc.WaitForExit($licenseTimeout)) {
            Write-Host "AdHoc Enabler Bundle licensing check has timed out. Killing Process" -ForegroundColor Red
            try {
                kill $codeCoverproc -ErrorAction Stop
            } catch {
                $errorMessage = $_.Exception.Message
                Write-Host "Unable to terminate AdHoc Enabler Bundle Process. Exception: $errorMessage" -ForegroundColor Red
            }
            Write-Host "AdHoc Enabler Bundle licensing Process Killed. Exit Code $($codeCoverproc.ExitCode)" -ForegroundColor Red
        }

        If ($codeCoverproc.ExitCode -eq 0 ) {
            If (Test-Path $uncoveredZipFile) {
                return @($true, "License found.")
            } Else {
                return @($false, "License not found.")
            }
        } Else {
            return @($false, "Error validating license with licensing server.")
        }

    } Catch {
        return @($false, "Error with license checking.")
    }
}

Function RunInstallScript{
param ( 
    [String]$platformPass,
    [boolean]$FORCE
)
    If(Test-Path $adHocInstallScript){
        & $adHocInstallScript -pp $platformPass -f $FORCE
        Remove-Item $deployDir -Force -Recurse -Confirm:$False -ea SilentlyContinue
        Remove-Item $uncoveredZipFile -Force -Confirm:$False -ea SilentlyContinue
        Clean-EnvPath
    } else {
        Write-Host "$adHocInstallScript not found." -ForegroundColor Red
        Clean-EnvPath
        Exit
    }

}

### Function: Decrypt-TSSS ###
#
#   Decrypt TSSS software.
#
# Arguments:
#       none
# Return Values:
#       [list] - @($true|$false, [string] $message)
#

Function Decrypt-TSSS {

If (!(Test-Path $adHocEnablerExeDir\$tsssSoftware)) {
        Write-Host "Error installing Network Analytics Server Ad-Hoc Enabler Package. $tsssSoftware not found." -ForegroundColor Red
        Exit
    }
    Write-Host "Copying Software.."
    try {
        Copy-Item -Path $adHocEnablerExeDir\$tsssSoftware -Destination $deployDir -Recurse -Force
    } catch {
        return @($false, "ERROR Copying Network Analytics Server Ad-Hoc Enabler Package from $adHocEnablerExeDir\$tsssSoftware location.")
    }
    
    $status =  Set-FilePermission $encrptedFile
        if ( $status[0] -ne $True) {
            return @($false, $status[1])
        } 
        
    $decryptstatus =  Decrypt-TsssFile $encrptedFile
    if ($decryptstatus[0] -ne $True) {
        return @($false, $decryptstatus[1])
    } 
    
    Write-Host "Unzipping File..."
    if (-not (Unzip-Move)) {
        return @($false, "ERROR unzipping file " + $encrptedFile)
    }
    return @($true, "Decryption completed.")
}

### Function: Set-FilePermission ###
#
#   Updates file permissions to remove the readonly flag.
#
# Arguments:
#       [string] $directory
# Return Values:
#       [list] - @($true|$false, [string] $message)
#
Function Set-FilePermission {
    param( 
        [string]$file 
    )
    if (Test-Path $file) {
        try {
            Set-ItemProperty -Path $file -Name IsReadOnly -Value $false
        } catch {
            return @($false, "ERROR updating file permissions " + $file)
        }
    } else {
            return @($false, "ERROR file does not exist " + $file)
    }
    return @($true, "File permissions updated " + $file)
}


### Function: Unzip-Move ###
#
#   Unzip and move the software to the expected folder.
#
# Arguments:
#       None
# Return Values:
#       [list] - @($true|$false, [string] $message)
#
Function Unzip-Move {
    try {
        [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
        foreach ($item in $files) {
            [System.IO.Compression.ZipFile]::ExtractToDirectory($item, $deployDir+"\Software")
        }
    } catch {
        return @($false, "ERROR in unzipping file: " + $item)
    }
    return @($true, "Files unzipped successfully")
}

Function Clean-EnvPath {
    $env:PSModulePath = $originalEnvPath
    [Environment]::SetEnvironmentVariable("PSModulePath", $originalEnvPath, "Machine")
}

#----------------------------------------------------------------------------------
#  Validate ENIQ coordinator blade IP
#----------------------------------------------------------------------------------
Function Check-Ip {
    
    $ip = [Environment]::GetEnvironmentVariable("LSFORCEHOST","User")

    if([string]::IsNullOrEmpty($ip)) {
         Write-Host "LSFORCEHOST environment variable is not set as IP address of the ENIQ coordinator blade.Exit" -ForegroundColor Red
         Exit
    }
    
    $status = Test-Connection -ComputerName $ip -Quiet

    if(!$status) {
          Write-Host "Ping To ENIQ coordinator Blade Failed.Exit" -ForegroundColor Red
          Exit
    }
}

Main