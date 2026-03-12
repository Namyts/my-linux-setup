cd "C:\Users\james\Videos\YouTube"

yt-dlp --js-runtimes node --remote-components ejs:github -f "bestvideo[height=1440]+bestaudio/best" --write-subs --sub-lang "en" --sub-format "srt" %*

@REM yt-dlp -f "bestvideo[height=1440]+bestaudio/best" --write-subs --sub-lang "en" --sub-format "srt" %*