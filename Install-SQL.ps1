$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If (!($isAdmin))
{
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	exit
}

Start-Transcript -Path "$PSScriptRoot\Install-SQL.log"

$Start = get-date
Write-host ('Installation started at {0}' -f $Start)

If (Test-Path -Path "$PSScriptRoot\SQL\setup.exe")
{
	$SQLSetupEXE = (Get-Item -Path "$PSScriptRoot\SQL\setup.exe" -ErrorAction SilentlyContinue).fullname
	Write-Host ('$Setupfile detected')
}
else
{
	Write-Host "Select SQL Setup.exe"
	[reflection.assembly]::loadwithpartialname("System.Windows.Forms")
	$openFile = New-Object System.Windows.Forms.OpenFileDialog
	$openFile.Filter = "setup.exe files |setup.exe|All files (*.*)|*.*"
	If ($openFile.ShowDialog() -eq "OK")
	{
		$SQLSetupEXE = $openfile.filename
		Write-Host  ('{0} selected' -f $SQLSetupEXE)
	}
	if (!$openFile.FileName)
	{
		Write-Error  "setup.exe not selected."
	}
}

Write-Host ('Installing SQL Server')
& $SQLSetupEXE /q /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER /SQLSVCACCOUNT="DomainNameBookmark\SQL_SA" /SQLSVCPASSWORD="PasswordBookmark" /SQLSYSADMINACCOUNTS="DomainNameBookmark\Domain admins" /AGTSVCACCOUNT="DomainNameBookmark\SQL_Agent" /AGTSVCPASSWORD="PasswordBookmark" /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS /Indicateprogress /UpdateEnabled=0

Write-Host ('Script completed at {0} and installation took {1} seconds' -f (Get-date), (((get-date) - $Start).TotalSeconds))
Stop-Transcript

Write-Host "Completed"
exit