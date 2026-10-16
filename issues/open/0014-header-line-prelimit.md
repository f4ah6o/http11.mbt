# 0014: CRLF が無い状態でも行長・件数制限を強制

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

`read_crlf_line` は CRLF 発見後にしか line size を検査しない。

## 実装方針

- 未完了 start-line/header/trailer を逐次上限検査する
- 重複名や空値もヘッダー件数に算入する

## 完了条件

- [ ] CRLF 無しの上限+1を拒否
- [ ] 個数100/101境界が機能
- [ ] 過大メモリ保持を防ぐ
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0002](./0002-seed-framing-fixtures.md)、[0003](./0003-need-more-not-eof.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/limits.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/limits.mbt)
- Rust: [`src/decoder/head.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/head.rs)
- Rust: [`src/decoder/body.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/body.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
