# 0068: README・サンプル・バージョニングを実装実態へ揃える

- Priority: P2 (Low)
- Created: 2026-10-16
- Status: open
- Area: 統合・運用
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

README の chunked/HTTP1.1 対応記載と現行 decoder の未完成箇所が一致しない。

## 実装方針

- partial/missing/verified を表にする
- `moon.mod` と上流基準 SHA/公開契約の更新方法を書く

## 完了条件

- [ ] README 例の compile が通る
- [ ] 未対応を準拠済みと書かない
- [ ] compatibility breaking を changelog 化する
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0001](./0001-pin-upstream-parity-baseline.md)、[0061](./0061-ci-rust-oracle-gate.md)、[0062](./0062-cross-target-conformance.md)

## 対象・上流参照

- MoonBit: [`README.md`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/README.md)
- MoonBit: [`README.mbt.md`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/README.mbt.md)
- MoonBit: [`moon.mod`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/moon.mod)
- Rust: [`README.md`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/README.md)
- Rust: [`CHANGES.md`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/CHANGES.md)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
