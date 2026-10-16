# 0048: multipart delimiter・padding・buffer 上限の防御

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 追加モジュール
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

上流では部分 boundary・delimiter transport padding 等の問題が修正されている。

## 実装方針

- 未消費 byte 基準のメモリ上限を設ける
- 偽 boundary、quote、padding を回帰テスト

## 完了条件

- [ ] buffer cap を分割入力で回避しない
- [ ] 異常 delimiter を Part と認めない
- [ ] binary body は保存
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0046](./0046-multipart-part-builder.md)、[0047](./0047-multipart-streaming-parser.md)

## 対象・上流参照

- MoonBit: [`src/limits.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/limits.mbt)
- Rust: [`src/multipart.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/multipart.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
