# 0053: DigestAuth username*・quoted-pair・パラメーター上限

- Priority: P2 (Low)
- Created: 2026-10-16
- Status: open
- Area: ヘッダー互換
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

DigestAuth の実装はあるが Rust の username* と param-bomb 回帰に未追随。

## 実装方針

- charset/username* を検証する
- quoted-pair と CTL、同名パラメーターを検査する

## 完了条件

- [ ] 有効拡張名を解釈
- [ ] 不正 quote と過大 param を拒否
- [ ] Basic/Bearer 正常系を維持
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0017](./0017-header-name-value-validation.md)、[0057](./0057-common-validators.md)

## 対象・上流参照

- MoonBit: [`src/auth_digest.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/auth_digest.mbt)
- MoonBit: [`src/auth_utils.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/auth_utils.mbt)
- Rust: [`src/auth.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/auth.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
