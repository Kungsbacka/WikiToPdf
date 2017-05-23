$Script:Config = @{
    # Full path to wikihtmltopdf executable
    WkhtmltopdfPath = 'C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe'
    # Mediawiki base URL
    WikiUrl = 'http://mywiki/mediawiki'
    # Credentials used by Invoke-WebRequest and wkhtmltopdf to access the wiki.
    # This must not be blank. If no credentials are needed you have to modify the script.
    WikiUser = 'DOMAIN\username'
    # WikiPassword must be encrypted with the same user that is running the script.
    # Start a new PowerShell prompt as the user, run (Get-Credential).Password | ConvertFrom-SecureString
    # fill in credentials and paste the result below.
    WikiPassword = ''
}
