# 0023: Connection token と HTTP/1.0 keep-alive の判定

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

`is_keep_alive` は header 全体の単純一致で `upgrade, close` を誤認する。

## 実装方針

- カンマ区切り複数行と OWS を解釈する
- HTTP/1.0 と 1.1 のデフォルトを区別する

## 完了条件

- [ ] `keep-alive, close` では close を選ぶ
- [ ] 大小文字/複数行に依存しない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0017](./0017-header-name-value-validation.md)

## 対象・上流参照

- MoonBit: [`src/request.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/request.mbt)
- MoonBit: [`src/response.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/response.mbt)
- Rust: [`src/decoder/head.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/head.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
