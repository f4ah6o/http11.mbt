# 0035: 4種類の request-target と Method 制約

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 公開 API
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

CONNECT authority-form や OPTIONS * の妥当性がチェックされない。

## 実装方針

- origin/absolute/authority/asterisk form を区別する
- userinfo・IPv6/port・percent escape を検証する

## 完了条件

- [ ] GET /・GET http://host/・CONNECT host:443・OPTIONS * は通る
- [ ] GET * と CONNECT / を拒否
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0015](./0015-request-line-strict.md)、[0018](./0018-host-header-authority.md)、[0033](./0033-typed-method-query.md)

## 対象・上流参照

- MoonBit: [`src/request.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/request.mbt)
- MoonBit: [`src/uri.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/uri.mbt)
- Rust: [`src/request_target.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/request_target.rs)
- Rust: [`src/decoder/head.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/head.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
