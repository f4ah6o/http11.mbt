# 0040: HttpHead 共通ロジックでヘッダー判定を統一

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 公開 API
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

Request/Response 間の get_header/CL/TE/is_keep_alive 等がコピー実装。

## 実装方針

- 共通 helper または trait を設計する
- RequestHead/ResponseHead も同じ挙動にする

## 完了条件

- [ ] 同じ入力を4種類の head で比較
- [ ] 重複/OWS/connection の一貫性を確認
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0009](./0009-content-length-u64.md)、[0010](./0010-duplicate-content-length.md)、[0012](./0012-transfer-encoding-list.md)、[0023](./0023-connection-token-keepalive.md)、[0029](./0029-head-types-decode-headers.md)、[0039](./0039-mutators-and-header-list.md)

## 対象・上流参照

- MoonBit: [`src/request.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/request.mbt)
- MoonBit: [`src/response.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/response.mbt)
- Rust: [`src/decoder/head.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/head.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
