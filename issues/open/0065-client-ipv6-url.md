# 0065: native client の URL/IPv6/query 処理と応答境界を修正

- Priority: P2 (Low)
- Created: 2026-10-16
- Status: open
- Area: 統合・運用
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

client 例の自作 parse_url は colon/slash 単純分割で IPv6・query を正しく扱えない。

## 実装方針

- Uri parser を利用する
- HTTP/HTTPS 非対応を明示
- HEAD/close-delimited/chunked を受信する

## 完了条件

- [ ] `http://[::1]:8080/a?b=1` で正しい Host/target
- [ ] userinfo を安全に拒否
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0020](./0020-head-request-context.md)、[0021](./0021-connect-tunnel.md)、[0022](./0022-close-delimited-eof.md)、[0050](./0050-uri-resolve-normalize.md)、[0063](./0063-tcp-client-server-e2e.md)

## 対象・上流参照

- MoonBit: [`src/cmd/client/main_native.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/cmd/client/main_native.mbt)
- MoonBit: [`src/uri.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/uri.mbt)
- Rust: [`examples/http11_client/src/url.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/examples/http11_client/src/url.rs)
- Rust: [`examples/http11_client/src/main.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/examples/http11_client/src/main.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
