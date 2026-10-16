# 0050: RFC3986 相対解決と URI 正規化を移植

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 追加モジュール
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

MoonBit Uri は parse/accessors/percent helpers が中心で resolve/normalize が不足。

## 実装方針

- 基底 URI と相対 URI の resolve を追加する
- dot segments と percent 表現の normalize を検証する

## 完了条件

- [ ] RFC3986 代表ケース一致
- [ ] normalize が冪等
- [ ] IPv6/query/fragment を保持
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0001](./0001-pin-upstream-parity-baseline.md)

## 対象・上流参照

- MoonBit: [`src/uri.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/uri.mbt)
- Rust: [`src/uri.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/uri.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
