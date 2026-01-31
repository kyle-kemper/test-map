# ============================
# CONFIG (SET THESE FIRST)
# ============================
$AIRTABLE_TOKEN = $env:AIRTABLE_TOKEN
$BASE_ID = "appmoMytIhA7J2G1b"
$TABLE_NAME = "RaceBoard"
$OUTPUT_CSV = "races_airtable_fetched.csv"

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

                    # Flatten arrays (multi-selects, linked records)
                    if ($prop.Value -is [Array]) {
                        $row[$prop.Name] = ($prop.Value -join "; ")
                    } else {
                        $row[$prop.Name] = $prop.Value
                    }
                }
            }

            $allRecords += [PSCustomObject]$row
        }

        $offset = $response.offset

    } while ($offset)

    Write-Host "✅ Retrieved $($allRecords.Count) records"
    Write-Host ""

    # ============================
    # NORMALIZE COLUMNS
    # ============================
    $allColumns = $allRecords |
        ForEach-Object { $_.PSObject.Properties.Name } |
        Sort-Object -Unique

    $normalized = foreach ($record in $allRecords) {
        $row = [ordered]@{}
        foreach ($col in $allColumns) {
            $row[$col] = $record.$col
        }
        [PSCustomObject]$row
    }

    # ============================
    # EXPORT TO CSV
    # ============================
    $normalized | Export-Csv -Path $OUTPUT_CSV -NoTypeInformation -Encoding UTF8

    Write-Host "📄 CSV written to:"
    Write-Host (Resolve-Path $OUTPUT_CSV)

} catch {
    Write-Host "❌ FAILED"
    Write-Host $_
}
