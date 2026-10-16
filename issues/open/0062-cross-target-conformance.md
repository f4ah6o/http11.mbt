# 0062: native/js/wasm-gc 間で同じ fixture を比較

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: テスト・CI
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

CI に各 target はあるが framing/error 分類の相互比較までは保証されない。

## 実装方針

- 同一 fixture の結果を照合する
- Byte/Char/大きな整数の差を明示する

## 完了条件

- [ ] 3 target で結果一致
- [ ] unsupported/未実行を PASS としない
- [ ] `.mbti` gate 維持
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0009](./0009-content-length-u64.md)、[0013](./0013-enforce-max-body.md)、[0058](./0058-rust-moonbit-oracle-fixtures.md)

## 対象・上流参照

- MoonBit: [`.github/workflows/ci.yml`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/.github/workflows/ci.yml)
- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- Rust: [`tests/test_decoder/main.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/tests/test_decoder/main.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
