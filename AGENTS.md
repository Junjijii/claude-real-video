# Codex ガイド

## プロジェクト状態
- 作業開始前に `PROJECT_STATUS.md` を必ず読むこと
- 作業開始前に GitHub の Issue・PR も確認すること
- GitHub リモートが未設定、またはユーザーがローカル協業を明示した場合は、GitHub Issue・PR・push は必須扱いにしない。代わりに `PROJECT_STATUS.md` とローカル git 差分を共有元にする
- 作業完了時に `PROJECT_STATUS.md` を更新すること

## AGENTS / CLAUDE 指示同期ルール
- ユーザーは Codex と Claude Code を常に併用する前提。片方だけに永続指示が残る状態を作らないこと
- `AGENTS.md` に運用ルール、安全ルール、GitHub運用、ツール設定、協業手順などの永続指示を追加・変更したら、同じターンで `CLAUDE.md` にも同等内容を反映する
- `CLAUDE.md` 側に同種の永続指示が追加・変更されているのを見つけた場合も、`AGENTS.md` へ同等内容を反映する
- 片方だけに残す必要がある純粋な実装者固有ルールの場合は、なぜ同期しないかを `PROJECT_STATUS.md` に記録する
- 同期したら `PROJECT_STATUS.md` に、どの指示をどちらのファイルへ反映したかを残す

## 共有テーブル (`~/.claude/shared/table.md`)
- **作業開始時**: `Now Working` セクションに自分のタスクを記入
- **重要な変更時**: `Notes` に共有メモを書く（型変更、API変更、ファイル追加など）
- **困った時**: `Requests` に質問や依頼を書く
- **作業完了時**: `Now Working` から消して `Recent Completed` に移す
- **作業前に確認**: `Requests` に自分宛の依頼がないかチェック

## コミットルール
- コミットメッセージの末尾に `Co-Authored-By: OpenAI Codex <noreply@openai.com>` を付与
- 何を変更したか・なぜ変更したかを明記

## PDF出力ルール
- PDFを出力する際は日本語フォント（Noto Serif CJK JP / Noto Sans CJK JP等）を使用する
- 中国語フォント（CJK sc系）へのフォールバックは禁止
- 出力後は `pdffonts` コマンドで使用フォントを検証し、意図した日本語フォントになっているか確認する

## GitHub道具箱運用
- このリポジトリは業務資料置き場ではなく、スクリプト・アプリ・設定・運用メモを管理する道具箱として扱う
- GitHubはprivate repo前提。public repo化、初回remote追加、初回pushはユーザーの明示確認後に行う
- 見積書、請求書、保証書、FAX、契約書、スキャン原本、顧客名簿、OneDrive/Downloads由来の業務資料はGitHubへ入れない
- `output/`, `tmp/`, `.next/`, `node_modules/`, `.env`, 秘密鍵、APIキー、トークン、PDF/Word/Excel/画像/ZIPは原則Git管理しない
- GitHubへpushする前に `scripts/check_git_safe_to_push.sh` があれば必ず実行し、危険ファイルが混ざっていないことを確認する
- 例外的にテンプレートファイルをGit管理する場合は、顧客情報・住所・電話番号・金額・個人名が入っていないことを確認し、`PROJECT_STATUS.md` に理由を残す

## ScanSnap 全自動リネーム運用
- ScanSnap Home が `/Users/takemoto/Downloads` に保存したScanSnap由来PDFは、LaunchAgentで検知し、ローカルOCR後にDownloads内で自動リネームまで完了させる
- ファイル名は `YYYY-MM-DD_相手先または現場名_文書種別または用件.pdf` を基本にする
- OCR信頼度が低い場合も手動待ちにはせず、本文断片を避けた保守名へ自動で落とす。最低限は `YYYY-MM-DD_ScanSnap書類_内容確認.pdf` とする
- 保証書・報告書・見積依頼など本文から文書種別が拾える場合は、低信頼でも可能な限り `佐藤かな様邸_シロアリ防除施工保証書` のような内容名へ寄せる
- `scansnap-review-rename` スキルと補助スクリプト `/Users/takemoto/.codex/skills/scansnap-review-rename/scripts/inspect_scansnap_review.py` は、あとから名前確認・再調整したい時の診断用として使う
- LaunchAgent側はChatGPT/Codex/Claude Codeを自動起動しない。常時AI常駐ではなく、macOSイベントでローカルOCR処理だけ短時間起動する

## 行き詰まり時
- 同じエラーに対して2回修正を試みて解決しない場合:
  1. `~/.claude/shared/table.md` の `Requests` に問題を書く
  2. `PROJECT_STATUS.md` の「現在の問題」セクションに状況を記録
  3. 試したこと・エラー内容を具体的に書く
  4. PRコメントに「Claude Codeへの引き継ぎを推奨」と記載

## テスト
- 変更後は必ず既存テストを実行すること
- テストが存在する場合、全テストがパスすることを確認
