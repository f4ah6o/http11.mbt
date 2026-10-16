# 0052: Cookie/Set-Cookie の Max-Age・Domain・Path 境界

- Priority: P2 (Low)
- Created: 2026-10-16
- Status: open
- Area: ヘッダー互換
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

cookie モジュールはあるが上流の RFC6265bis 境界修正と未照合。

## 実装方針

- 負 Max-Age/多重 dot Domain/空 Path を比較する
- Secure/HttpOnly/SameSite を再検証

## 完了条件

- [ ] 属性順不同と quoted value を扱う
- [ ] CTL を拒否
- [ ] Rust golden と一致
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0017](./0017-header-name-value-validation.md)、[0057](./0057-common-validators.md)

## 対象・上流参照

- MoonBit: [`src/cookie_set_cookie.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/cookie_set_cookie.mbt)
- MoonBit: [`src/cookie_pair.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/cookie_pair.mbt)
- Rust: [`src/cookie.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/cookie.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
