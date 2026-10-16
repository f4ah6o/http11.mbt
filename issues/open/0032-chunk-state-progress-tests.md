# 0032: chunk state machine の任意分割・ゼロ進捗を検証

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: ストリーミング
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

chunk-size/CRLF/trailer の境界で前進しないループや byte 二重消費を防ぐテストが無い。

## 実装方針

- すべての byte 分割位置でデコードを検証する
- `consume_body(0)` と progress の振る舞いを決める

## 完了条件

- [ ] 同じ入力で分割結果が変わらない
- [ ] Advanced/NeedData が無限ループしない
- [ ] trailer まで正確に消費
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0005](./0005-chunked-request-body.md)、[0006](./0006-chunked-response-body.md)、[0007](./0007-chunk-extension-hex-overflow.md)、[0008](./0008-chunked-trailers.md)、[0030](./0030-peek-consume-progress.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- Rust: [`tests/test_decoder/streaming.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/tests/test_decoder/streaming.rs)
- Rust: [`src/decoder/body.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/body.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
