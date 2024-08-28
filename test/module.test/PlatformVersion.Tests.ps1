$pwd = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesUnderTest = "$((Get-Item $pwd).Parent.Parent.FullName)\src\Modules"
$testResourceDirectory = "$((Get-Item $pwd).Parent.FullName)\resources\PlatformVersion"
#$password='configtoolpassword'

if(-not $env:PsModulePath.Contains($modulesUnderTest)) {
    $env:PSModulePath = $env:PSModulePath + ";$($modulesUnderTest)"
}

Import-Module PlatformVersion

Describe "ProductVersion.psm1 Unit Test Cases" {

    It "should return false if no file found" {
            $someNonExistentFile = "C:\nonexistent.xml"
            $result = Get-AdhocEnablerDataFromFile $someNonExistentFile
            $result[0] | should be $false
        }

     It "should return error message if no file found" {
            $someNonExistentFile = "C:\nonexistent.xml"
            $result = Get-PlatformDataFromFile $someNonExistentFile
            $result[1] | should be "platform-release.xml not found at path: C:\nonexistent.xml"
        }

    It "should return  true if a platform-release.xml file is passed to it" {
            $platformReleaseXml = $testResourceDirectory + "\feature-release.R1A03.xml"
            $result = Get-PlatformDataFromFile $platformReleaseXml
            $result[0] | Should be $True
        }

        It "should return a hashtable if a platform-release.xml file is passed to it" {
            $platformReleaseXml = $testResourceDirectory + "\feature-release.R1A03.xml"
            $result = Get-PlatformDataFromFile $platformReleaseXml
            $result[1] | Should Not Be $null
            $result[1].GetType().Name | Should Be "HashTable"
        }

        It "should return a map with correct number of keys" {
            $platformReleaseXml = $testResourceDirectory + "\feature-release.R1A03.xml"
            $result = Get-PlatformDataFromFile $platformReleaseXml
            $keyCount = ($result[1].Keys | measure).Count
            $keyCount | Should Be 5
        }

        It "should contain the correct value for productID and release" {
            $platformReleaseXml = $testResourceDirectory + "\feature-release.R1A03.xml"
            $result = Get-PlatformDataFromFile $platformReleaseXml 

            $productID = $result[1]['PRODUCT-ID']
            $release = $result[1]['RELEASE']
            $productID | Should Be "CXC4011992"
            $release | Should Be "16B"


            
        }
	
}