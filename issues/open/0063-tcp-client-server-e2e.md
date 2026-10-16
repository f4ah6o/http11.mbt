# 0063: native client/server と curl の実通信 E2E

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 統合・運用
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

サンプルの TCP 実通信を自動検証する E2E が不足。

## 実装方針

- GET/POST/404 と chunked/CL/Host の送受信を自動化
- process の終了・port 解放・timeout を検査する

## 完了条件

- [ ] curl→MoonBit server と MoonBit client→server 成功
- [ ] chunked upload が空にならない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0005](./0005-chunked-request-body.md)、[0006](./0006-chunked-response-body.md)、[0013](./0013-enforce-max-body.md)、[0025](./0025-fallible-encoder.md)、[0026](./0026-request-content-length-auto.md)、[0027](./0027-response-content-length-logic.md)

## 対象・上流参照

- MoonBit: [`src/cmd/server/main_native.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/cmd/server/main_native.mbt)
- MoonBit: [`src/cmd/client/main_native.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/cmd/client/main_native.mbt)
- Rust: [`examples/http11_server/tests/http_basic.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/examples/http11_server/tests/http_basic.rs)
- Rust: [`examples/http11_client/tests/nginx_basic.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/examples/http11_client/tests/nginx_basic.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
