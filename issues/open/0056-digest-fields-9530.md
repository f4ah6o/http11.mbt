# 0056: Content-/Repr-/Want-Digest の RFC9530 バイト互換

- Priority: P2 (Low)
- Created: 2026-10-16
- Status: open
- Area: ヘッダー互換
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

digest fields モジュールはあるが structured byte sequence の互換網羅がない。

## 実装方針

- digest alg・base64・重複・不正 structured value を比較する
- formatter の再解析可能性を確認

## 完了条件

- [ ] NUL/不正 base64 で panic しない
- [ ] 代表 RFC 値を roundtrip
- [ ] Rust との差分を記録
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0057](./0057-common-validators.md)

## 対象・上流参照

- MoonBit: [`src/content_digest.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/content_digest.mbt)
- MoonBit: [`src/digest_value.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/digest_value.mbt)
- MoonBit: [`src/want_digest.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/want_digest.mbt)
- Rust: [`src/digest_fields.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/digest_fields.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
