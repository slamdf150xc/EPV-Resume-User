# EPV-Resume-User
PowerShell utility to resume a suspended user in EPV.

## Prerequisites
You will need the following setup in the Vault prior to modifying and using this script.

#### EPV Accounts
- You will need to have a user account that has rights to resume suspended users, this user should have rights to **Audit Users** & **Activate Users**.

#### CCP (Central Credential Provider)
Because this is 100% based on REST APIs you will need to have a CCP instance up and running so we can retreive the account username and password at run time to preform the resume function.

#### Credential and Safe Setup
You will need to store the credential of the user that will be used to resumes other users in a safe in the Vault. You will then need to assign **PROV_{CCP User}**, **{AppID User}** and the **{Account to preform resume}** to the safe with **List Files**, **Retrieve Files**, **View Audit**, **View Owners** and **Use Pssword** permissions.

You can also create a group in the Vault with these users in it and assign that one group the same permissions to the safe.

## Edit the Script
Once you have the script on your system you will need to edit a few variables so it will run.
- **$baseURL**, URL or IP address for your environment.
- **$appID**, AppID created for resmuming users.
- **$safe**, the name of the safe that contains the CyberArk credential to resume the users.
- **$folder**, folder the credential is stored in (Usally this is root).
- **$object**, the Object that corisponds to the credential in the Vault.

## Running the script
```
.\Unlock-EPVUser.ps1
```
You will be promted for input...
> What is the name of the user that needs to be resumed in EPV:

## Things to do
- [ ] Allow script to take user to resume as arugment.
