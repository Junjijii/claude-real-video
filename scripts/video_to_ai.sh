#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/video_to_ai.sh <video-file-or-authorized-url> [analysis-purpose]

Examples:
  ./scripts/video_to_ai.sh input.mp4
  ./scripts/video_to_ai.sh input.mp4 "求人動画として応募者目線で改善点を出す"
  ./scripts/video_to_ai.sh "https://www.youtube.com/watch?v=..." "自社チャンネル動画の改善点を出す"

Environment variables:
  VIDEO_AI_ROOT=video_ai_outputs   Output root directory
  VIDEO_AI_OUT=path                Exact output directory
  VIDEO_AI_OVERWRITE=1             Allow deleting VIDEO_AI_OUT if it exists
  VIDEO_AI_LANG=auto               Whisper language, e.g. ja / en / auto
  VIDEO_AI_WHISPER_MODEL=base      tiny / base / small / medium / large
  VIDEO_AI_MAX_FRAMES=120          Frame cap
  VIDEO_AI_SCENE=0.30              Scene sensitivity
  VIDEO_AI_FPS_FLOOR=1.0           Minimum frame interval
  VIDEO_AI_NO_TRANSCRIBE=1         Skip transcription
  VIDEO_AI_REPORT=1                Also create report.html and dropped/
  VIDEO_AI_KEEP_AUDIO=1            Also save audio.m4a
  VIDEO_AI_COOKIES=path            Netscape cookie file for authorized videos
  VIDEO_AI_COOKIES_FROM_BROWSER=chrome|safari|firefox|edge
  CRV_BIN=crv                     Override claude-real-video command
USAGE
}

