# Fianbakken.WebAutomation

Powershell module for Web Automation. 

# Intended usage:

* API Stress-testing 
* Security testing 
* Web scraping
* Advanced load-testing (through Microsoft Azure)

# Installation
Documentation is under construction... Module is to be publised to PSGet and should be installed through PSGet / Install-Module

# Usage

## Create a new websession
```powershell
$websession = New-WebSesssion;
$url = "http://requestb.in/1hud5671";
$params=@{"Username"="user";"Password"="Passwor1d"} 
```
## Add a step to the session, specifying POST method
```powershell
$websession|Add-Step -step (create-step -Url $url -Params $params -Method POST)
```

## Add a step to post regular form-data to a url
```powershell
$contentType="application/x-www-form-urlencoded";
$websession|Add-Step -step (create-step -Url $url -Params $params -Method POST -ContentType $contentType)
```

## Add a step using a regular GET-request 

```powershell
$params=@{"UserId"="12";"AlbumId"="11"} 
$websession|Add-Step -step (create-step -Url (Create-Url -Url "http://requestb.in/1hud5671" -Params $params);
```

## Run the actual websession (10 times)
```powershell
Run-WebSession -websession $websession -Verbose -Times 10
```
## Export the websession definition to a file
```powershell
    Export-WebSessionDefinition -Websession $websession|Set-Content c:\tmp\MyWebSession.json
```

## Import the websession definiton from a file
```powershell
    Import-WebsessionDefinition -Path C:\tmp\MyWebSession.json
```

## Select the total time in a formatted manner
```powershell
$websession.RunTimes|Select @{Name="TotalMilliseconds";Expression={$_.ResponseTime.TotalMilliseconds}}, @{Name="Url";Expression={$websession.Steps[$_.StepIndex].Url}}, @{Name="Method";Expression={$websession.Steps[$_.StepIndex].Method}}
```

