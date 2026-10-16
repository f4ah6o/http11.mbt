# 0039: Request/Response の add/set/clear と get_headers を揃える

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 公開 API
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現行は header/body と単一 get_header のみで多値 header や更新操作が不足。

## 実装方針

- add_header/set_header/get_headers を追加する
- set_body/clear_body とチェイン規則を統一する

## 完了条件

- [ ] Set-Cookie 2行を保持
- [ ] set_header は同名を case-insensitive で置換
- [ ] encode に反映
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0034](./0034-typed-header-name.md)、[0038](./0038-validated-constructors.md)

## 対象・上流参照

- MoonBit: [`src/request.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/request.mbt)
- MoonBit: [`src/response.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/response.mbt)
- Rust: [`src/request.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/request.rs)
- Rust: [`src/response.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/response.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
