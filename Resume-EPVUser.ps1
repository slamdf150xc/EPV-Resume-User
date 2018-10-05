$baseURI = "https://components.cyberarkdemo.com"

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
	$ret = Invoke-RestMethod -Uri "$baseURI/AIMWebService/api/Accounts?AppID=UnlockUser&Safe=Unlock Users&Object=UserUnlock" -Method GET -ContentType 'application/json'

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

$userToResume = Read-Host "What is the name of the user that needs to be resumed in EPV"

$cred = EPV-GetUnlockUserPW

$login = EPV-Login $cred.UserName $cred.Content
$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("Authorization", $login.CyberArkLogonResult)

$resume = EPV-ActivateUser $userToResume

If ($resume.Suspended -eq $false) {
	Write-Host "$userToResume was successfully unlocked!" -ForegroundColor Green
}