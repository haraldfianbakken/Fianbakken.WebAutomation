# Fianbakken.WebAutomation

Powershell module for Web Automation. 

# Known limitation
* Not storing / saving basic authentication for web session when exporting / importing session
* No support for SOAP actions yet.

# Intended usage:

* API Stress-testing 
* Advanced load-testing (through Microsoft Azure)
* API data testing 
* Security testing / bruteforce / capthas / ddos
* Web scraping


# Installation
Documentation is under construction... Module is should be published under the Powershell gallery or PSGet and should be installed through Install-Module

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

## Run the websession x-num times
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

## Select the time for each step in a formatted manner from the session
```powershell
$websession.RunTimes|Select @{Name="TotalMilliseconds";Expression={$_.ResponseTime.TotalMilliseconds}}, @{Name="Url";Expression={$websession.Steps[$_.StepIndex].Url}}, @{Name="Method";Expression={$websession.Steps[$_.StepIndex].Method}}
```

