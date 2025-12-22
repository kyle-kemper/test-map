# ============================
# CONFIG (SET THESE FIRST)
# ============================
$AIRTABLE_TOKEN = $env:AIRTABLE_TOKEN
$BASE_ID = "appN2ESAm2bjJ4esB"
$TABLE_NAME = "races_kylecopy"
$OUTPUT_CSV = "races_kylecopy.csv"

# ============================
# HEADERS
# ============================
$headers = @{
    Authorization = "Bearer $AIRTABLE_TOKEN"
}

Write-Host ""
Write-Host "=== Airtable Full Table Export ==="
Write-Host ""

# ============================
# ENCODE TABLE NAME
# ============================
$encodedTableName = [System.Uri]::EscapeDataString($TABLE_NAME)

# ============================
# BASE URL (SAFE CONCAT)
# ============================
$baseUrl = "https://api.airtable.com/v0/" + $BASE_ID + "/" + $encodedTableName + "?pageSize=100"

# ============================
# FETCH ALL RECORDS
# ============================
$allRecords = @()
$offset = $null

try {
    do {
        $url = $baseUrl
        if ($offset) {
            $url += "&offset=" + $offset
        }

        Write-Host "Requesting:"
        Write-Host $url
        Write-Host ""

        $response = Invoke-RestMethod -Uri $url -Headers $headers

        foreach ($record in $response.records) {

            $row = [ordered]@{
                AirtableRecordId = $record.id
            }

            if ($record.fields) {
                foreach ($prop in $record.fields.PSObject.Properties) {
                    $row[$prop.Name] = $prop.Value
                }
            }

            $allRecords += [PSCustomObject]$row
        }

        $offset = $response.offset

    } while ($offset)

    Write-Host "✅ Retrieved $($allRecords.Count) records"
    Write-Host ""

    # ============================
    # EXPORT TO CSV
    # ============================
    $allRecords | Export-Csv -Path $OUTPUT_CSV -NoTypeInformation -Encoding UTF8

    Write-Host "📄 CSV written to:"
    Write-Host (Resolve-Path $OUTPUT_CSV)

} catch {
    Write-Host "❌ FAILED"
    Write-Host $_
}