if [[ $# -lt 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  [[ $# -lt 1 ]] && exit 1 || exit 0
fi

SOURCE=$1
shift || true
WHY=${1:-${VIDEO_AI_WHY:-"京都ビルサービスの実務用途で、内容、良い点、改善点、マニュアル化できる手順を分析する"}}

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

# If this repo has a venv, put it first so crv can also find whisper installed in it.
if [[ -x "$REPO_ROOT/.venv/bin/crv" ]]; then
  export PATH="$REPO_ROOT/.venv/bin:$PATH"
fi

CRV_BIN=${CRV_BIN:-crv}
if ! command -v "$CRV_BIN" >/dev/null 2>&1; then
  cat >&2 <<'ERROR'
error: crv was not found.

Install it first:
  python3 -m venv .venv
  source .venv/bin/activate
  python -m pip install "claude-real-video[whisper]"
ERROR
  exit 1
fi

for tool in ffmpeg ffprobe; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "error: $tool was not found. Install ffmpeg first: brew install ffmpeg" >&2
    exit 1
  fi
done

if [[ "$SOURCE" == http://* || "$SOURCE" == https://* ]]; then
  echo "notice: URL input uses yt-dlp. Use only videos you own or are authorized to process." >&2
fi

make_slug() {
  local raw=$1
  printf '%s' "$raw" |
    sed -E 's#^https?://##; s#[/?=&:%]+#-#g; s#[^A-Za-z0-9._-]+#-#g; s#^-+##; s#-+$##' |
    cut -c 1-60
}

if [[ "$SOURCE" == http://* || "$SOURCE" == https://* ]]; then
  SLUG=$(make_slug "${SOURCE%/}")
else
  BASE=$(basename "${SOURCE%/}")
  SLUG=$(make_slug "${BASE%.*}")
fi
[[ -n "$SLUG" ]] || SLUG=video

STAMP=$(date +%Y%m%d-%H%M%S)
OUT_ROOT=${VIDEO_AI_ROOT:-video_ai_outputs}
OUT_DIR=${VIDEO_AI_OUT:-"$OUT_ROOT/$STAMP-$SLUG"}

if [[ -e "$OUT_DIR" ]]; then
  if [[ "${VIDEO_AI_OVERWRITE:-0}" == "1" ]]; then
    rm -rf "$OUT_DIR"
  else
    echo "error: output directory already exists: $OUT_DIR" >&2
    echo "Set VIDEO_AI_OUT to a new path, or set VIDEO_AI_OVERWRITE=1." >&2
    exit 1
  fi
fi

mkdir -p "$(dirname "$OUT_DIR")"

LANG=${VIDEO_AI_LANG:-auto}
WHISPER_MODEL=${VIDEO_AI_WHISPER_MODEL:-base}
MAX_FRAMES=${VIDEO_AI_MAX_FRAMES:-120}
SCENE=${VIDEO_AI_SCENE:-0.30}
FPS_FLOOR=${VIDEO_AI_FPS_FLOOR:-1.0}

CRV_ARGS=(
  "$SOURCE"
  -o "$OUT_DIR"
  --viewer
  --grid
  --why "$WHY"
  --lang "$LANG"
  --whisper-model "$WHISPER_MODEL"
  --max-frames "$MAX_FRAMES"
  --scene "$SCENE"
  --fps-floor "$FPS_FLOOR"
)

if [[ "${VIDEO_AI_NO_TRANSCRIBE:-0}" == "1" ]]; then
  CRV_ARGS+=(--no-transcribe)
fi
if [[ "${VIDEO_AI_REPORT:-0}" == "1" ]]; then
  CRV_ARGS+=(--report)
fi
if [[ "${VIDEO_AI_KEEP_AUDIO:-0}" == "1" ]]; then
  CRV_ARGS+=(--keep-audio)
fi
if [[ -n "${VIDEO_AI_COOKIES:-}" ]]; then
  CRV_ARGS+=(--cookies "$VIDEO_AI_COOKIES")
fi
if [[ -n "${VIDEO_AI_COOKIES_FROM_BROWSER:-}" ]]; then
  CRV_ARGS+=(--cookies-from-browser "$VIDEO_AI_COOKIES_FROM_BROWSER")
fi

echo "Running claude-real-video..."
"$CRV_BIN" "${CRV_ARGS[@]}"

if [[ ! -f "$OUT_DIR/transcript.txt" ]]; then
  TRANSCRIPT_NOTE="transcript.txt was not generated. See MANIFEST.txt for the reason."
  if [[ -f "$OUT_DIR/MANIFEST.txt" ]]; then
    FOUND_NOTE=$(grep -E '^transcript:' "$OUT_DIR/MANIFEST.txt" | head -1 || true)
    [[ -n "$FOUND_NOTE" ]] && TRANSCRIPT_NOTE="$FOUND_NOTE"
  fi
  printf '%s\n' "$TRANSCRIPT_NOTE" > "$OUT_DIR/transcript.txt"
fi

ABS_OUT=$(cd "$OUT_DIR" && pwd)
FRAME_COUNT=$(find "$OUT_DIR/frames" -maxdepth 1 -type f -name '*.jpg' 2>/dev/null | wc -l | tr -d ' ')
GRID_COUNT=$(find "$OUT_DIR/grids" -maxdepth 1 -type f -name '*.jpg' 2>/dev/null | wc -l | tr -d ' ')

cat > "$OUT_DIR/ai_prompt.txt" <<PROMPT
あなたは京都ビルサービスの業務改善・採用・研修・営業動画の分析担当です。
以下の動画変換結果を材料に、社長や事務員がそのまま使える日本語で整理してください。

分析目的:
$WHY

入力:
- MANIFEST.txt: $ABS_OUT/MANIFEST.txt
- transcript.txt: $ABS_OUT/transcript.txt
- viewer.html: $ABS_OUT/viewer.html
- frames/: $ABS_OUT/frames/ (${FRAME_COUNT} files)
- grids/: $ABS_OUT/grids/ (${GRID_COUNT} files)

作業手順:
1. まず MANIFEST.txt と transcript.txt を読んでください。
2. 画像は grids/ を優先して見てください。細部確認が必要な場合だけ frames/ を見てください。
3. 動画から分からないことは推測で断定しないでください。
4. 顔、住所、車のナンバー、現場名など個人情報・機密情報がありそうなら指摘してください。
5. 清掃、害虫駆除、薬剤、安全、契約条件に関わる内容は、人間の確認が必要な前提で書いてください。

出力してほしいもの:
- 5行以内の動画要約
- 良い点
- 改善点: すぐ直せる / 次回撮影で直す / 方針検討が必要
- 業務に使えるチェックリスト
- 必要なら、求人文、営業台本、研修メモ、作業マニュアル案
- 最後に人間が確認すべき点を5つ以内
PROMPT

cat <<DONE

Done.
Output: $ABS_OUT

Next:
  1. Open: $ABS_OUT/viewer.html
  2. Paste: $ABS_OUT/ai_prompt.txt into ChatGPT or Claude
  3. Attach or paste MANIFEST.txt, transcript.txt, and grids/ as needed
DONE
