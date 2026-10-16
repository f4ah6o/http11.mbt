# 0060: 不正 byte corpus と roundtrip fuzz 回帰

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: テスト・CI
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

上流には多くの fuzz target があるが MoonBit には framing/encoder fuzz 経路がない。

## 実装方針

- smuggling/不正 chunk/NUL/overflow/UTF8 の corpus を作る
- panic・無限進捗・上限超過を検知する

## 完了条件

- [ ] 再現入力を記録
- [ ] CI 用の時間制限付き決定的 smoke を実行
- [ ] 異常を黙って PASS しない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0009](./0009-content-length-u64.md)、[0011](./0011-te-cl-conflict.md)、[0013](./0013-enforce-max-body.md)、[0014](./0014-header-line-prelimit.md)、[0025](./0025-fallible-encoder.md)、[0058](./0058-rust-moonbit-oracle-fixtures.md)、[0059](./0059-pbt-decoder-fragmentation.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/encoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder.mbt)
- Rust: [`fuzz/fuzz_targets/fuzz_decoder_request.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/fuzz/fuzz_targets/fuzz_decoder_request.rs)
- Rust: [`fuzz/fuzz_targets/fuzz_decoder_roundtrip.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/fuzz/fuzz_targets/fuzz_decoder_roundtrip.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
