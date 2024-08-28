Adhoc Enabler Manual Build Instructions 28-01-2016
==================================================
These are the manual build and packaging steps required to be carried out
prior to running the Jenkins build task on the adhoc enabler package.

Pre-requisites:
---------------
Sentinel RMS codecover must be installed
iExpress must be installed (is installed by default on Ericsson Workstations w/ Windows 7)


$ADHOC_REPO - the path to your local adhoc enabler repository
$NETANSERVER_REPO - the path to local Network Analytics Server REPO (gerrit.ericsson.se:29418/OSS/com.ericsson.eniq/network-analytics-server)
 
Stage 1 - Copy Build Items to temporary location
-------------------------------------------------
1. Create a temporary directory.

    $ADHOC_REPO\src\tmp

2. Copy 'modules' directory to temp directory '$ADHOC_REPO\src\tmp'  

3. Copy 'resources' directory to temp directory '$ADHOC_REPO\src\tmp'

4. Copy '$ADHOC_REPO\src\scripts\Install_AdhocEnabler.ps1' to temp directory '$ADHOC_REPO\src\tmp'

        The following folder structure / contents should now exist in the temporary directory '$ADHOC_REPO\src\tmp'

                        |
                        -- modules
                        |    |
                        |    -- ManageAdhocUsers 
                        |    |        |
                        |    |        -- ManageAdhocUsers.psm1
                        |    |
                        |    -- ManageGroups 
                        |    |         |
                        |    |         --ManageGroups.psm1
            			|    | 
            			|    -- PlatformVersion
            			|	 |     |
            			|	 |      --PlatformVersion.psm1
                        |    | 
                        |    -- FeatureUtility
                        |           |
                        |            -- FeatureUtility.psm1
                        |
                        |       
                        -- resources
                        |        |
                        |        -- folder
                        |        |     |
                        |        |     -- meta-data.xml
                        |        |
                        |        -- groups
                        |        |     |
                        |        |     --  adhocgroups.txt         
                        |        |
                        |        -- library
                        |               |
                        |               -- custom.part0.zip
                        |
                        |
                        -- Install_AdhocEnabler.ps1
                        
                        

Stage 2 - Create adhoc-enabler-bundle.zip
--------------------------------------------                        
5. Create a zip file named 'adhoc-enabler-bundle.zip' and add the contents of the temp directory '$ADHOC_REPO\src\tmp' to this zip

        The zip file should have the following folder structure

                adhoc-enabler-bundle.zip
                        |
                        -- modules
                        |    |
                        |    -- ManageAdhocUsers 
                        |    |        |
                        |    |        -- ManageAdhocUsers.psm1
                        |    |
                        |    -- ManageGroups 
                        |    |         |
                        |    |         --ManageGroups.psm1
            			|    | 
            			|    -- PlatformVersion
            			|	       |
            			|	       --.PlatformVersion.psm1
                        |        
                        -- resources
                        |       
                        |        -- folder
                        |        |     |
                        |        |     -- meta-data.xml
                        |        |
                        |        -- groups
                        |        |     |
                        |        |     --  adhocgroups.txt         
                        |        |
                        |        -- library
                        |        |       |
                        |        |       -- custom.part0.zip
						
                        |        -- config
                        |               |
                        |               -- Install_TERRServer.txt                        |
                        |
                        -- Install_AdhocEnabler.ps1      


Stage 3 - create code covered adhoc-enabler-bundle.exe
------------------------------------------------------
Use the LicenceFeature.ps1 script located in the Network Analytics Server platform repo.
This will create a code covered (licenced) exe.


6. Navigate to the Network Analytics Server platform licencing directory

    cd $NETANSERVER_REPO\src\main\scripts\Licencing
    
7. Execute the LicenceFeature.ps1 script with the following parameters

    .\LicenceFeature.ps1 "CXC4011992" "$ADHOC_REPO\src\tmp"
    
    This script will pick up any zip file in the argument provided directory i.e. the temp directory and apply the
    provided licence key to the exe.
    
    
Stage 4 - move adhoc-enabler-bundle.exe to build directory
----------------------------------------------------------
8. Move the $ADHOC_REPO\src\tmp\adhoc-enabler-bundle.exe to $ADHOC_REPO\src\build


Stage 5 - Delete the tmp directory
---------------------------------------
9. Delete the temporary directory and its contents:

    $ADHOC_REPO\src\tmp
    
    
Stage 6 - Push changes to remote Adhoc repo and run Jenkins build
-------------------------------------------------------------
Jenkins URL: https://fem101-eiffel013.lmera.ericsson.se:8443/jenkins/view/ENIQ_Official/job/network-analytics-server-ad-hoc-enabler-package/

    
