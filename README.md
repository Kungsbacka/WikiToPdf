# WikiToPdf

Exports all wiki pages to PDF files - one file per page. Uses [Mediawiki's API](https://www.mediawiki.org/wiki/API:Main_page) to list all pages and [wkhtmltopdf](https://wkhtmltopdf.org/) to export the individual pages to PDF.

We don't use [namespaces](https://www.mediawiki.org/wiki/Manual:Namespace) in our wiki so only the main namespace (0) gets exported.

Rename Config.example.ps1 to Config.ps1 and update contents to match your environment.
