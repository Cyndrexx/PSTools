

$text=@"
$ver

Simple command Script

  
"@
$DateTime=Get-Date -Format yyyyMMdd_HHmmss
$OSInfo = Get-WmiObject -Class Win32_OperatingSystem
$sel='[1-3,qQ,hH]'
Function ShowMenu{
    do
     {
         $selection=""
         Clear-Host
         Write-Host $text
         Write-Host ""
         #Write-Host "Please make a selection of what you would like to do"
         Write-Host ""
         Write-Host "==================== Please make a selection ====================="
         Write-Host ""
         Write-Host "Press '1' To Access HCI Commands"
         #Write-Host "Press '1' Get Service Tags of ALL Nodes"
         #Write-Host "Press '2' Get Status of StorageJob"
         Write-Host "Press '2' Get Status of Physical Disk"
         Write-Host "Press '3' Get Disk Usage"
         Write-Host "Press '4' Get List of Installed Drivers"
         Write-Host "Press '5' Get List of Virtual Disks"
         Write-Host "Press '6' to Run DISM Check"

         #Write-Host "Press '4' Get OS Build Information of Nodes"
         #Write-Host "Press '5' Get Status of Virtual Disk"
         #Write-Host "Press '6' Find a VM"
         

         
         Write-Host ""
         Write-Host ""
         Write-Host "Press 'H' to Display Help"
         Write-Host "Press 'Q' to Quit"
         Write-Host ""
         $selection = Read-Host "Please make a selection"


         switch ($selection){
                #Display HCI Commands
             1{
                    ShowHCIMenu
             
                }#End of 1
             pm{
                    ShowPatchingMenu
              
              }



             #Grabbing Physical Disk Information
             2{
                Echo "";Echo ""
                Write-Host "----------------------------------------"
                Write-Host "Grabbing Physical Disk Info"
                Write-Host "----------------------------------------"
                Echo ""
                Get-PhysicalDisk | Out-Host
                Pause
                break
             }
             3{
                Get-WmiObject -Class Win32_LogicalDisk | ForEach-Object {
                        $driveType = switch ($_.DriveType) {
                            2 { "Removable" }
                            3 { "Local Disk" }
                            4 { "Network" }
                            5 { "CD-ROM" }
                            6 { "RAM Disk" }
                            default { "Unknown" }
                        }

                        $totalSize = $_.Size / 1MB
                        $freeSpace = $_.FreeSpace / 1MB
                        $usedSpace = $totalSize - $freeSpace
                        $usedPercentage = if ($totalSize -eq 0) { 0 } else { [math]::Round($usedSpace / $totalSize * 100, 2) }
                        $freePercentage = if ($totalSize -eq 0) { 0 } else { [math]::Round($freeSpace / $totalSize * 100, 2) }

                        $sizeUnit = "MB"
                        $totalSizeGB = $totalSize
                        $usedSpaceGB = $usedSpace
                        $freeSpaceGB = $freeSpace

                        if ($totalSize -gt 1024) {
                            $sizeUnit = "GB"
                            $totalSizeGB = [math]::Round($totalSize / 1024, 2)
                            $usedSpaceGB = [math]::Round($usedSpace / 1024, 2)
                            $freeSpaceGB = [math]::Round($freeSpace / 1024, 2)
                        }

                        [PSCustomObject]@{
                            Drive       = $_.DeviceID
                            Type        = $driveType
                            TotalSize   = "$totalSizeGB $sizeUnit"
                            UsedSpace   = "$usedSpaceGB $sizeUnit"
                            UsedPercent = "$usedPercentage %"
                            FreeSpace   = "$freeSpaceGB $sizeUnit"
                            FreePercent = "$freePercentage %"
                        }
                    } | Format-Table -AutoSize | Out-Host
                     
                     
                     Pause
                     ShowMenu
             }#End of 3
             
             #List currently installed drivers
             4{
                GWmi Win32_PnPSignedDriver|?{$_.DeviceName -match "HBA"-or($_.DeviceName -match "Marvell")-or(($_.DeviceName -match "Chipset")-and($_.DeviceName -match "Controller"))-or ($_.DeviceName -match "Ethernet")-or ($_.DeviceName -match "FastLinQ")-or ($_.DeviceName -match "QLogic")-or ($_.DeviceName -match "giga")-or ($_.DeviceName -match "PERC")-or ($_.DeviceName -match "Mell")-or ($_.DeviceName -match "NVIDIA")-or ($_.DeviceName -match "E810")-or ($_.DeviceName -match "SMBus")} | select PSComputerName, DeviceName, DriverVersion, Manufacturer,infname | Sort DeviceName | FT -AutoSize
                Pause
                break
             }#End of 4

             
             #Display OS Build of each Node
             5{
                Echo ""
                Echo ""
                Write-Host "----------------------------------------"
                Write-Host "Displaying Virtual Disks"
                Write-Host "----------------------------------------"
                Get-VirtualDisk | Out-Host
                Echo""
                Pause
                break
             }

             #Find a VM
             6{
             Echo ""
             Echo ""
             Write-Host " DISM check requires an elevated cmd window."
             Write-Host " Ensure that you run as Administrator" 
             Echo ""
             dism.exe /online /Cleanup-Image /StartComponentCleanup
             Pause
             break
            
              }
                
            }#End of Switch
        }#End of "DO"


    while ($selection -ne "q")
    
    
    }

