<#
.Synopsis
   Web automation tool and load-testing
.DESCRIPTION
   Tool for web automation and load-testing. This tool will keep session data and abstract methods and allow you to execute and aggregate 
   data for e.g. load-testing on multiple machines or stress-testing your application.
.AUTHOR
   Harald S. Fianbakken <harald.fianbakken "at" gmail "dot" com
#>


<#
.Synopsis
   Create a web-session that can be used for automating web-requests
.DESCRIPTION
   Creates a web-session (with an initial url), that saves headers and keeps the web-session alive throught subsequent requests
.EXAMPLE
   $s = New-WebSession -InitialUrl http://localhost:3100/LoginJSON   
.EXAMPLE
   Create a web session, and make the initial request post something (e.g. login) as the first action
   $s = New-WebSession -InitialUrl http://localhost:3100/LoginJSON 
   $s.Steps[0].Method = "POST";
   $s.Steps[0].Params = @{"Username"="user";"Password"="Pass@word"}
#>

function New-WebSesssion{
    [CmdletBinding(ConfirmImpact="None")] 
    [OutputType([PSCustomObject])]
    Param
    (
        # Url to the initial request         
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Alias("Uri")]
        [Alias("Url")]
        [Uri]
        $InitialUrl
    )
    begin{
        Write-Verbose "Creating new websession ! ";
    } 
    process{
        $webRequestSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession;    
        $properties = @{"WebSession"=$webRequestSession; "Steps"=@();"Runtimes"=@()}
        $ws = New-Object PSCustomObject -Property $properties;

        if($InitialUrl){
            $step = Create-Step -Url $InitialUrl;        
            Add-Step -websession $ws -step $step;
        }

        return $ws;     
    } 
    end {
        
    }
}

<#
.Synopsis
   Create a step for usage in a web-session
.DESCRIPTION
   Creates a step to be used in a websession (load-test / automated test).
.EXAMPLE
   Create-Step -url http://localhost:33000/Login -params @{"username"="admin";"password"="p@assword";} -Method "POST"
.EXAMPLE
   Create-Step -url http://localhost:33000/Login -params @{"username"="admin";"password"="p@assword";} -Headers "" -Method "POST"
#>
function Create-Step
{
    [CmdletBinding(ConfirmImpact="None")] 
    [OutputType([PSCustomObject])]
    Param
    (
        # Url to the request         
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Alias("Uri")]         
        [Uri]
        $Url,

        # Dictionary or string with params to pass to the request 
        [Parameter(Mandatory=$false, Position=1)]        
        $Params,

        # Dictionary with params to pass to the request 
        [Parameter(Mandatory=$false, Position=2)]
        [hashtable]
        $Headers,

        # Method to use for the request 
        # Todo - Support , "SOAP-ACTION" later
        [ValidateSet("GET","POST","PUT","DELETE")]
        [Parameter(Position=3)]
        [string]
        $Method="GET",


        # Method to use for the request         
        [ValidateSet("application/json", "application/xml", "application/x-www-form-urlencoded", "multipart/form-data","multipart/mixed")]
        [Parameter(Position=4)]
        [string]
        $ContentType="application/json"

    )
    Begin
    {
        Write-Verbose "Creating step $url using params $params";
    }
    Process
    {        
        $properties = @{"Url"=$url;"Method"=$method; "Headers"=$headers; "Params"=$params; "Response"=$false; "RequestStarted"=$false; "RequestEnded"=$false; "ResponseTime"=$false; "ContentType" = $ContentType};
        return New-Object PSCustomObject -Property $properties;        
    }
    End
    {
    }
}

<#
.Synopsis
   Exports a web session to a human readable json format
.DESCRIPTION
   To be used accross machines or configured from external editor and then imported
.EXAMPLE
   $websession = new-websession;   
   $websession|Export-WebsessionDefinition;
#>
function Export-WebSessionDefinition{    
    [CmdletBinding(ConfirmImpact="None")] 
    [OutputType([PSCustomObject])]
    Param
    (
        # The WebSession to export
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]        
        [PSCustomObject]
        $Websession
    )
    begin {
        Write-Verbose "Export web session definition";
        if(-not (Get-Member -InputObject $Websession -Name "WebSession")){
            Write-Error "Illegal input object! This must be a websession!";
            throw "Illegal input object!"
        }
    } 

    process 
    {
        Write-Verbose "Note : Export does not persist your cookies / headers"
        return ($websession|ConvertTo-Json -Depth 10000)
    }

    end {
        Write-Verbose "Ending export!";
    }
    
}

