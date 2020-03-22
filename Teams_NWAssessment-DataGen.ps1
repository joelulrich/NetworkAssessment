#Network Assessment core task script. V3.0 - 22/3/20
#By Joel Ulrich - joel@julrich.com, no warranties. Use at your own risk.

#Runs 12 assessments as 1&2 start and pause then 3-12 run???
#Dont change these vars, sets the out and binary directories. 
$workingDir = $PSScriptRoot
$binDir = $workingDir + "\bin"
$outDir = $workingDir + "\out"

#check for outdir and creates if needed
if(!(Test-Path -Path ($outDir + "\temp1"))) {
    mkdir ($outDir + "\temp1")
}

#Grab adaptor and hostnames
$netTest = Test-NetConnection -ComputerName 13.107.64.2
$hostname = $env:computername 

#predefine some vars
$arr = $null
$arr = @()
$items = $null
$itemsList = $null
$csv = $null

#Grab current datetime for reporting
$runDateTime2 = (get-date -Format yyMMdd-hhmmss)

#SET LAST RUN 
$runDateTime = (get-date -Format "dd/MM/yy hh:mm")
$runDateTime | Out-File -FilePath ($outDir + "\last_run.txt")

#start run log
($runDateTime + ".csv,Start,"+ (get-date -Format yy/MM/dd) + "," + (get-date -Format hh:mm:ss)) | Out-File -FilePath ($outDir + "\runLog.csv") -Append

Write-Host "Starting Jobs" 
Start-Job -Name Job1 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\1\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir
Start-Job -Name Job2 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\2\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir
Start-Job -Name Job3 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\3\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir
Start-Job -Name Job4 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\4\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir
Start-Job -Name Job5 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\5\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir
Start-Job -Name Job6 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\6\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir
Start-Job -Name Job7 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\7\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir
Start-Job -Name Job8 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\8\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir
Start-Job -Name Job9 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\9\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir
Start-Job -Name Job10 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\10\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir
Start-Job -Name Job11 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\11\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir
Start-Job -Name Job12 -ScriptBlock { param($binDir) Start-Process -FilePath ($binDir + "\12\NetworkAssessmentTool.exe") -WorkingDirectory $binDir -WindowStyle Hidden } -ArgumentList $binDir

#artifical sleep to make sure all tools have ran and finished
Write-Host "Finished Jobs" 
Write-Host "Sleeping for 120seconds then writing logs and results"
#Wait for Jobs to finish/tie out
Sleep 120

#cleanup jobs
Get-Job | Remove-Job

#generate list of csv's to import
$items = Get-ChildItem ($env:LOCALAPPDATA + "\Microsoft Skype for Business Network Assessment Tool") | select *
$itemsList = $items | where {$_.extension -eq “.csv”}

#import results
Foreach ($csv in $itemsList) {
    $arr += Import-Csv $csv.FullName | Select *,@{Name='ProbeHost';Expression={$hostname}},@{Name='SourceCSV';Expression={$csv.Name}},@{Name='interface';Expression={$netTest.InterfaceAlias.ToString()}}    
}

#out results
$arr | export-csv -path ($outDir + "\temp1\" + $runDateTime2 + ".csv") -NoTypeInformation

#end log
($runDateTime2 + ".csv,END,"+ (get-date -Format yy/MM/dd) + "," + (get-date -Format hh:mm:ss)) | Out-File -FilePath ($outDir + "\runLog.csv") -Append




