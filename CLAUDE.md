# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

このリポジトリはGitHub Pagesでホストされる個人サイトです。Scrapboxの日記フィードから`#日記`タグ付きエントリを抽出し、RSS 2.0フィードとして配信します。

## アーキテクチャ

### コア処理の流れ

1. **ScrapboxDiaryFeed** (`lib/scrapbox_diary_feed.rb`)
   - Scrapbox APIからRSSフィードを取得
   - `#日記`タグ、`(WIP)`なしの条件でフィルタリング
   - 本文から`#YYYY-MM-DD`タグを抽出して日付を特定
   - 過去30日以内の日記のみを抽出（`#YYYY-MM-DD`タグ基準）
   - `#YYYY-MM-DD`タグの日付で降順ソート（新しい順）
   - `pubDate`を日記の日付（`#YYYY-MM-DD`）に設定（RSS仕様との整合性のため）
   - フィルタリング後のアイテムリストを提供

2. **DiaryFeedGenerator** (`lib/diary_feed_generator.rb`)
   - ScrapboxDiaryFeedから取得したアイテムをRSS 2.0形式に変換
   - プロジェクト名は`'kenchan'`にハードコード済み

3. **実行スクリプト** (`bin/generate_diary_feed`)
   - DiaryFeedGeneratorを実行し、標準出力にRSSを出力

### デプロイメント

- GitHub Actions (`/.github/workflows/static.yml`) で自動デプロイ
- トリガー: mainブランチへのpush、毎日JST 5:00（UTC 20:00）、手動実行
- Ruby 3.2.2を使用
- `bin/generate_diary_feed > dist/diary.rss` で生成したRSSをGitHub Pagesへデプロイ

## 開発コマンド

### フィードの生成

```bash
bin/generate_diary_feed
```

標準出力にRSS 2.0フォーマットのXMLを出力します。

### ローカルテスト

```bash
# RSSフィードを生成してファイルに保存
mkdir -p dist
bin/generate_diary_feed > dist/diary.rss

# 生成されたRSSの確認
cat dist/diary.rss
```

## 技術スタック

- Ruby 3.2.2
- 標準ライブラリの`rss`、`net/http`、`uri`のみを使用（外部gemなし）
- GitHub Actions for CI/CD
- GitHub Pages for hosting
