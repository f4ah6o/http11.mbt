# 0019: 1xx/204/304/205 の本文フレーミングを修正

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現行 ResponseDecoder/encoder は status を見ず CL/TE に従って本文を処理する。

## 実装方針

- 1xx/204/304 の no-body 規則と 205 の符号化制約を移植する
- 次レスポンスの先頭を守る

## 完了条件

- [ ] 204 に CL があっても後続を飲まない
- [ ] 205 の不正 body を拒否
- [ ] 200 では通常 CL を処理
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0009](./0009-content-length-u64.md)、[0016](./0016-status-line-strict.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/encoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder.mbt)
- Rust: [`src/decoder/response.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/response.rs)
- Rust: [`src/encoder.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/encoder.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
