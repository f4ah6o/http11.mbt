# 0061: CI へ固定 Rust oracle 互換ゲートを導入

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: テスト・CI
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現行 CI は MoonBit の check/test/build を行うが Rust 実装との差分ゲートはない。

## 実装方針

- 固定 SHA と fixture checksum を CI に埋め込む
- 差分・未検証・拒否をログ/成果物として出す

## 完了条件

- [ ] 差分増加で FAIL
- [ ] oracle 未取得で green にならない
- [ ] upstream は明示 PR でのみ更新
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0001](./0001-pin-upstream-parity-baseline.md)、[0058](./0058-rust-moonbit-oracle-fixtures.md)

## 対象・上流参照

- MoonBit: [`.github/workflows/ci.yml`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/.github/workflows/ci.yml)
- Rust: [`src/lib.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/lib.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
