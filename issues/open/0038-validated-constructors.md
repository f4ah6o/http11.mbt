# 0038: Request/Response の不変条件と検証付きコンストラクター

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 公開 API
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

`pub(all)` struct と `Request::new`/`Response::new` は無効フィールドでも値を作る。

## 実装方針

- 型/フィールド公開範囲を見直す
- メソッド/ヘッダー/target/status 検証を構築時に導入する

## 完了条件

- [ ] 不正入力は Result エラー
- [ ] decoder が検証済み値を再利用
- [ ] 公開 API 変更を文書化
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0025](./0025-fallible-encoder.md)、[0033](./0033-typed-method-query.md)、[0034](./0034-typed-header-name.md)、[0035](./0035-request-target-forms.md)、[0036](./0036-status-code-type.md)、[0037](./0037-http-version-validation.md)

## 対象・上流参照

- MoonBit: [`src/request.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/request.mbt)
- MoonBit: [`src/response.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/response.mbt)
- Rust: [`src/request.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/request.rs)
- Rust: [`src/response.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/response.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
