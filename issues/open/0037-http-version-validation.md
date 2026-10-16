# 0037: HTTP-version の比較と検証を共通化

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 公開 API
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

version は自由 String で decode/encode/keep-alive の判断が分散する。

## 実装方針

- HTTP/1.0/1.1 文法を検証する共通関数/型を作る
- RTSP 兼用時の拡張方針を明示

## 完了条件

- [ ] 不正 version を拒否
- [ ] 1.0 と 1.1 の framing が混同されない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0015](./0015-request-line-strict.md)、[0016](./0016-status-line-strict.md)、[0023](./0023-connection-token-keepalive.md)

## 対象・上流参照

- MoonBit: [`src/request.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/request.mbt)
- MoonBit: [`src/response.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/response.mbt)
- Rust: [`src/decoder/head.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/head.rs)
- Rust: [`src/encoder.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/encoder.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
