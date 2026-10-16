# 0064: サーバー例で keep-alive・複数要求・upload を動作させる

- Priority: P2 (Low)
- Created: 2026-10-16
- Status: open
- Area: 統合・運用
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

native server 例は1要求処理で return しており keep-alive 動作を示せない。

## 実装方針

- 接続内で順次 request を処理する
- chunked/大規模 upload を streaming で受ける

## 完了条件

- [ ] 同接続で2要求を処理
- [ ] /echo の本文一致
- [ ] 途中切断でも無限ループなし
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0004](./0004-preserve-pipelining.md)、[0005](./0005-chunked-request-body.md)、[0023](./0023-connection-token-keepalive.md)、[0030](./0030-peek-consume-progress.md)、[0063](./0063-tcp-client-server-e2e.md)

## 対象・上流参照

- MoonBit: [`src/cmd/server/main_native.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/cmd/server/main_native.mbt)
- Rust: [`examples/http11_server/src/main.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/examples/http11_server/src/main.rs)
- Rust: [`examples/http11_server/tests/http_keep_alive.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/examples/http11_server/tests/http_keep_alive.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
