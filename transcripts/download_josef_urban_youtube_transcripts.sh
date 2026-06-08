#!/usr/bin/env bash
set -euo pipefail

# Download subtitles/transcripts for Josef Urban research talks.
# Requires: yt-dlp
#
# Usage:
#   chmod +x download_josef_urban_youtube_transcripts.sh
#   ./download_josef_urban_youtube_transcripts.sh
#
# Optional:
#   OUTDIR=urban_youtube_transcripts ./download_josef_urban_youtube_transcripts.sh
#   LANGS="en,en-US,en-GB" ./download_josef_urban_youtube_transcripts.sh
#
# Notes:
# - This downloads subtitles only, not video/audio.
# - It tries both manually provided subtitles and auto-generated subtitles.
# - Output formats requested: vtt, srt, json3 where available.
# - Some videos may have no transcript/subtitles, or YouTube may temporarily block access.
# - Review failed_urls.txt after running.

OUTDIR="${OUTDIR:-josef_urban_youtube_transcripts}"
LANGS="${LANGS:-en,en-US,en-GB}"
ARCHIVE="$OUTDIR/download_archive.txt"
FAILED="$OUTDIR/failed_urls.txt"
URLS_FILE="$OUTDIR/urls.txt"

mkdir -p "$OUTDIR"
: > "$FAILED"

cat > "$URLS_FILE" <<'EOF'
https://www.youtube.com/watch?v=BmQCErUA72A
https://www.youtube.com/watch?v=Z-dJTETVLyQ
https://www.youtube.com/watch?v=ZWh7Rc3C0fM
https://www.youtube.com/watch?v=M0fVmNZBIrg
https://www.youtube.com/watch?v=4JeezEGc_gQ
https://www.youtube.com/watch?v=0y6TS4fqNNM
https://www.youtube.com/watch?v=jHpcuxiSAzg
https://www.youtube.com/watch?v=xF6OSrd8QpU
https://www.youtube.com/watch?v=vs2QPdpPLwc
https://www.youtube.com/watch?v=q5WxDpXwDq4
https://www.youtube.com/watch?v=UnYrWuOzOlc
https://www.youtube.com/watch?v=EKjZPlAwOBg
https://www.youtube.com/watch?v=YRoFYv35bGY
https://www.youtube.com/watch?v=kYXu5NPaddI
EOF

echo "Downloading transcript/subtitle files into: $OUTDIR"
echo "Languages: $LANGS"
echo

while IFS= read -r url; do
  [[ -z "$url" || "$url" =~ ^# ]] && continue

  echo "==> $url"

  if ! yt-dlp \
      --skip-download \
      --write-subs \
      --write-auto-subs \
      --sub-langs "$LANGS" \
      --sub-format "vtt/srt/json3/best" \
      --convert-subs srt \
      --restrict-filenames \
      --windows-filenames \
      --no-overwrites \
      --download-archive "$ARCHIVE" \
      -o "$OUTDIR/%(upload_date>%Y-%m-%d,release_date>%Y-%m-%d,epoch-0>%Y-%m-%d)s - %(title).180B [%(id)s].%(ext)s" \
      "$url"; then
    echo "$url" >> "$FAILED"
    echo "FAILED: $url" >&2
  fi

  echo
done < "$URLS_FILE"

echo "Done."
echo "URL list:       $URLS_FILE"
echo "Archive file:   $ARCHIVE"
echo "Failures file:  $FAILED"
echo
echo "Downloaded files:"
find "$OUTDIR" -type f \( -iname '*.srt' -o -iname '*.vtt' -o -iname '*.json3' \) | sort
