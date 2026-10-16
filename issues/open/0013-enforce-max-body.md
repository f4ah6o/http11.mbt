# 0013: DecoderLimits.max_body_size を本文全体に強制

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現行 Body 分岐は `max_body_size` を参照せず本文を蓄積する。

## 実装方針

- CL 判明時に上限を検査する
- chunked と close-delimited は累計 bytes を制限する

## 完了条件

- [ ] 上限ぴったり成功/+1失敗
- [ ] feed 分割で上限回避できない
- [ ] 不正な大数で割当しない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0005](./0005-chunked-request-body.md)、[0006](./0006-chunked-response-body.md)、[0009](./0009-content-length-u64.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/limits.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/limits.mbt)
- Rust: [`src/decoder/body.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/body.rs)
- Rust: [`src/limits.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/limits.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
