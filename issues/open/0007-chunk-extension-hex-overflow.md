# 0007: chunk-size の16進オーバーフローと拡張構文を検証

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

chunked 用の size 行解釈が未実装で、桁あふれや quoted extension を検証できない。

## 実装方針

- サイズを checked arithmetic で解釈する
- chunk extension の合法/不正 quote を検証する

## 完了条件

- [ ] `a;foo=bar` を解釈できる
- [ ] 巨大数・不正 quote・chunk 後 CRLF 欠落を拒否する
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0005](./0005-chunked-request-body.md)、[0006](./0006-chunked-response-body.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/limits.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/limits.mbt)
- Rust: [`src/decoder/body.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/body.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
