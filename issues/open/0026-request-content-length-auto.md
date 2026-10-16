# 0026: Request エンコード時の Content-Length 自動設定と整合性

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: エンコード・安全性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

`encode_request` は body を繋ぐだけで宣言された長さと bytes を照合しない。

## 実装方針

- 明示 CL/TE と本文を検証する
- 必要な場合だけ Content-Length を自動付与する

## 完了条件

- [ ] POST 5byte→CL:5
- [ ] 明示 CL 不一致を Err
- [ ] CL と TE 競合を許可しない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0009](./0009-content-length-u64.md)、[0011](./0011-te-cl-conflict.md)、[0025](./0025-fallible-encoder.md)

## 対象・上流参照

- MoonBit: [`src/encoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder.mbt)
- MoonBit: [`src/request.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/request.mbt)
- Rust: [`src/encoder.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/encoder.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
