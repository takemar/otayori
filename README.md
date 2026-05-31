# otayori

ローカルでデータを管理し、静的 Web サーバに SFTP で HTML を送り込んで公開する、という構成のブログ管理システムです。

Web コンテンツを公開するサーバとして安価で管理が容易かつ可用性が高い静的 Web サーバを利用しつつ、Web ブラウザから記事を投稿できるように、というのがモチベーションです。

https://blog.takemaro.com/ で使っています。

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
bundle exec ruby db/seeds.rb  # tags テーブルに最低 1 件のタグが必要
```

## 起動前の準備

リモートの Web サーバに以下を用意しておく：

- `posts/` ディレクトリと `tags/` ディレクトリ
- スタイルシートなどの静的アセット

`app/templates/` 内のテンプレートを必要に応じて編集する。

## 起動

```sh
bundle exec rackup
```

ブラウザで `http://localhost:9292/blog/new` を開く。

## ライセンス

特段のライセンスを適用しません。著作権法に基づき、私的使用のための複製は認められます。
