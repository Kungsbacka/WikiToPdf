. "$PSScriptRoot\Config.ps1"

function LogError([object]$o)
{
    "--- $(Get-Date -Format 'G')" | Out-File -FilePath "$PSScriptRoot\error.log" -Append
    "URL: $($Script:currentUrl)" | Out-File -FilePath "$PSScriptRoot\error.log" -Append
    $o | Out-File -FilePath "$PSScriptRoot\error.log" -Append
    "`r`n" | Out-File -FilePath "$PSScriptRoot\error.log" -Append
}

$credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @(
    $Script:Config.WikiUser
    $Script:Config.WikiPassword | ConvertTo-SecureString
)
if (Test-Path -Path "$PSScriptRoot\State.ps1")
{
    . "$PSScriptRoot\State.ps1"
    if ($Script:Config.AlwaysDoFullExport -or ((Get-Date) - $Script:State.LastFull).Days -gt $Script:Config.DaysBetweenFullExport)
    {
        $exportType = 'Full'
        $Script:State.LastFull = Get-Date
        $Script:State.LastIncremental = Get-Date
    }
    else
    {
        $exportType = 'Incremental'
        # Mediawiki API expects that time is UTC
        $rcStart = $Script:State.LastIncremental.ToUniversalTime().ToString('yyyyMMddHHmmss') 
        $Script:State.LastIncremental = Get-Date
    }
}
else
{   
    $exportType = 'Full'
    $Script:State = @{
        LastFull = Get-Date
        LastIncremental = Get-Date
    }
}
$vars = @(
    'action=query'
    'format=json'
)
if ($exportType -eq 'Full')
{
    $vars += @(
        'list=allpages'
        'aplimit=100'
    )
}
else # Incremental
{
    $vars += @(
        'list=recentchanges'
        'rcprop=title'
        'rcdir=newer'
        'rcnamespace=0'
        "rcstart=$rcStart"
    )
}
$wikiUrl = $Script:Config.WikiUrl.TrimEnd('/')
$apiUrl = "$wikiUrl/api.php?$($vars -join '&')"
$currentUrl = "$apiUrl&continue="
if ($exportType -eq 'Full')
{
    Remove-Item -Path (Join-Path -Path $Script:Config.Destination -ChildPath '*.pdf') -Confirm:$false
}
do
{
    try
    {
        $response = Invoke-WebRequest -Uri $currentUrl -Credential $credential -ErrorAction Stop
    }
    catch
    {
        LogError $_
        exit 1
    }
    $content = $response.Content | ConvertFrom-Json
    if ($content.error)
    {
        LogError ($content | ConvertTo-Json)
        exit 1
    }
    if ($exportType -eq 'Full')
    {
        $pages = $content.query.allpages
    }
    else # Incremental
    {
        $pages = $content.query.recentchanges
    }
    foreach ($page in $pages)
    {
        $filename = ($page.title -replace '[<>:"/\\|?*. ]', '_') + '.pdf'
        $title = [System.Web.HttpUtility]::UrlEncode($page.title)
        $arguments = @(
            '-q'
            '--no-background'
            '--username'
            $credential.UserName
            '--password'
            $credential.GetNetworkCredential().Password
            "$wikiUrl/index.php?title=$title"
            (Join-Path -Path $Script:Config.Destination -ChildPath $filename)
        )
        $result = & $Script:Config.WkhtmltopdfPath $arguments 2>&1
        if ($LASTEXITCODE -ne 0 -and ($result -join ' ') -notlike '*ContentNotFoundError*') # Ignore 404
        {
            LogError $result
            exit 1
        }
    }
    if ($content.continue)
    {
        if ($exportType -eq 'Full')
        {
            $currentUrl = "$apiUrl&apcontinue=$($content.continue.apcontinue)&continue=$($content.continue.continue)"
        }
        else # Incremental
        {
            $currentUrl = "$apiUrl&rccontinue=$($content.continue.rccontinue)&continue=$($content.continue.continue)"
        }
    }
}
while ($content.continue)

# Save state
"`$Script:State = @{LastFull = Get-Date '$($State.LastFull.ToString('G'))';LastIncremental = Get-Date '$($State.LastIncremental.ToString('G'))'}" |
    Out-File -FilePath "$PSScriptRoot\State.ps1" -Encoding UTF8 -Force
