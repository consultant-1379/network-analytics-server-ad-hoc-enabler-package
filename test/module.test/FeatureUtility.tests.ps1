$pwd = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesUnderTest = "$((Get-Item $pwd).Parent.Parent.FullName)\src\main\modules"


if(-not $env:PsModulePath.Contains($modulesUnderTest)) {
    $env:PSModulePath = $env:PSModulePath + ";$($modulesUnderTest)"
}

Import-Module Logger
Import-Module FeatureUtility


Describe "Feature Utility Tests" {

   BeforeEach{
     $installParams = @{}
     $installParams.Add('username', "netanserver")
     $installParams.Add('userPassword', "Ericsson01")
     $installParams.Add('platformPassword', "Ericsson02")
     $installParams.Add('groupname', "Group01")
     $installParams.Add('tomCatDir', "path to dir")
 }

     Context "When Get-CommandArguments is called" {
        Mock -ModuleName Logger Log-Message {}
        $stages = @('create-user', 'add-member','list-users','delete-user')

            It "Should return the correct string for 'create-user'" {
                $output = Get-CommandArguments $stages[0] $installParams 
                $expected = "create-user -t Ericsson02 -u netanserver -p Ericsson01"
                $output | Should BeExactly $expected  
            }
           
            It "Should return the correct string for 'add-member'" {
                $output = Get-CommandArguments $stages[1] $installParams 
                $expected = "add-member -t Ericsson02 -g Group01 -u netanserver"
                $output | Should BeExactly $expected  
            }
            
            It "Should return the correct string for 'list-users'" {
                $output = Get-CommandArguments $stages[2] $installParams 
                $expected = "list-users -t Ericsson02"
                $output | Should BeExactly $expected  
            }
          
            It "Should return the correct string for 'delete-user'" {
                $output = Get-CommandArguments $stages[3] $installParams 
                $expected = "delete-user -t Ericsson02 -u netanserver"
                $output | Should BeExactly $expected  
            }

            It "Should return NULL if incorrect key passed" {
                $stage = "incorrect key"
                $output = Get-CommandArguments $stage $installParams 
                $ouput | Should Be $NULL
            }
        }

}