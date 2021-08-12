# Update Types 
# Critical Updates - A widely released fix for a specific problem that addresses a critical, non-security-related bug.
# Definition Updates - A widely released and frequent software update that contains additions to a product’s definition database. Definition databases are often used to detect objects that have specific attributes, such as malicious code, phishing websites, or junk mail.
# Driver Sets - 
# Drivers - Software that controls the input and output of a device.
# Feature Packs - New product functionality that is first distributed outside the context of a product release and that is typically included in the next full product release.
# Security Updates - A widely released fix for a product-specific, security-related vulnerability. Security vulnerabilities are rated by their severity. The severity rating is indicated in the Microsoft security bulletin as critical, important, moderate, or low.
# Service Packs - A tested, cumulative set of all hotfixes, security updates, critical updates, and updates. Additionally, service packs may contain additional fixes for problems that are found internally since the release of the product. Service packs my also contain a limited number of customer-requested design changes or features.
# Tools - A utility or feature that helps complete a task or set of tasks.
# Update Rollups - A tested, cumulative set of hotfixes, security updates, critical updates, and updates that are packaged together for easy deployment. A rollup generally targets a specific area, such as security, or a component of a product, such as Internet Information Services (IIS).
# Updates - A widely released fix for a specific problem. An update addresses a noncritical, non-security-related bug.
# Upgrades
# This should work on all workstations/servers up to Server2019. It does however require Powershell 5.0 or higher. There's a catch somewhere in the code that will let you know if you're missing it or if you're not an Administrator.
# While I do trust my abilities and code. Never run this unwatched/unattended unless you know what you're doing. 

$forceRestart = $false
$interactive = $false
#Enter the desired update types from above into this array:
[string[]]$Update_Classifications = "Critical Updates", "Definition Updates", "Feature Packs", "Security Updates", "Tools", "Update Rollups", "Updates"

#Make sure the powershell version is 5 or higher
$psversion = $PSVersionTable.PSVersion.Major
if ($psversion -ge 5){
  # Ask for elevated permissions if required
  If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
  }else{
    #Running this code means this user is an administrator


    #Install Nuget if necessary
    $nuget=Get-PackageProvider -Name Nuget
    if (!($nuget)){
      Install-PackageProvider -Name NuGet -Force
    }    

    $result = 6 #tells the script to auto-reboot
    if ($interactive){
      $wshell = New-Object -ComObject Wscript.Shell
      $result = $wshell.Popup("Do you want to reboot after the updates if required?",0,"Autoreboot",48+4)
    }
    

    if ($result -eq 6){
      #User chose to autoreboot
      Install-Module PSWindowsUpdate
      #Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false #This is supposed to get updates for all microsoft products but the -MicrosoftUpdate switch does the same thing
      write-host "`r`nWhile updates are installing you may see extended periods of time with just a blinking cursor."

      if ($forceRestart){
        write-host "Will auto-reboot after installing updates."
        #Get-WUInstall –MicrosoftUpdate –AcceptAll -Category $Update_Classifications
        Get-WindowsUpdate -MicrosoftUpdate -Install -Category $Update_Classifications -Verbose -AcceptAll
        Start-Sleep -Seconds 60
        Restart-Computer -Force
      }else{
        Write-Host "Will auto-reboot if the updates request it."
        Get-WindowsUpdate -MicrosoftUpdate -Install -Category $Update_Classifications -AutoReboot -Verbose -AcceptAll
      }     
      
    }else{
      Install-Module PSWindowsUpdate
      Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
      write-host "`r`nWhile updates are installing you may see extended periods of time with just a blinking cursor."
      #Get-WUInstall –MicrosoftUpdate –AcceptAll -Category $Update_Classifications #-AutoReboot
      Get-WindowsUpdate -MicrosoftUpdate -Install -Category $Update_Classifications -Verbose -AcceptAll

      if ($interactive){
        $wshell = New-Object -ComObject Wscript.Shell
        $result = $wshell.Popup("Updates are complete.",0,"Finished",48)
      }else{
        write-host "Updates are complete."
      }     
    }
  }
}else{
  if ($interactive){
    $wshell = New-Object -ComObject Wscript.Shell
    $result = $wshell.Popup("Powershell 5 is required. You have version $psversion. Exiting.",0,"Autoreboot",48)
  }else{
    write-host "Powershell 5 is required. You have version $psversion. Exiting."
  }
  
}