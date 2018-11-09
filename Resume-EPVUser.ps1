################################### GET-HELP #############################################
<#
.SYNOPSIS
	Resume user that has been suspended in EPV

.EXAMPLE
	./Resume-EPVUser.ps1

.INPUTS
	None via command line

.OUTPUTS
	None

.NOTES
	AUTHOR:
	Randy Brown

	VERSION HISTORY:
	1.0 10/05/2018 - Initial release
#>
##########################################################################################

######################### GLOBAL VARIABLE DECLARATIONS ###################################

$baseURI = "https://components.cyberarkdemo.com"		# URL or IP address for your environment
$appID = "UnlockUser"									# AppID created for resmuming users
$safe = "Unlock Users"									# Name of the safe that contains the CyberArk credential to resume the users
$folder = "root"										# Folder the credential is stored in (Usally this is root)
$object = "UserUnlock"									# The Object that corresponds to the credential in the Vault

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

$userToResume = Read-Host "What is the name of the user that needs to be resumed in EPV"

Write-Host "Retreiving the credential to resume $userToResume..." -NoNewLine
$cred = EPV-GetUnlockUserPW
Write-Host "Success!"

Write-Host "Logging into EPV as $cred.UserName..." -NoNewLine
$login = EPV-Login $cred.UserName $cred.Content
$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("Authorization", $login.CyberArkLogonResult)
Write-Host "Success!"

Write-Host "Activating $userToResume..." -NoNewLine
$resume = EPV-ActivateUser $userToResume

If ($resume.Suspended -eq $false) {
	Write-Host "$userToResume was successfully resumed!" -ForegroundColor Green
}

EPV-Logoff

########################### END SCRIPT ###################################################
