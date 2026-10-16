# 0015: request-line の method・target・version を厳格に検証

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

`parse_request_line` は2要素入力を HTTP/1.1 に補完し、余分な token を拒否しない。

## 実装方針

- HTTP/1.x の正しい構文と区切りを検証する
- 制御文字と不正 target/version を拒否する

## 完了条件

- [ ] 版欠落/余分な token/埋め込み CRLF を拒否
- [ ] 正常 HTTP/1.0/1.1 を通す
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0002](./0002-seed-framing-fixtures.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- Rust: [`src/decoder/head.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/head.rs)
- Rust: [`src/request_target.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/request_target.rs)
- Rust: [`src/method.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/method.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
