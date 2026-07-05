# プロジェクトステータス

<!-- このファイルは全AIツール共通の情報共有ファイルです -->
<!-- Claude Code / Codex / ChatGPT 誰が読んでも現状がわかるように書く -->
<!-- 作業のたびに更新すること -->

## 概要
HUANGCHIHHUNGLeo/claude-real-video を Mac で実務利用するための検証・手順化プロジェクト。
京都ビルサービスで動画を AI 分析、文字起こし、マニュアル化へつなげる補助資料とラッパースクリプトを追加する。

## 現在のバージョン / 状態
作業完了。上流 v0.5.2 をベースに、Mac 向け導入資料、京都ビルサービス向け業務活用資料、ラッパースクリプト、AI依頼テンプレートを追加済み。

## 協業ステータス
<!-- claudecodex:モード時にClaude Codeが自動で記入する。通常モードでは空欄のまま -->
- lead:
- executor:
- phase:
- handoff_ready: false
- next_owner:
- final_owner:
- updated_at:

## 直近の変更（最新を上に追記）
| 日付 | 変更内容 | 担当 |
|------|---------|------|
| 2026-07-06 | Mac 実測結果を反映した導入資料、業務活用資料、`video_to_ai.sh`、AI依頼テンプレートを追加 | Codex |
| 2026-07-06 | Mac 実務利用向け調査・ドキュメント・ラッパースクリプト作成を開始 | Codex |

## 次にやること
<!-- 優先度順に -->
- [x] README / pyproject / CLI 実装を確認する
- [x] Mac 環境で pip install と最小動画処理を検証する
- [x] `docs/claude-real-video-setup.md` を作成する
- [x] `docs/business-usecases.md` を作成する
- [x] `scripts/video_to_ai.sh` と `samples/ai_prompt_template.md` を作成する
- [ ] 変更を commit / push する

## 現在の問題
<!-- 行き詰まり時にここに書く。次の担当者が読む -->
- READMEには「再実行は出力ディレクトリを上書き」とあるが、現行コードは出力先を掃除しない。同じ `-o` を使い回すと古い `frames/` が混ざるため、追加資料とラッパーでは毎回新しい出力フォルダを使う前提にした。
- `pyproject.toml` は 0.5.2 だが `src/claude_real_video/__init__.py` の `__version__` は 0.4.0 のまま。
- venv を activate せず `.venv/bin/crv` だけ直指定すると、同じ venv に入れた `whisper` を CLI が PATH 上で見つけられない場合がある。ラッパーは repo の `.venv/bin` を PATH 先頭に入れる。

## 引き継ぎメモ
<!-- 協業モード時に更新。だれが次に何をするかを明記。更新後は cmux の相手ペインにも要点を送る -->
- from: Codex
- to: reviewer
- branch: codex/mac-business-video-guide
- commit: pending final commit
- summary: Mac導入手順、京都ビルサービス向け業務活用、`video_to_ai.sh`、AI依頼テンプレートを追加。権利のない動画を前提にしない注意と、実測で見つけたREADME差分も記載。
- tests: `pip install -e .`, `pip install -e ".[whisper]"`, `crv --help`, `python -m claude_real_video --help`, `compileall src`, local sample video, sidecar subtitle, Whisper tiny transcription, wrapper smoke test

## ファイル構成
<!-- 主要ファイルと役割 -->
- `README.md`: 上流の導入・利用説明
- `src/claude_real_video/`: CLI と動画処理の実装
- `docs/claude-real-video-setup.md`: Mac導入、CLI、出力構成、エラー対処、実測差分
- `docs/business-usecases.md`: 京都ビルサービス向けの求人、競合研究、現場作業、研修、営業動画の使い方
- `scripts/video_to_ai.sh`: 実務用ラッパースクリプト
- `samples/ai_prompt_template.md`: ChatGPT / Claude に貼る分析依頼テンプレート

## テスト方法
<!-- テスト実行コマンド -->
- `python3 -m venv .venv`
- `.venv/bin/python -m pip install -e ".[whisper]"`
- `.venv/bin/crv --help`
- `.venv/bin/python -m claude_real_video --help`
- `scripts/video_to_ai.sh <動画ファイルまたはURL>`
- `bash -n scripts/video_to_ai.sh`
- `.venv/bin/python -m compileall src`

## デプロイ / リリース方法
<!-- リリース手順 -->
作業ブランチをフォークへ push し、必要に応じて upstream へ Pull Request を作成する。
