# 0057: OWS/tchar/quoted-string の共有バリデーター

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: ヘッダー互換
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

header/auth/content-disposition/decoder に独自文字判定が散在している。

## 実装方針

- 共通 byte validator を導入する
- obs-text と CTL の許容範囲を統一する

## 完了条件

- [ ] 同じ不正 byte を module ごとに別判定しない
- [ ] 公開 API 差分を確認
- [ ] 有効な obs-text を破壊しない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0017](./0017-header-name-value-validation.md)、[0034](./0034-typed-header-name.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/auth_utils.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/auth_utils.mbt)
- MoonBit: [`src/content_disposition_utils.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/content_disposition_utils.mbt)
- Rust: [`src/validate.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/validate.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
