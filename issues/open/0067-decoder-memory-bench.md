# 0067: Decoder コピー量・CPU・メモリのベンチマーク

- Priority: P2 (Low)
- Created: 2026-10-16
- Status: open
- Area: 統合・運用
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

Array append/split と String 連結で大量入力時に O(n²) の疑いがある。

## 実装方針

- 1B/1KiB/64KiB feed と 100 headers/10MiB body を測定
- native/js で peak memory を記録する

## 完了条件

- [ ] 条件/コマンド再現可能
- [ ] 改善前後の数字を提示
- [ ] 上限解除で速く見せない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0014](./0014-header-line-prelimit.md)、[0024](./0024-feed-error-transactionality.md)、[0030](./0030-peek-consume-progress.md)、[0031](./0031-direct-buffer-feed.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/encoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder.mbt)
- Rust: [`src/decoder/buffer.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/buffer.rs)
- Rust: [`src/decoder/body.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/body.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
