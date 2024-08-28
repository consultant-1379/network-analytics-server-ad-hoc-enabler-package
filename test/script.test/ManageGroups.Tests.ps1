$pwd = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesUnderTest = "$((Get-Item $pwd).Parent.Parent.FullName)\src\main\scripts\Modules"
$testResourceDirectory = "$((Get-Item $pwd).Parent.FullName)\resources\ManageGroups"
$password='configtoolpassword'
if(-not $env:PsModulePath.Contains($modulesUnderTest)) {
    $env:PSModulePath = $env:PSModulePath + ";$($modulesUnderTest)"
}

Import-Module ManageGroups

Describe "ManageGroups.psm1 Unit Test Cases" {

    Mock -ModuleName Logger Log-Message {} 


    $global:groupstemplate = "$($testResourceDirectory)\groups.txt"

    Context "Add-Groups is called with all correct parameters" {

        Mock -ModuleName ManageGroups Use-ConfigTool {} -Verifiable -ParameterFilter { $command -eq "import-groups -t $password -m true $global:groupstemplate" }        
        It "Add-Groups function should return boolean" {
            $actual = Add-Groups $global:groupstemplate  $password 
            Assert-VerifiableMocks
        }
    }
        Context "Add-Groups is called with  incorrect grouptemplate file" {

        Mock -ModuleName ManageGroups Use-ConfigTool {} -Verifiable -ParameterFilter { $command -eq "import-groups -t $password -m true $global:groupstemplate" }        
        It "Add-Groups function should return boolean" {
            $actual = Add-Groups "/some/path"  $password 
            $actual[0]|Should Be $False
            
        }
    }
}