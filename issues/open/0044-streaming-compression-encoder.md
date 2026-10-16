# 0044: RequestEncoder/ResponseEncoder に圧縮器を注入

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 追加モジュール
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現行 encode は全量一括出力のみで圧縮インターフェースがない。

## 実装方針

- with_compressor/compress_body/finish/reset の契約を実装する
- chunked wire との責務を分ける

## 完了条件

- [ ] 分割入力で正しい byte 順
- [ ] finish/reset で再利用
- [ ] NoCompression は既存 wire と一致
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0027](./0027-response-content-length-logic.md)、[0028](./0028-chunk-trailer-encoder.md)、[0043](./0043-compression-interfaces.md)

## 対象・上流参照

- MoonBit: [`src/encoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder.mbt)
- Rust: [`src/encoder.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/encoder.rs)
- Rust: [`src/compression.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/compression.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
