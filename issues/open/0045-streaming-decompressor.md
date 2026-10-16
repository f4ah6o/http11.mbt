# 0045: Decoder に展開器を注入し展開後サイズを制限

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 追加モジュール
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現在 Decoder は展開器を受け取れず、展開後 byte の resource cap も無い。

## 実装方針

- with_decompressor を追加する
- consumed/produced を管理し reset を保証する
- 解凍爆弾の上限を導入する

## 完了条件

- [ ] 複数 fragment の出力が一致
- [ ] cap 超過で安全なエラー
- [ ] keep-alive で前 message の状態が残らない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0013](./0013-enforce-max-body.md)、[0030](./0030-peek-consume-progress.md)、[0043](./0043-compression-interfaces.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/limits.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/limits.mbt)
- Rust: [`src/decoder/request.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/request.rs)
- Rust: [`src/decoder/response.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/response.rs)
- Rust: [`src/compression.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/compression.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
