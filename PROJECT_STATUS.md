# プロジェクトステータス

<!-- このファイルは全AIツール共通の情報共有ファイルです -->
<!-- Claude Code / Codex / ChatGPT 誰が読んでも現状がわかるように書く -->
<!-- 作業のたびに更新すること -->

## 概要
HUANGCHIHHUNGLeo/claude-real-video を Mac で実務利用するための検証・手順化プロジェクト。
京都ビルサービスで動画を AI 分析、文字起こし、マニュアル化へつなげる補助資料とラッパースクリプトを追加する。

## 現在のバージョン / 状態
調査・実装中。上流 v0.5.2 をベースに、Mac 向け導入資料と業務利用サンプルを作成中。

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
| 2026-07-06 | Mac 実務利用向け調査・ドキュメント・ラッパースクリプト作成を開始 | Codex |

## 次にやること
<!-- 優先度順に -->
- [ ] README / pyproject / CLI 実装を確認する
- [ ] Mac 環境で pip install と最小動画処理を検証する
- [ ] `docs/claude-real-video-setup.md` を作成する
- [ ] `docs/business-usecases.md` を作成する
- [ ] `scripts/video_to_ai.sh` と `samples/ai_prompt_template.md` を作成する
- [ ] テストと push を完了する

## 現在の問題
<!-- 行き詰まり時にここに書く。次の担当者が読む -->
なし

## 引き継ぎメモ
<!-- 協業モード時に更新。だれが次に何をするかを明記。更新後は cmux の相手ペインにも要点を送る -->
- from:
- to:
- branch:
- commit:
- summary:
- tests:

## ファイル構成
<!-- 主要ファイルと役割 -->
- `README.md`: 上流の導入・利用説明
- `src/claude_real_video/`: CLI と動画処理の実装
- `docs/`: 追加予定の Mac 導入・業務活用資料
- `scripts/`: 追加予定の実務用ラッパースクリプト
- `samples/`: 追加予定の AI 分析依頼テンプレート

## テスト方法
<!-- テスト実行コマンド -->
- `python3 -m venv .venv`
- `.venv/bin/python -m pip install -e ".[whisper]"`
- `.venv/bin/crv --help`
- `.venv/bin/python -m claude_real_video --help`
- `scripts/video_to_ai.sh <動画ファイルまたはURL>`

## デプロイ / リリース方法
<!-- リリース手順 -->
作業ブランチをフォークへ push し、必要に応じて upstream へ Pull Request を作成する。
