$Script:Config = @{
    # Full path to wikihtmltopdf executable
    WkhtmltopdfPath = 'C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe'
    # Destination directory
    Destination = 'C:\Pdf'
    # Set this to $false to perform an incremental export instead of full
    AlwaysDoFullExport = $false
    # Always do a full export every n days to guarantee consistency
    DaysBetweenFullExport = 30
    # Mediawiki base URL
    WikiUrl = 'http://mywiki/mediawiki'
    # Credentials used by Invoke-WebRequest and wkhtmltopdf to access the wiki.
    # This must not be blank. If no credentials are needed you have to modify the script.
    WikiUser = 'DOMAIN\username'
    # WikiPassword must be encrypted with the same user that is running the script.
    # Start a new PowerShell prompt as the user, run (Get-Credential).Password | ConvertFrom-SecureString
    # fill in credentials and paste the result below.
    WikiPassword = ''
    # List pages by title that should be rendered in landscape mode.
    RenderInLandscapeMode = @(
        'Page title'
    )
}
