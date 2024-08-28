$pwd = Split-Path -Parent $MyInvocation.MyCommand.Path
$modulesUnderTest = "$((Get-Item $pwd).Parent.Parent.FullName)\src\Modules"
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
        Mock -ModuleName ManageGroups Use-ConfigTool {}
        Mock -ModuleName ManageGroups Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "import-groups -t $password -m true $global:groupstemplate" }        
        It "Add-Groups function should return boolean" {
            $actual = Add-Groups $global:groupstemplate  $password 
			Assert-VerifiableMocks
        }
    }
	
	Context "Add-Groups is called with  incorrect grouptemplate file" {
	    Mock -ModuleName ManageGroups Use-ConfigTool {}
      #Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "import-groups -t $password $global:groupstemplate" }        
         It "Add-Groups function should return boolean" {
            $actual = Add-Groups "/some/path"  $password 
            $actual[0]|Should Be $False
            Assert-MockCalled -ModuleName ManageGroups Use-ConfigTool -Exactly 0
        }
     } 
	       Context "Set-Licence is able to set all licenses" {
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {}			
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Author`" -l `"Spotfire.Dxp.WebAnalyzer`"" }      
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Author`" -l `"Spotfire.Dxp.Metrics`"" }      
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Analyst`" -l `"Spotfire.Dxp.Extensions`"" }      
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Analyst`" -l `"Spotfire.Dxp.Professional`"" }      
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Author`" -l `"Spotfire.Dxp.EnterprisePlayer`" -f `"openFile,saveDXPFile,saveToLibrary`"" }
         Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Analyst`" -l `"Spotfire.Dxp.Administrator`" -f `"libraryAdministration`"" }
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Analyst`" -l `"Spotfire.Dxp.InformationModeler`"" }      
        It "Set-Licence function should return boolean" {
            $actual = Set-Licence  $password
            $actual[0]|Should Be $TRUE
			Assert-VerifiableMocks
            
        }
    }
		Context "Set-Licence fails for one of License " {
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {}			
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Author`" -l `"Spotfire.Dxp.WebAnalyzer`"" }      
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Author`" -l `"Spotfire.Dxp.Metrics`"" }      
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Analyst`" -l `"Spotfire.Dxp.Extensions`"" }      
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Analyst`" -l `"Spotfire.Dxp.Professional`"" }      
        Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password  -g `"Business Author`" -l `"Spotfire.Dxp.EnterprisePlayer`" -f `"openFile,saveDXPFile,saveToLibrary`"" }
        #Mock -ModuleName NetAnServerConfig Use-ConfigTool {$TRUE} -Verifiable -ParameterFilter { $command -eq "set-license -t $password -g `"Business Analyst`" -l `"Spotfire.Dxp.InformationModeler`"" }      
        It "Set-Licence function should return false" {
            $actual = Set-Licence  $password
            $actual[0]|Should Be $FALSE
			Assert-VerifiableMocks
            
        }
    } 
}