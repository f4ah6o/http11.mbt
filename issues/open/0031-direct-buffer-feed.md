# 0031: 低コピーの受信バッファ API を実装・評価

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: ストリーミング
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現行 `Array[Byte]` の繰り返し append/split でコピーが増え得る。

## 実装方針

- Rust mut_buf/advance_buf/available_buf に相当する安全な所有権/スライス API を検討する
- 代替 bytes feed も比較する

## 完了条件

- [ ] 残容量/advance 範囲を検証
- [ ] バッファ超過が防止される
- [ ] native/js/wasm-gc の実現方法を記録
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0013](./0013-enforce-max-body.md)、[0024](./0024-feed-error-transactionality.md)、[0030](./0030-peek-consume-progress.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- Rust: [`src/decoder/buffer.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/buffer.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
