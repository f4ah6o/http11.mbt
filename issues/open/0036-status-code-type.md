# 0036: StatusCode・StatusClass と canonical phrase

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 公開 API
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

MoonBit の Response は自由 Int32 code と reason_phrase を持つ。

## 実装方針

- StatusCode::from_code と主要 IANA 定数を提供する
- StatusClass と Response::with_status を追加

## 完了条件

- [ ] 200/204/418/429/451/500 を分類
- [ ] 3桁範囲外を拒否
- [ ] canonical reason が oracle 一致
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0016](./0016-status-line-strict.md)、[0019](./0019-bodyless-status.md)

## 対象・上流参照

- MoonBit: [`src/response.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/response.mbt)
- Rust: [`src/status_code.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/status_code.rs)
- Rust: [`src/response.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/response.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
