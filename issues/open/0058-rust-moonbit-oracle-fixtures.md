# 0058: 上流 Rust から golden fixture を継続生成

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: テスト・CI
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

独立 MoonBit tests だけでは Rust の wire/semantic drift を検出できない。

## 実装方針

- 固定 upstream SHA の harness で JSON 等の期待値を生成する
- decoded headers/body/remaining/error と encoder byte を比較する

## 完了条件

- [ ] 未実装を unverified と表示
- [ ] 故意に1 byte 変えると比較 FAIL
- [ ] fixture 更新はレビュー可能
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0001](./0001-pin-upstream-parity-baseline.md)、[0002](./0002-seed-framing-fixtures.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/encoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder.mbt)
- Rust: [`tests/test_decoder/main.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/tests/test_decoder/main.rs)
- Rust: [`tests/test_encoder/main.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/tests/test_encoder/main.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
