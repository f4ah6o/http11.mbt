# 0027: Response エンコード時の CL/TE・特殊 status 検証

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: エンコード・安全性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現行 encoder は status と body の整合性を判定しない。

## 実装方針

- 必要な CL を自動計算する
- TE+CL と 204/205/304 の不正送信を拒否する

## 完了条件

- [ ] 通常 200 の body5byte を正しく送信
- [ ] no-body 応答に本文を書かない
- [ ] HEAD 用 omit は別途検証
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0019](./0019-bodyless-status.md)、[0020](./0020-head-request-context.md)、[0025](./0025-fallible-encoder.md)

## 対象・上流参照

- MoonBit: [`src/encoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder.mbt)
- MoonBit: [`src/response.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/response.mbt)
- Rust: [`src/encoder.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/encoder.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
