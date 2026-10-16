# 0017: ヘッダー名/値の検証と CRLF 注入対策

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

`parse_header_line` は name 非空のみ確認し token・colon 前空白・CTL を見ない。

## 実装方針

- tchar/OWS/obs-fold/CTL の規則を統一する
- decoder と encoder に同じ byte 検証を適用する

## 完了条件

- [ ] `Host : x`/NUL/先頭空白を拒否
- [ ] 許可される obs-text を保持
- [ ] 重複 Set-Cookie を壊さない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0002](./0002-seed-framing-fixtures.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/encoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder.mbt)
- Rust: [`src/header_name.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/header_name.rs)
- Rust: [`src/validate.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/validate.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
