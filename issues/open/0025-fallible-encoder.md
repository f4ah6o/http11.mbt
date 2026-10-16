# 0025: encode_request/response を検証付き Result にする

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: エンコード・安全性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現行 encoder は method/target/header/value を無検証で CRLF 連結する。

## 実装方針

- EncodeError を定義する
- encoding 前に名前/値/version/status/target を検証する

## 完了条件

- [ ] CRLF/NUL 注入は Err
- [ ] 正常 wire snapshot と一致
- [ ] 破壊的 API 変更を記録
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0015](./0015-request-line-strict.md)、[0016](./0016-status-line-strict.md)、[0017](./0017-header-name-value-validation.md)

## 対象・上流参照

- MoonBit: [`src/encoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder.mbt)
- MoonBit: [`src/request.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/request.mbt)
- MoonBit: [`src/response.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/response.mbt)
- Rust: [`src/encoder.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/encoder.rs)
- Rust: [`src/error.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/error.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
