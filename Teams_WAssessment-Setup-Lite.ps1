#Network Assessmentsetup script. V3.0 - 22/3/20
#By Joel Ulrich - julrich@icomm.com.au / joel@julrich.com
#Setup for Network Assessment script, adds firewall rules and copies binaries


#Only change if not installed under default directory
$nwAssessDir = "C:\Program Files (x86)\Microsoft Skype for Business Network Assessment Tool"
#how many agents?
$testUnits = 12

#dont change 
$workingDir = $PSScriptRoot
$binDir = $workingDir + "\bin"
$i = 1

if (!(Test-Path -Path "C:\Program Files (x86)\Microsoft Skype for Business Network Assessment Tool")) {
    Write-Host "Unable to find Network Assessment Folder under $nwAssessDir"
    Pause
}

#check for bindir and creates if needed
While ($i -lt($testUnits+1)) {
    if(!(Test-Path -Path ($binDir + "\" + $i.ToString() + "\") ) ) {
        $binDirDest = $binDir + "\" + $i
        mkdir $binDirDest
        Copy-Item -Path ($nwAssessDir + "\*") -Destination $binDirDest -Force  
        $config = Get-Content -Path ($binDirDest + "\NetworkAssessmentTool.exe.config")
        $config.Replace('<add key="ResultsFilePath" value="performance_results.tsv"/>','<add key="ResultsFilePath" value="performance_results' + $i.ToString() + '.csv"/>') | Out-file ($binDirDest + "\NetworkAssessmentTool.exe.config") -Force
    }
    $i++
}

#Checkbin dir for Tone.wav
if(!(Test-Path -Path ($binDir + "\Tone.wav") ) ) { 
    Copy-Item -Path ($nwAssessDir + "\Tone.wav") -Destination $binDir -Force
    
}

#Reser int var
$i = 1

#Add firewall rules
While ($i -lt($testUnits+1)){
    $binPath = $binDir + "\" + $i.ToString() + "\" + "NetworkAssessmentTool.exe"
    New-NetFirewallRule -DisplayName ("Teams Assessment Engine " + $i.ToString()) -Direction Inbound -Program $binPath -Action Allow
    Write-Host "FW Rule added for $binPath"
    $i++
    
}
