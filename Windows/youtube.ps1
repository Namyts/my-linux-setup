$YtDir = 'C:\Users\james\Videos\YouTube'
$current = (Get-Location).Path
$normalizedCurrent = [IO.Path]::GetFullPath($current)
$normalizedYt = [IO.Path]::GetFullPath($YtDir)

if (
    $normalizedCurrent -ne $normalizedYt -and
    -not $normalizedCurrent.StartsWith(
        $normalizedYt + [IO.Path]::DirectorySeparatorChar,
        [StringComparison]::OrdinalIgnoreCase
    )
) {
    Set-Location $normalizedYt
}

$ytDlpArgs = @(
    '--js-runtimes', 'node',
    '--remote-components', 'ejs:github',
    '-f', 'bestvideo[height=1440]+bestaudio/best',
    '--write-subs',
    '--sub-lang', 'en',
    '--sub-format', 'srt',
    '-o', '%(playlist_index&{} - |)s%(title)s.%(ext)s'
) + $args

& yt-dlp @ytDlpArgs
exit $LASTEXITCODE