function Import-WebsessionDefinition{
    [CmdletBinding(ConfirmImpact="None")] 
    [OutputType([PSCustomObject])]
    param(
        
        [Parameter(Mandatory=$false)]
        [string]
        $Json,
        
        [Parameter(Mandatory=$false)]
        [System.IO.FileInfo]        
        $File,

        [Parameter(Mandatory=$false)]
        [string]
        [Alias("Fullname")]
        $Path
    )

    begin{
        Write-Verbose "Import websession definition!";
        if(-not $json){
            Write-Verbose "No json given";
            if($file){
                Write-Verbose "Using file $($File.FullName)";
                $json = ConvertFrom-Json (Get-Content -Path $File.FullName -Raw)
            } 

            if((Test-Path -Path $path)){
                Write-Verbose "Using path : $($path)";
                $json = ConvertFrom-Json (Get-Content -Path $Path -Raw)
            }
        } else {
            Write-Verbose "Converting from json";
            $json = ConvertFrom-Json $json;
        }

        if(-not $json -or $json.Length -lt 1){
            throw "Illegal arguments , no valid json to import!"
        }
    }

    process {
        $data = $Json;
        $s = New-WebSesssion;
        $s.Steps = $data.Steps;

        if($data.WebSession.Credentials){
            Write-Verbose "Import of credentials not supported yet!";
        }

        if($data.WebSession.Certificates){
            Write-Verbose "Import of Certificates not supported yet!";
        }


        $s.WebSession.UserAgent = $data.WebSession.UserAgent;
        $s.WebSession.MaximumRedirection = $data.WebSession.MaximumRedirection;
        $s.WebSession.Headers = $data.WebSession.Headers;
        $s.WebSession.Proxy = $data.WebSession.Proxy;

        return $s;
    }
    end {
        Write-Verbose "Ending import!"
    }


}



function Add-Step {    
    [CmdletBinding(ConfirmImpact="None")] 
    param(            
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [PSCustomObject]
        $websession,
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$false,
                   Position=1)]
        [PSCustomObject]$step
    )

    begin {
        Write-Verbose "Adding step to websession";
    } 

    process {
        if(-not (Get-Member -InputObject $step -Name "Method") -or
           -not (Get-Member -InputObject $step -Name "Url")){
            Write-Error "The step is not applicable to add";
        } else{
            Write-Verbose "Adding step to websession";        
            $websession.Steps += $step;
        }  
    } 
    end {
        Write-Verbose "Done adding step to websession";
    }
    
}

function Create-Url{
    [CmdletBinding(ConfirmImpact="None")] 
    param(
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Alias("Uri")]        
        [Uri]
        $Url,

        # Dictionary with params to pass to the request 
        [Parameter(Mandatory=$true, Position=1)]
        $Params
    )
    
    $queryString = "";

    if($params.GetType() -eq [hashtable]){
        $params.Keys|ForEach-Object {
            $queryString += "{0}={1}&" -f $_, $params[$_];
        }
    } elseif($params.GetType() -eq [string]){
        $queryString = $Params;
    }
    $querySTring = $queryString.Substring(0,$queryString.LastIndexOf("&"));
    $newurl = $url.OriginalString;
    
    if($newurl.Contains("?") -and -not $queryString.StartsWith("?")){
        $newurl  += "&{0}" -f $queryString;
    } else{
        $newurl  += "?{0}" -f $queryString;
    }

    return [uri]$newurl ;
}


<#
.Synopsis
   Executes a  websession and its steps
.DESCRIPTION
   Runs all the step a number of times for execution.
.EXAMPLE
   
   
#>
function Run-WebSession{
    [CmdletBinding(ConfirmImpact="None")] 
    param(
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [PSCustomObject]
        $websession, 
        [int]
        $times=1,

        # Automatically convert the params to query string/url
        [switch]
        $AutoConvertParamsForVerbs=$true,

        # Save response data for each request
        [switch]
        $SaveResponseData=$false
    )

       
    1..$times|Foreach-Object {
        $iteration=$_;
        $stepNum=0; 
        Write-Verbose "Running sequence iteration : $iteration"
        $runtimes = @();
        $websession.Steps|ForEach-Object {
            Write-Verbose "Running step $($stepNum+1)"
            $step = $_;
            $step.RequestStarted = [DateTime]::UtcNow;
            $url = $step.Url;            

            
            $body = "";
            
            if($step.ContentType -eq "application/json" -and ($step.Params -ne $null)  -and ($step.Params.GetType() -eq [hashtable]) -and $AutoConvertParamsForVerbs){                
                Write-Verbose "Converting params to JSON"
                $body = ConvertTO-Json $step.Params;
            } elseif($AutoConvertParamsForVerbs -and $step.Method -ne "POST" -and ($step.Params -ne $null) -and ($step.Params.GetType() -eq [hashtable])){
                Write-Verbose "Autoconverting params"
                $url = Create-Url -Url $url -Params $step.Params;                
                $body = "";
            } else{             
                Write-Verbose "Using params as is";
                $body = $step.Params;                                    
            }
         
            $response = Invoke-WebRequest -WebSession $websession.WebSession -Uri $url -Method $step.Method -Headers $step.Headers -Body $body -ContentType $step.ContentType        
            $step.RequestEnded = [DateTime]::UtcNow;
            $step.ResponseTime = New-TimeSpan -Start $step.RequestStarted -End $step.RequestEnded;

            if($SaveResponseData){
                $step.Response = $response;
            }
            $runtimes+=New-Object PSCustomObject -Property @{"Iteration"=$iteration;"StepIndex"=$stepNum;"RequestEnded"=$step.RequestEnded; "RequestStarted"=$step.RequestStarted;"ResponseTime"=$step.ResponseTime};
            
            $stepNum++;
        }

        $websession.Runtimes+=$runtimes;
    }
}


Export-ModuleMember Create-Step;
Export-ModuleMember New-WebSesssion;
Export-ModuleMember Add-Step;
Export-ModuleMember Export-WebSessionDefinition;
Export-ModuleMember Import-WebsessionDefinition;
Export-ModuleMember Run-WebSession;

