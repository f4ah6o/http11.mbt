# 0054: filename* と Content-Disposition quoted-string の互換

- Priority: P2 (Low)
- Created: 2026-10-16
- Status: open
- Area: ヘッダー互換
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

ContentDisposition はあるが filename* の RFC8187 境界検証が十分とは限らない。

## 実装方針

- extended charset/language/percent を照合
- filename と filename* 併記時の優先順位を固定する

## 完了条件

- [ ] UTF8 ファイル名が roundtrip
- [ ] 不正 percent と CRLF 注入を拒否
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0017](./0017-header-name-value-validation.md)、[0051](./0051-unicode-percent-encode.md)、[0057](./0057-common-validators.md)

## 対象・上流参照

- MoonBit: [`src/content_disposition_header.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/content_disposition_header.mbt)
- MoonBit: [`src/content_disposition_utils.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/content_disposition_utils.mbt)
- Rust: [`src/content_disposition.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/content_disposition.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
