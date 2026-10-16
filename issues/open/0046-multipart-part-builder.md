# 0046: multipart/form-data Part と Builder の移植

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 追加モジュール
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

Rust `multipart.rs` の Part・MultipartBuilder に対応する MoonBit モジュールが無い。

## 実装方針

- text/file Part・content type・boundary 検証を実装する
- binary-safe wire を組み立てる

## 完了条件

- [ ] text2件+file1件が正しく生成される
- [ ] 不正 boundary はエラー
- [ ] NUL/非UTF8 byte を保持
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0017](./0017-header-name-value-validation.md)

## 対象・上流参照

- MoonBit: [`src/content_disposition_header.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/content_disposition_header.mbt)
- MoonBit: [`src/content_type.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/content_type.mbt)
- Rust: [`src/multipart.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/multipart.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
