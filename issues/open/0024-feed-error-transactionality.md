# 0024: feed 超過・parse 失敗時の Decoder 状態契約

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

バッファ上限失敗後の retry/reset と fatal parse error の扱いが未定義。

## 実装方針

- 拒否した feed を部分適用しない
- fatal error 後の再利用/停止ルールを定義する

## 完了条件

- [ ] 失敗前の未消費 byte は保たれる
- [ ] error 直後に別の message を誤生成しない
- [ ] reset で再利用可能
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0003](./0003-need-more-not-eof.md)、[0013](./0013-enforce-max-body.md)、[0014](./0014-header-line-prelimit.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- Rust: [`src/decoder/buffer.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/buffer.rs)
- Rust: [`src/error.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/error.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
