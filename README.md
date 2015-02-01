# Fianbakken.WebAutomation
Powershell module for Web Automation

# Some usage (Documentation to be made..)
#$websession = New-WebSesssion;
# Add a normal post using JSON data
#$websession|Add-Step -step (create-step -Url "http://requestb.in/1hud5671" -Params @{"Username"="user";"Password"="Passwor1d"} -Method POST)
# Add a normal
#$websession|Add-Step -step (create-step -Url "http://requestb.in/1hud5671" -Params @{"Username"="user";"Password"="Passwor1d"} -Method POST -ContentType application/x-www-form-urlencoded)
# Create a Get-Request - add the params to the URL instead
#$websession|Add-Step -step (create-step -Url (Create-Url -Url "http://requestb.in/1hud5671" -Params @{"asfd"="aa";"test"="1923091"}));

#Run-WebSession -websession $websession -Verbose


# Show some aggregated data 

#$websession.Steps|Select @{Name="TotalMilliseconds";Expression={$_.ResponseTime.TotalMilliseconds}}, @{Name="Url";Expression={$_.Url}}, @{Name="Method";Expression={$_.Method}}


