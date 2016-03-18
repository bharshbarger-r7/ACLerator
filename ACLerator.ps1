<# quick script to use either Get-Acls to determine permissions on the output from regshot.
README
You'll need to run set-executionpolicy remotesigned and as an administrator

USAGE
.\ACLerator.ps1 <filename>
#>

#params code stolen from https://stackoverflow.com/questions/2157554/how-to-handle-command-line-arguments-in-powershell
param (
[string] $source = $null
)


#Check for administrator
#stolen from https://social.technet.microsoft.com/Forums/scriptcenter/en-US/e0612a7a-4c1c-4221-be6d-d99cefc14244/need-help-with-running-powershell-script-as-admin?forum=ITCG
function Test-Elevation {
  $role = [Security.Principal.WindowsBuiltInRole]::Administrator
  $principal = [Security.Principal.WindowsPrincipal]`
    [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal.IsInRole($role)
}

if ( -not (Test-Elevation) ) {
  Write-Error "You must run this script as an administrator." -Category PermissionDenied
  exit
}


#spew lines if you want
#Get-Content $source


#for loop to dump acls
ForEach ($line in Get-Content $source)
	{
	
	Write-Host "Original line " $line	

	# fix lack of colons in path, this may be too much of a hack to work reliably
	$line = $line -replace "HKU","HKU:"
	$line = $line -replace "HKLM","HKLM:"

	# fix spaces, dashes, stars, etc in paths. script still hangs on *, possibly treating as wildcard
	$line = $line -replace " ","` "
	$line = $line -replace "-","`-"

	#just something to spew to the user and see if there's a hang
	Write-Host "This is the command that is running:"
	Write-Host Get-Acl -Path $line 
	
	#Path of my test file C:\Users\AVevasion\Desktop\1.txt
	
	#runs getacl on our line from the file. $line to deal with spaces in path. formats as list then appends to this file
	Get-Acl -Path $line | Format-List | Out-File C:\Users\AVevasion\Desktop\RegDiffAcls.txt -Append
	
	#optional pause to be able to read output
	start-sleep -seconds 0.1
	}


<# references to dump acls
Get-Acl -Path HKLM:\System\CurrentControlSet\Control | Format-List

dir -rec -file | select fullname,LastWriteTime,@{N='Owner';E={$_.GetAccessControl().Owner}}

#>
