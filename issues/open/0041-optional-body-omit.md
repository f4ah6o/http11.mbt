# 0041: 空本文・本文なし・送信抑止フラグの区別

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 公開 API
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

MoonBit は body が常に Array で Rust の optional body と omit_body の区別がない。

## 実装方針

- no body と empty body の意味を設計する
- HEAD 用 omit と Content-Length 宣言を両立する

## 完了条件

- [ ] 空 byte と absent の wire 差を test
- [ ] HEAD は宣言長を維持して body を送らない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0019](./0019-bodyless-status.md)、[0020](./0020-head-request-context.md)、[0026](./0026-request-content-length-auto.md)、[0027](./0027-response-content-length-logic.md)、[0038](./0038-validated-constructors.md)

## 対象・上流参照

- MoonBit: [`src/request.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/request.mbt)
- MoonBit: [`src/response.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/response.mbt)
- MoonBit: [`src/encoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder.mbt)
- Rust: [`src/request.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/request.rs)
- Rust: [`src/response.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/response.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
