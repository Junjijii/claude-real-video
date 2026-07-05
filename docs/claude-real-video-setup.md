# claude-real-video Mac導入・検証メモ

対象リポジトリ: https://github.com/HUANGCHIHHUNGLeo/claude-real-video

`claude-real-video` は、動画から重要フレームを抜き出し、音声を文字起こしして、ChatGPT / Claude / Gemini へ渡しやすいフォルダを作る Python CLI です。動画そのものをAIへ丸ごと投げるのではなく、`frames/` と `transcript.txt` と `MANIFEST.txt` を作る道具です。

## 検証した環境

- macOS 26.5.1
- Apple Silicon Mac (`arm64`)
- Python 3.14.3 (`/opt/homebrew/bin/python3`)
- Homebrew 6.0.5
- ffmpeg 8.1 / ffprobe 8.1
- claude-real-video 0.5.2
- openai-whisper 20250625
- torch 2.12.1 arm64 wheel

この環境では、core install、`[whisper]` extra、ローカル動画、字幕優先、Whisper文字起こし、`--viewer`、`--grid`、`--report` の動作を確認済みです。

## 先に入れるもの

```bash
brew install ffmpeg
ffmpeg -version
ffprobe -version
```

Python は 3.10 以上が必要です。今回の検証では Python 3.14.3 でも動きました。もし Whisper / torch 周りで失敗する場合は、安定版の Python 3.12 で venv を作り直すのが現実的です。

## インストール

通常利用では venv を作って、その中に入れるのが安全です。

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install "claude-real-video[whisper]"
```

このリポジトリを編集・検証する場合は、clone したディレクトリで次を使います。

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e ".[whisper]"
```

確認:

```bash
crv --help
python -m claude_real_video --help
whisper --help
```

重要: `.venv/bin/crv` を直接実行するだけだと、同じ venv に入れた `whisper` を CLI が見つけない場合があります。必ず `source .venv/bin/activate` するか、`PATH="$PWD/.venv/bin:$PATH" crv ...` のように venv の `bin` を PATH に入れてください。

## 基本コマンド

ローカル動画:

```bash
crv input.mp4 -o out/input-analysis --viewer --grid --lang auto --why "求人動画として、応募したくなる要素と改善点を確認する"
```

日本語音声を明示したい場合:

```bash
crv input.mp4 -o out/input-analysis --viewer --grid --lang ja --whisper-model small
```

文字起こし不要でフレームだけ欲しい場合:

```bash
crv input.mp4 -o out/frames-only --no-transcribe --viewer --grid
```

YouTube / Instagram / TikTok などのURL:

```bash
crv "https://www.youtube.com/watch?v=..." -o out/url-analysis --viewer --grid --why "競合の動画構成を研究する"
```

ログインが必要な、自分が権限を持つ動画:

```bash
crv "https://..." -o out/private-analysis --viewer --grid --cookies cookies.txt
crv "https://..." -o out/private-analysis --viewer --grid --cookies-from-browser chrome
```

権利のない動画、利用規約上ダウンロードできない動画、他社の非公開動画は対象にしないでください。URL指定は `yt-dlp` を使うため、サイト側の仕様変更やログイン状態で失敗することがあります。

## よく使うオプション

| オプション | 用途 |
|---|---|
| `-o, --out` | 出力フォルダ |
| `--viewer` | `viewer.html` を作る。動画、フレーム、文字起こしをブラウザで確認できる |
| `--grid` | `grids/` に3x3の連続フレーム画像を作る。AIへ渡す画像数を減らしやすい |
| `--why` | 分析目的を `MANIFEST.txt` に入れる |
| `--lang ja` | Whisperに日本語として文字起こしさせる |
| `--whisper-model tiny/base/small/medium/large` | 文字起こしモデル。大きいほど遅く重いが精度が上がりやすい |
| `--max-frames 80` | 長い動画で画像数を抑える |
| `--scene 0.20` | 低いほどフレームが増えやすい |
| `--fps-floor 2.0` | 最低でも2秒に1枚は拾う |
| `--report` | `report.html` と `dropped/` を作り、フレーム採用・除外の判断を確認する |
| `--keep-audio` | `audio.m4a` を残す。音声対応AIへ渡す場合に使う |
| `--kb DIR` | `MANIFEST.txt` を日付付きMarkdownとして保存する |

## 出力ファイル構成

通常:

```text
out/
  source.mp4
  frames/
    frame_001.jpg
    frame_002.jpg
  transcript.txt
  MANIFEST.txt
```

オプションを付けた場合:

```text
out/
  viewer.html        # --viewer
  grids/
    grid_01.jpg      # --grid
  report.html        # --report
  dropped/           # --report
  audio.m4a          # --keep-audio
```

実測では、`MANIFEST.txt` には source、duration、フレーム数、frames dir、transcript情報、`--why` の目的、 transcript本文が入ります。現行コードでは各フレームのタイムスタンプ一覧は出ません。

## Whisperの扱い

処理順は次の通りです。

1. ローカル動画の横に同名 `.srt` / `.vtt` があれば、それを `transcript.txt` に変換する。
2. 動画内に字幕トラックがあれば、それを使う。
3. 字幕がなく、`whisper` CLI が PATH 上にあれば、音声を抽出して Whisper で文字起こしする。
4. `whisper` がない、または音声トラックがない場合は、`MANIFEST.txt` に理由を書いて終わる。

Apple Silicon Macでは、初回に Whisperモデルと torch が入るため時間と容量を使います。まずは `--whisper-model base`、急ぎなら `tiny`、精度重視なら `small` 以上が現実的です。

## READMEと実挙動の差分

- `pyproject.toml` は 0.5.2 ですが、`src/claude_real_video/__init__.py` の `__version__` は 0.4.0 のままです。
- READMEのオプション表には `--viewer`、`--whisper-model`、`--cookies-from-browser`、`--grid` が載っていませんが、CLIには実装されています。
- READMEには「再実行は出力ディレクトリを上書き」とありますが、現行コードは出力フォルダを掃除しません。同じ `-o` を使い回すと古い `frames/` が混ざることがあります。毎回新しい出力フォルダを使ってください。
- Claude Code skill の説明には「Manifestに各フレームのタイムスタンプがある」と読める記載がありますが、現行の `MANIFEST.txt` にはフレーム別タイムスタンプは出ません。

## よくあるエラーと対処法

### `crv: command not found`

venv を有効化します。

```bash
source .venv/bin/activate
crv --help
```

### `ffmpeg` / `ffprobe` がない

```bash
brew install ffmpeg
```

### Whisperを入れたのに文字起こしされない

`crv` が `whisper` を PATH で探すため、venv を activate してください。

```bash
source .venv/bin/activate
which whisper
crv input.mp4 -o out/test --lang ja
```

### URLのダウンロードに失敗する

- 自分が権限を持つ動画か確認する。
- サイト側でダウンロードが禁止・制限されていないか確認する。
- 自分のログインが必要な場合だけ `--cookies` または `--cookies-from-browser` を使う。
- 権利のない動画を保存する前提にしない。

### 出力フレーム数がおかしい

同じ `-o` 出力先を使い回した可能性があります。新しいフォルダを指定してください。

```bash
crv input.mp4 -o out/$(date +%Y%m%d-%H%M%S)-input --viewer --grid
```

このリポジトリに追加した `scripts/video_to_ai.sh` は、毎回ユニークな出力フォルダを作るため、この問題を避けられます。
