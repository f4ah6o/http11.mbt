# 0047: incremental MultipartParser を追加

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 追加モジュール
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現在 multipart の feed/next_part に相当する処理が無い。

## 実装方針

- boundary 断片・header/body・終端を状態機械化する
- 消費済み buffer を排出する

## 完了条件

- [ ] 1byte feed でも Part 順序/byte が一致
- [ ] preamble/epilogue を誤検出しない
- [ ] 最終境界で finished
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0014](./0014-header-line-prelimit.md)、[0046](./0046-multipart-part-builder.md)

## 対象・上流参照

- MoonBit: [`src/content_disposition_header.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/content_disposition_header.mbt)
- Rust: [`src/multipart.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/multipart.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
