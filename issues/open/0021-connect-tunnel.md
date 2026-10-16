# 0021: CONNECT 要求/2xx 応答から tunnel モードに入る

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現行 Decoder には CONNECT の tunnel と後続バイナリ byte の区別がない。

## 実装方針

- `is_tunnel`/`take_remaining` を実装する
- 2xx 応答では CL/TE を無視し head から除去する

## 完了条件

- [ ] CONNECT 200 後の任意 byte をパースしない
- [ ] CONNECT 502 は通常の本文規則
- [ ] 2xx head に CL/TE を残さない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0015](./0015-request-line-strict.md)、[0016](./0016-status-line-strict.md)、[0018](./0018-host-header-authority.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- Rust: [`src/decoder/request.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/request.rs)
- Rust: [`src/decoder/response.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/response.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
