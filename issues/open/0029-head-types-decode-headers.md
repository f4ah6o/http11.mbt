# 0029: RequestHead/ResponseHead と decode_headers API

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: ストリーミング
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現在は body 完了時にだけ Request/Response を取得できる。

## 実装方針

- Head 型を公開し本文未受信でもメタ情報を取得する
- `(Head, BodyKind)` を返す decode_headers を実装する

## 完了条件

- [ ] ヘッダー終端時に head を返す
- [ ] full decode と同じ header を示す
- [ ] body を先読みしない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0015](./0015-request-line-strict.md)、[0016](./0016-status-line-strict.md)、[0017](./0017-header-name-value-validation.md)、[0019](./0019-bodyless-status.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/request.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/request.mbt)
- MoonBit: [`src/response.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/response.mbt)
- Rust: [`src/decoder/head.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/head.rs)
- Rust: [`src/decoder/request.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/request.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
