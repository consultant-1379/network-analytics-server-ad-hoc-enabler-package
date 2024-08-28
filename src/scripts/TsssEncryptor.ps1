
# ********************************************************************
# Ericsson Radio Systems AB                                     Script
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
# Name    : TsssEncryptor.ps1
# Date    : 21/10/2016
# Revision: PA1
# Purpose : #  Encryption script for TSSS TERR
# ### Function: Encrypt-File ###
#
#   This function uses Rijndael .NET library to encrypt files.
#
# Arguments:
#   $fileName[string] the directory and name of the file to be encrypted.
#   $encryptedFile[string] the destination directory and name of the file once encrypted.
# Return Values:
#   Boolean
#
#---------------------------------------------------------------------------------
param(
     [Parameter(Mandatory=$true)][string]$fileName, 
     [Parameter(Mandatory=$true)][string]$encryptedFile
)
#Password is the CXC number
$Script:password = "CXC4011992"
#Salt should be randomly generated and be the same as used in the decrypt function
$Script:salt = "NxCSfD^0XecvER"
#Init should be randomly generated and should be the same as used in the decrypt function
$Script:init = "7d49cr^aYa739gH%0rq@M3"

function Encrypt-File {
    param(
    [string]$fileName, 
    [string]$encryptedFile
    )
   
    If (Test-Path $fileName) {
        
        Try {
            $rijndaelProvider = New-Object System.Security.Cryptography.RijndaelManaged

            #encode variables into UTF-8
            $pass = [Text.Encoding]::UTF8.GetBytes($password)
            $salt = [Text.Encoding]::UTF8.GetBytes($salt)
    
            #create key and vector for encryption
            $rijndaelProvider.Key = (New-Object Security.Cryptography.PasswordDeriveBytes $pass, $salt, "SHA1", 5).GetBytes(32)
            $rijndaelProvider.IV = (New-Object Security.Cryptography.SHA1Managed).ComputeHash( [Text.Encoding]::UTF8.GetBytes($init) )[0..15]

            $encryptor = $rijndaelProvider.CreateEncryptor()
            #open a file input stream and initialize stream
            $inputFileStream = New-Object System.IO.FileStream($fileName, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
            [int]$data = $inputFileStream.Length
            [byte[]]$inputFileData = New-Object byte[] $data
            [void]$inputFileStream.Read($inputFileData, 0, $data)
            $inputFileStream.Close()
            $outputFileStream = New-Object System.IO.FileStream($encryptedFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
            
            #create encryption stream, store in buffer and output encrypted data to file
            $encryptStream = New-Object Security.Cryptography.CryptoStream $outputFileStream, $encryptor, "Write"
            $encryptStream.Write($inputFileData, 0, $data)
            $encryptStream.Close()
            $outputFileStream.Close()
            $rijndaelProvider.Clear()
            return @($True, "File $fileName has been encrypted. Encrypted file available at $encryptedFile.")

        } Catch [Exception] {
            Write-Host $_.Exception.GetType().FullName; 
            Write-Host $_.Exception.Message; 
            return @($False, "File $fileName has not been encrypted.")

        }

    } Else {
      
        return @($False, "File $fileName not found.")
    
    }
}
Encrypt-File $fileName $encryptedFile