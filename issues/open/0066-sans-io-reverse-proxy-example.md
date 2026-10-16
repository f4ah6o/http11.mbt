# 0066: reverse proxy の Sans I/O 実例を追加

- Priority: P2 (Low)
- Created: 2026-10-16
- Status: open
- Area: 統合・運用
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

MoonBit サンプルに上流相当の reverse proxy がない。

## 実装方針

- hop-by-hop headers と Host を適切に書き換える
- chunked/EOF/CONNECT を透過中継する

## 完了条件

- [ ] 複数応答を正しく中継
- [ ] tunnel data を HTTP 解釈しない
- [ ] TE+CL を中継しない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0011](./0011-te-cl-conflict.md)、[0018](./0018-host-header-authority.md)、[0021](./0021-connect-tunnel.md)、[0022](./0022-close-delimited-eof.md)、[0023](./0023-connection-token-keepalive.md)、[0030](./0030-peek-consume-progress.md)、[0063](./0063-tcp-client-server-e2e.md)

## 対象・上流参照

- MoonBit: [`src/cmd/server/main_native.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/cmd/server/main_native.mbt)
- Rust: [`examples/http11_reverse_proxy/src/main.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/examples/http11_reverse_proxy/src/main.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
