# 0049: QUERY method と Accept-Query（RFC 10008/9651）

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 追加モジュール
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

上流 develop は QUERY/Accept-Query に対応し MoonBit に専用モジュールはない。

## 実装方針

- structured field List の Token/String item と params を実装する
- Inner List 等は明示拒否

## 完了条件

- [ ] 有効 Accept-Query が parse/format/parse で一致
- [ ] QUERY をエンコード
- [ ] 不正 structured field を拒否
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0033](./0033-typed-method-query.md)

## 対象・上流参照

- MoonBit: [`src/accept_header.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/accept_header.mbt)
- Rust: [`src/accept_query.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/accept_query.rs)
- Rust: [`src/method.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/method.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
