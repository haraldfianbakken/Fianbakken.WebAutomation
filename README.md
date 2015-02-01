# Fianbakken.WebAutomation

Powershell module for Web Automation

# Usage
Documentation is under construction...
Module is to be publised to PSGet

## Create a new websession
```powershell
$websession = New-WebSesssion;
```
## Add a step to the session, specifying POST method
```powershell
$websession|Add-Step -step (create-step -Url "http://requestb.in/1hud5671" -Params @{"Username"="user";"Password"="Passwor1d"} -Method POST)
```
## Add a step posting regular form/data to a url
$websession|Add-Step -step (create-step -Url "http://requestb.in/1hud5671" -Params @{"Username"="user";"Password"="Passwor1d"} -Method POST -ContentType application/x-www-form-urlencoded)
```

## Add a step using a regular GET-request 

```powershell
$websession|Add-Step -step (create-step -Url (Create-Url -Url "http://requestb.in/1hud5671" -Params @{"asfd"="aa";"test"="1923091"}));
```

## Run the actual websession (10 times)
```powershell
Run-WebSession -websession $websession -Verbose -Times 10
```

## Select the total time in a formatted manner
```powershell
$websession.RunTimes|Select @{Name="TotalMilliseconds";Expression={$_.ResponseTime.TotalMilliseconds}}, @{Name="Url";Expression={$websession.Steps[$_.StepIndex].Url}}, @{Name="Method";Expression={$websession.Steps[$_.StepIndex].Method}}
```

