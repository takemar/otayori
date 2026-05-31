# otayori

静的サイトジェネレータ型の個人ブログソフトウェア。ローカルで動作する管理 UI から投稿を作成し、静的 HTML を SFTP でリモートサーバへ配信する。

## スタック

- Ruby / Sinatra
- ActiveRecord / SQLite3
- Hamlit (HAML)
- Redcarpet (Markdown)
- net-sftp

## セットアップ

```sh
bundle install
cp config/environment.example.rb config/environment.rb
# config/environment.rb を編集して接続情報・ブログ設定を記入
```

SFTP 接続には `~/.ssh/config` の設定を利用する。

## DB の初期化

```sh
bundle exec rake db:migrate
bundle exec ruby db/seeds.rb
```

## 起動

```sh
bundle exec ruby app.rb
```

ブラウザで `http://localhost:4567/blog/new` を開く。