Function ShowHCIMenu{
    do{
        $HCIselection=""
         Clear-Host
         Write-Host $text
         Write-Host ""
         #Write-Host "Please make a selection of what you would like to do"
         Write-Host ""
         Write-Host "==================== Please make a selection ====================="
         Write-Host ""
         Write-Host "Press '1' Get Service Tags of ALL Nodes"
         Write-Host "Press '2' Get-StorageJob"
         Write-Host "Press '3' Get Status of Physical Disk"
         Write-Host "Press '4' Get OS Build Information of Nodes"
         Write-Host "Press '5' To Locate a VM on the Clusters"
         Write-Host "Press 'E' To Return to Main menu"
         $HCIselection = Read-Host "Please make a selection"
      
    
 #     _   _  ____ ___   __  __                  
 #| | | |/ ___|_ _| |  \/  | ___ _ __  _   _ 
 #| |_| | |    | |  | |\/| |/ _ \ '_ \| | | |
 #|  _  | |___ | |  | |  | |  __/ | | | |_| |
 #|_| |_|\____|___| |_|  |_|\___|_| |_|\__,_|

    switch($HCISelection){
             
             
             #Get Service Tags of all the Nodes within a cluster
             1{
                Write-Host "Grabbing Service Tags..."
                Echo ""
                Echo ""
                Write-Host "Server         Model                     Tag"
                Write-Host "-----------------------------------------------"
                foreach($c in $(Get-ClusterNode)) { Invoke-Command -ComputerName $c.Name -ScriptBlock {Write-Host $env:COMPUTERNAME  " " (Get-WmiObject win32_computersystemproduct).Name "---- "  -NoNewLine; Write-Host "Service Tag = " -ForegroundColor Yellow -NoNewLine;(Get-WmiObject win32_computersystemproduct).IdentifyingNumber }}
                Echo "" 
                Echo ""
                Pause
                break
             }
             #Get status of StorageJob
             2{
                Echo "";Echo ""
                Write-Host "----------------------------------------"
                Write-Host "Grabbing StorageJob Info"
                Write-Host "----------------------------------------"
                Echo ""
                Get-StorageJob | Out-Host
                Pause
                break
             
             }#End of 2

             3{
                Echo "";Echo ""
                Write-Host "----------------------------------------"
                Write-Host "Grabbing Physical Disk Info"
                Write-Host "----------------------------------------"
                Echo ""
                Get-PhysicalDisk | Out-Host
                Pause
                break
             }#END of 3

             4{
                Echo ""
                Echo ""
                Write-Host "----------------------------------------"
                Write-Host "Displaying OS Build Information"
                Write-Host "----------------------------------------"
                Echo""
                $nodes = Get-ClusterNode | % NodeName
                Invoke-Command $nodes { $v = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\' -Name CurrentMajorVersionNumber, CurrentMinorVersionNumber, CurrentBuildNumber, UBR; "$(hostname): $($v.CurrentMajorVersionNumber).$($v.CurrentMinorVersionNumber).$($v.CurrentBuildNumber).$($v.UBR)" } | Sort-Object
                Pause
                break
             }
             5{
             Echo ""
             Echo ""
             $findvm = Read-Host "Please Provide VM Name"
             Echo ""
             $clusters = $clusters = (get-cluster -domain bh.local | where  {($_.name -like "cop-azc*") -or ($_.name -like "NCP-AZC1") -or ($_.name -like "SAP-AZC1")}) 
                    foreach ($cluster in $clusters) {
                        Write-Host "Checking Cluster: $($cluster.Name)"
                        $nodes = Get-ClusterNode -Cluster $cluster.Name
                        foreach ($node in $nodes) {
                            Write-Host "  Checking Node: $($node.Name)"
                            #Get VMs on the node
                            $vms = Get-VM -ComputerName $node.Name
                            if($vms -match $findvm){
                                Echo ""
                                Echo ""
                                Write-Host "VM HAS BEEN FOUND"
                                Write-Host "---------------------------------------------"
                                Write-Host "VM found on node: $($node.Name)"
                                Echo ""
                                get-vm -name $findvm | out-host
                                Write-Host "---------------------------------------------"
                                Echo ""
                                Echo ""
                                Pause
                                ShowMenu
                                break 2
                            }
                            
                        }
                    }
            
                }



        e{
            Write-Host ""
            Write-Host "Returning to Main Menu...."
            Write-Host ""
            Write-Host ""
            Start-Sleep -seconds 3
            ShowMenu
            }
        


     }#end of Switch
    }while($HCIselection -ne "e") #END of "DO"

}


#  ____       _       _       __  __                  
# |  _ \ __ _| |_ ___| |__   |  \/  | ___ _ __  _   _ 
# | |_) / _` | __/ __| '_ \  | |\/| |/ _ \ '_ \| | | |
# |  __/ (_| | || (__| | | | | |  | |  __/ | | | |_| |
# |_|   \__,_|\__\___|_| |_| |_|  |_|\___|_| |_|\__,_|

Function ShowPatchingMenu{
        $sol=""
        do{
        
        $PatchSelection=""
         Clear-Host
         Write-Host $text
         Write-Host ""
         #Write-Host "Please make a selection of what you would like to do"
         Write-Host ""
         Write-Host "==================== Please make a selection ====================="
         Write-Host ""
         Write-Host "--------------------------------------------------------"
         Write-Host "Current Selected ResourceID = " $sol
         Write-Host "--------------------------------------------------------"
         Write-Host ""
         Write-Host "Press '1' Get Solution Environment"
         Write-Host "Press '2' Get Available Update Information"
         Write-Host "Press '3' Get Update Release Information"
         Write-Host "Press 'E' To Return to Main menu"
         $PatchSelection = Read-Host "Please make a selection"

         switch($PatchSelection){
            1{
                Write-Host ""
                Write-Host "The Current Solution Environment:"
                Write-Host ""
                Get-SolutionUpdateEnvironment | FT CurrentVersion, CurrentSbeVersion, State, HealthState, HealthCheckDate -Autosize
                Pause
                break
            }#End of 1

            2{
                Write-Host ""
                Write-Host "Below are the following Available Updates.  Solutions generally go before any SBE update"
                Write-Host ""
                Get-SolutionUpdate | Where-Object {$_.State -like "Ready*" -or $_.State -like "Additional*"} | FT DisplayName, Description, ResourceId, State, PackageType -Autosize
                Echo ""
                Pause
                break
            }#End of 2

            3{
                Write-Host ""
                $sol = Read-Host "Which Solution ID"
                Write-Host ""
                $Update = Get-SolutionUpdate -Id $sol | FL ResourceId, State, DisplayName, ReleaseLink, RebootRequired, HealthState, HealthCheckResult
                $Update
                Echo ""
                Pause
                break
            
            }
         
         }

         }While($PatchSelection -ne "e")
}

ShowMenu
