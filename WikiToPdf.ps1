. "$PSScriptRoot\Config.ps1"

$credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList @(
    $Script:Config.WikiUser
    $Script:Config.WikiPassword | ConvertTo-SecureString
)
$wikiUrl = $Script:Config.WikiUrl.TrimEnd('/')
$apiUrl = "$wikiUrl/api.php?action=query&list=allpages&aplimit=100&format=json"
$currentUrl = "$apiUrl&continue="
Remove-Item -Path (Join-Path -Path $Script:Config.Destination -ChildPath '*.pdf') -Confirm:$false
do
{
    try
    {
        $response = Invoke-WebRequest -Uri $currentUrl -Credential $credential -ErrorAction Stop
    }
    catch
    {
        $_ | Out-File -FilePath '.\error.log' -Append
        exit
    }
    $content = $response.Content | ConvertFrom-Json
    if ($content.error)
    {
        $content | ConvertTo-Json | Out-File -FilePath '.\error.log' -Append
        exit
    }
    foreach ($page in $content.query.allpages)
    {
        $title = $page.title -replace ' ', '_'
        $filename = ($title -replace '\.', '_') + '.pdf'
        $args = @(
            '-q'
            '--no-background'
            '--username'
            $credential.UserName
            '--password'
            $credential.GetNetworkCredential().Password
            "$wikiUrl/index.php?title=$title"
            (Join-Path -Path $Script:Config.Destination -ChildPath $filename)
        )
        & $Script:Config.WkhtmltopdfPath $args 2>&1 > $null
    }
    if ($content.continue)
    {
        $currentUrl = "$apiUrl&apcontinue=$($content.continue.apcontinue)&continue=$($content.continue.continue)"
    }
}
while ($content.continue)
