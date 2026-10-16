# 0028: chunked 終端と Trailer の送信 API

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: エンコード・安全性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

`encode_chunks` は単純な 0-chunk 終端だけを出力し trailer を作れない。

## 実装方針

- 送信 Trailer と終端 API を統一する
- empty chunk の扱いと二重終端を防止する

## 完了条件

- [ ] chunk1→chunk2→0→Trailer→空行が wire 一致
- [ ] 禁止 header を拒否
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0008](./0008-chunked-trailers.md)、[0025](./0025-fallible-encoder.md)

## 対象・上流参照

- MoonBit: [`src/encoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder.mbt)
- MoonBit: [`src/trailer.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/trailer.mbt)
- Rust: [`src/encoder.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/encoder.rs)
- Rust: [`src/trailer.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/trailer.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
