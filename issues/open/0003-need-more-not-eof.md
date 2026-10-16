# 0003: 入力断片で UnexpectedEof を返さず待機する

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

`read_crlf_line` は CRLF 到着前に `UnexpectedEof` を返し README の `Ok(None)` 契約と異なる。

## 実装方針

- start-line/header の途中状態を保持し追加 feed を受け付ける
- EOF 確定時だけ終端不足エラーを返す

## 完了条件

- [ ] `G`・`GET /`・末尾 CR では Ok(None)
- [ ] 最終 byte 到着で完全メッセージになる
- [ ] EOF 確定後は不完全入力を拒否
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0002](./0002-seed-framing-fixtures.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- Rust: [`src/decoder/request.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/request.rs)
- Rust: [`src/decoder/response.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/response.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
