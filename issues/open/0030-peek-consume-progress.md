# 0030: peek_body / consume_body / progress のストリーミング実装

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: ストリーミング
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現行 `decode` は本文全量蓄積のみで定数メモリで読めない。

## 実装方針

- BodyProgress を導入する
- CL/chunked/close-delimited を incremental に読み出す

## 完了条件

- [ ] どの分割でも byte が欠落しない
- [ ] NeedData で前進停止
- [ ] 大容量本文を全量メモリ保持せず処理
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0005](./0005-chunked-request-body.md)、[0006](./0006-chunked-response-body.md)、[0008](./0008-chunked-trailers.md)、[0013](./0013-enforce-max-body.md)、[0021](./0021-connect-tunnel.md)、[0022](./0022-close-delimited-eof.md)、[0029](./0029-head-types-decode-headers.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- Rust: [`src/decoder/body.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/body.rs)
- Rust: [`src/decoder/phase.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/phase.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
