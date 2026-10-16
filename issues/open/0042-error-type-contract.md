# 0042: Decode/Encode/Compression/Multipart のエラー体系

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 公開 API
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

既存 HttpError のバリエーションでは encode の意味違反や処理待ちを区別できない。

## 実装方針

- EncodeError と各 submodule error を整理する
- 大きい size/limit を overflow-safe に表現する

## 完了条件

- [ ] invalid input を panic ではなくエラーで返す
- [ ] target 間で同じ error 分類を保つ
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0003](./0003-need-more-not-eof.md)、[0009](./0009-content-length-u64.md)、[0013](./0013-enforce-max-body.md)、[0025](./0025-fallible-encoder.md)

## 対象・上流参照

- MoonBit: [`src/error.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/error.mbt)
- MoonBit: [`src/limits.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/limits.mbt)
- Rust: [`src/error.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/error.rs)
- Rust: [`src/limits.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/limits.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
