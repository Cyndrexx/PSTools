

$text=@"
$ver
    ____              __  _      __ 
   / __ )____ _____  / /_(_)____/ /_
  / __  / __ `/ __ \/ __/ / ___/ __/
 / /_/ / /_/ / /_/ / /_/ (__  ) /_  
/_____/\__,_/ .___/\__/_/____/\__/  
           /_/   

Created by Derek Lawrence  
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
         Write-Host "Press '1' Get Service Tags of ALL Nodes"
         Write-Host "Press '2' Get Status of StorageJob"
         Write-Host "Press '3' Get Status of Physical Disk"
         Write-Host "Press '4' Get OS Build Information of Nodes"
         Write-Host "Press '5' Get Status of Virtual Disk"
         Write-Host "Press '6' Find a VM"
         
         
         Write-Host "Press 'H' to Display Help"
         Write-Host "Press 'Q' to Quit"
         Write-Host ""
         $selection = Read-Host "Please make a selection"


         switch ($selection){
             1{
                Write-Host "Grabbing Service Tags..."
                Echo ""
                Echo ""
                Write-Host "Server         Model                     Tag" 
                Write-Host "-----------------------------------------------"
                foreach($c in $(Get-ClusterNode)) 
                    { Invoke-Command -ComputerName $c.Name -ScriptBlock 
                        {Write-Host $env:COMPUTERNAME  " " (Get-WmiObject win32_computersystemproduct).Name "---- "  -NoNewLine 
                         Write-Host "Service Tag = " -ForegroundColor Yellow -NoNewLine
                        (Get-WmiObject win32_computersystemproduct).IdentifyingNumber | Out-Host }
                    } 
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
             
             }
             #Grabbing Physical Disk Information
             3{
                Echo "";Echo ""
                Write-Host "----------------------------------------"
                Write-Host "Grabbing Physical Disk Info"
                Write-Host "----------------------------------------"
                Echo ""
                Get-PhysicalDisk | Out-Host
                Pause
                break
             }

             #Display OS Build of each Node
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
                                get-vm -name $findvm
                                Write-Host "---------------------------------------------"
                                Echo ""
                                Echo ""
                                Pause
                                ShowMenu
                            }
                            
                        }
                    }
            
                }
            }
        }
    while ($selection -ne "q")
    
    
    }
    
    
    

   


ShowMenu
