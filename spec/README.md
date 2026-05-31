# テストスイート

## テスト環境

`APP_ENV=test` で動作する。通常の起動と以下の点が異なる。

- SQLite をインメモリに切り替え（`config/database.yml` の `test` エントリ）
- HTTP Digest 認証をスキップ
- SFTP の代わりに `Filesystem::Local` を使用し `tmp/webdir_test/` に書き出す
- 各テストはトランザクションロールバックで DB 状態をリセットする
- 投稿ソースファイルは `tmp/test_source/` に書き出され、スイート終了後に削除される

実行:

```sh
bundle exec rspec
```

---

## ファイル構成

```
spec/
  support/
    test_renderer.rb      # レンダリング用テストヘルパー（後述）
  routes_spec.rb          # HTTP smoke tests
  render_body_spec.rb     # レンダリングロジックの単体に近いテスト
  migrate_erb_format_spec.rb  # データ移行のテスト
```

---

## テスト設計の方針

### HTTP テスト（routes_spec）は最小限に

`routes_spec.rb` はルート疎通とステータスコードの確認に限定する。
Sinatra のルーティングや認証スキップが機能していることを確認する程度でよく、
レンダリング結果の詳細検証はここでは行わない。

### レンダリングは直接呼び出しでテストする

`render_body_spec.rb` では `Post` レコードを作成して `post.render_body` を直接呼び出す。
HTTP を介さないため速く、レンダリングロジックだけに集中したテストが書ける。

```ruby
post = Post.create!(format: 'markdown', text: '# Hello', ...)
expect(post.render_body(TestRenderer)).to include('<h1>Hello</h1>')
```

### E2E で Sinatra との差分を補完する

`render_body_spec` は `TestRenderer`（後述）を使うため、
本番で使われる Sinatra のテンプレートエンジン設定との差異を直接は検証しない。
`routes_spec` の HTTP テストで各フォーマットのレンダリングが 200 を返すことを確認し、
差分が生じた場合に気づける程度のカバレッジを持つ。

---

## TestRenderer

`spec/support/test_renderer.rb` に定義されたモジュール。
`render_body(renderer)` の引数として渡し、Sinatra のリクエストコンテキストなしに
レンダリングをテストするために使う。

Sinatra が内部で使っている Tilt を直接呼び出し、本番と同じエンジン
（Hamlit・Redcarpet）で同じオプションを再現する。

---

## 注意事項

- `Post.create!` の `before_create` フックが `tmp/test_source/` にソースファイルを書き出す。DB ロールバックとは独立しているため、ファイルシステムの後始末は `after(:suite)` で行う
- `Tag` が 1 件以上存在しないと投稿フォーム経由のテストが `NoMethodError` になることがある（`converted_tags` が `nil.include?` を呼ぶため）。HTTP テストでは `before` ブロックでタグを作成すること
