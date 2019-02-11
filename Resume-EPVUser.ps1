################################### GET-HELP #############################################
<#
.SYNOPSIS
	Resume user that has been suspended in EPV

.EXAMPLE
	./Resume-EPVUser.ps1
	./Resume-EPVUser.ps1 -UserToResume John

.INPUTS
	UserToResume - The ID of the user that is suspended and needs resumed

.OUTPUTS
	None

.NOTES
	AUTHOR:
	Randy Brown

	VERSION HISTORY:
	1.0 10/05/2018 - Initial release
	1.1 02/11/2019 - Added manditory parameter to input user to be unlocked at run time
#>
######################### Parameters ####################################################
Param (
	[Parameter(Mandatory = $true)]
	[string] $UserToResume
)
######################### GLOBAL VARIABLE DECLARATIONS ###################################

$baseURI = "https://components.cyberarkdemo.com"		# URL or IP address for your environment
$appID = "UnlockUser"						# AppID created for resmuming users
$safe = "Unlock Users"						# Name of the safe that contains the CyberArk credential to resume the users
$folder = "root"						# Folder the credential is stored in (Usally this is root)
$object = "UserUnlock"						# The Object that corresponds to the credential in the Vault

########################## START FUNCTIONS ###############################################

Function EPV-Login($user, $pass) {

	$data = @{
		username=$user
		password=$pass
		useRadiusAuthentication=$false
	}

	$loginData = $data | ConvertTo-Json

	$ret = Invoke-RestMethod -Uri "$baseURI/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logon" -Method POST -Body $loginData -ContentType 'application/json'

	return $ret
}

Function EPV-Logoff {
	Invoke-RestMethod -Uri "$baseURI/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logoff" -Method POST -Headers $header -ContentType 'application/json'
}

Function EPV-GetUnlockUserPW {
	$ret = Invoke-RestMethod -Uri "$baseURI/AIMWebService/api/Accounts?AppID=$appID&Safe=$safe&Folder=$folder&Object=$object" -Method GET -ContentType 'application/json'

	return $ret
}

Function EPV-ActivateUser($userID) {
	$data = @{
		Suspended=$false
	}

	$resume = $data | ConvertTo-Json

	$ret = Invoke-RestMethod -Uri "$baseURI/PasswordVault/WebServices/PIMServices.svc/Users/$userID" -Method PUT -Body $resume -Headers $header -ContentType 'application/json'

	return $ret
}

########################## END FUNCTIONS #################################################

########################## MAIN SCRIPT BLOCK #############################################

Write-Host "Retreiving the credential to resume $userToResume..." -NoNewLine
$cred = EPV-GetUnlockUserPW
Write-Host "Success!"

$user = $cred.UserName

Write-Host "Logging into EPV as $user..." -NoNewLine
$login = EPV-Login $cred.UserName $cred.Content
$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("Authorization", $login.CyberArkLogonResult)
Write-Host "Success!"

Write-Host "Activating $userToResume..." -NoNewLine
$resume = EPV-ActivateUser $userToResume

If ($resume.Suspended -eq $false) {
	Write-Host "$userToResume was successfully resumed!" -ForegroundColor Green
} Else {
	Write-Host "$userToResume was not successfully resumed." -ForegroundColor Red
}

EPV-Logoff

########################### END SCRIPT ###################################################
