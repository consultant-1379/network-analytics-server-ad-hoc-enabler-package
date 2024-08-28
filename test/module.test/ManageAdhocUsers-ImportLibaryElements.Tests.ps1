$pwd = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesUnderTest = "$((Get-Item $pwd).Parent.Parent.FullName)\src\Modules"
$testResourceDirectory = "$((Get-Item $pwd).Parent.FullName)\resources\"

if(-not $env:PsModulePath.Contains($modulesUnderTest)) {
    $env:PSModulePath = $env:PSModulePath + ";$($modulesUnderTest)"
}

Import-Module ManageAdhocUsers

Describe "ManageAdhocUsers.psm1 Import-LibraryElement Unit Test Cases" {

    Mock -Modulename Logger Log-Message {}
    

    Context "When a destination is supplied" {
        Mock -ModuleName ManageAdhocUsers Use-ConfigTool {} 
        Mock -ModuleName ManageAdhocUsers Use-ConfigTool {} -Verifiable -ParameterFilter { $command -eq "import-library-content -t password -p C:\temp -m KEEP_BOTH -u username -l `"/Ericsson/Test`"" } 
    
        It "Should call Use-ConfigTool with import location" {
            Import-LibraryElement -element "C:\temp" -username "username" -password "password" -destination "/Ericsson/Test" -conflict "KEEP_BOTH"
            Assert-VerifiableMocks
        }
    }
}