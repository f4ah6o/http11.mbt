# 0006: ResponseDecoder の chunked 本文を復元

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

`ResponseDecoder` も chunked を読まずに Complete に遷移する。

## 実装方針

- 共通 chunk 状態機械を使い response body を復元する
- 受信の分割位置と次レスポンス境界を扱う

## 完了条件

- [ ] 1 byte feed でも正しい body を取得する
- [ ] 不完全 CRLF では待機する
- [ ] 完了後の余剰 bytes は保持
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0003](./0003-need-more-not-eof.md)、[0004](./0004-preserve-pipelining.md)、[0005](./0005-chunked-request-body.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- Rust: [`src/decoder/body.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/body.rs)
- Rust: [`src/decoder/response.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/response.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
