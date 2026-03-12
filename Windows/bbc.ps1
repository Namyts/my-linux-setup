param(
    [Parameter(Mandatory=$true)]
    [string]$ApiUrl
)

Write-Host "Fetching JSON from: $ApiUrl"

# Fetch JSON from the URL
try {
    $jsonRaw = Invoke-WebRequest -Uri $ApiUrl -UseBasicParsing
} catch {
    Write-Error "Failed to fetch JSON from the URL"
    exit
}

# Parse JSON
try {
    $json = $jsonRaw.Content | ConvertFrom-Json
} catch {
    Write-Error "Failed to parse JSON"
    exit
}

# Extract the HLS (.m3u8) URL
$m3u8 = $json.media.connection |
    Where-Object { $_.transferFormat -eq "hls" } |
    Select-Object -First 1 -ExpandProperty href

# Extract the TTML subtitle URL
$ttml = $json.media.connection |
    Where-Object { $_.href -match 'subtitle' -and $_.href -like '*.xml*' } |
    Select-Object -First 1 -ExpandProperty href

if (-not $m3u8) {
    Write-Error "No HLS (.m3u8) URL found"
    exit
}

if (-not $ttml) {
    Write-Error "No TTML subtitle URL found"
    exit
}

# Try to extract PID from URL
if ($ApiUrl -match "pid:(?<pid>[^/]+)") {
    $base = $Matches.pid
} else {
    $base = "iplayer_" + (Get-Date -Format "yyyyMMdd_HHmmss")
}

$videoFile = "$base.mp4"
$ttmlFile  = "$base.ttml"

Write-Host "Downloading TTML subtitles..."
Invoke-WebRequest -Uri $ttml -OutFile $ttmlFile

Write-Host "Downloading video stream..."
yt-dlp $m3u8 -o $videoFile

Write-Host "Done!"
Write-Host "Saved:"
Write-Host " - $videoFile"
Write-Host " - $ttmlFile"
