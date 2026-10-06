param(
    [string]$Source = (Join-Path $PSScriptRoot 'report.html'),
    [string]$Docx = (Join-Path $PSScriptRoot 'EC8206_Project_Report.docx'),
    [string]$Pdf = (Join-Path $PSScriptRoot 'EC8206_Project_Report.pdf')
)

$sourcePath = (Resolve-Path -LiteralPath $Source).Path
$docxPath = [System.IO.Path]::GetFullPath($Docx)
$pdfPath = [System.IO.Path]::GetFullPath($Pdf)
$word = $null
$document = $null

try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $document = $word.Documents.Open($sourcePath, $false, $true)

    # wdFormatXMLDocument = 12; wdExportFormatPDF = 17
    $document.SaveAs2($docxPath, 12)
    $document.ExportAsFixedFormat($pdfPath, 17)
}
finally {
    if ($document) {
        $document.Close($false)
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($document)
    }
    if ($word) {
        $word.Quit()
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($word)
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}

Write-Output "Created: $docxPath"
Write-Output "Created: $pdfPath"
