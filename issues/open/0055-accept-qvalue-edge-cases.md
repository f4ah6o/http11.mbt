# 0055: Accept 系 qvalue・quoted list の境界値照合

- Priority: P2 (Low)
- Created: 2026-10-16
- Status: open
- Area: ヘッダー互換
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

Accept* モジュールが存在するが上流の qvalue PBT と同じ入力集合ではない。

## 実装方針

- q=0/1/1.000/1.001 を比較する
- quote 中 comma、空 list item、wildcard を検証

## 完了条件

- [ ] 不正 qvalue を丸めない
- [ ] 並び順/優先値が Rust oracle に一致
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0057](./0057-common-validators.md)

## 対象・上流参照

- MoonBit: [`src/accept_header.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/accept_header.mbt)
- MoonBit: [`src/accept_qvalue.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/accept_qvalue.mbt)
- MoonBit: [`src/accept_language.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/accept_language.mbt)
- Rust: [`src/accept.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/accept.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
