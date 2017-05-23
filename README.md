# WikiToPdf

Exports all wiki pages to PDF files - one file per page. Uses [Mediawiki's API](https://www.mediawiki.org/wiki/API:Main_page) to list all pages and [wkhtmltopdf](https://wkhtmltopdf.org/) to export the individual pages to PDF.

This can be useful as a backup in a disaster recovery scenario.

## Deploy
1. Rename Config.example.ps1 to Config.ps1 and update contents to match your environment.
2. Create a folder called pdf in the working directory.
3. Schedule or run WikiToPdf directly to start exporting.
