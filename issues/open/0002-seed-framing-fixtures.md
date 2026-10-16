# 0002: HTTP framing の正常・異常 fixture を先に保存

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: 調査・基盤
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

`src/decoder.mbt` に対する専用の境界テストがなく、移植差分を保護できない。

## 実装方針

- request/response の分割 CRLF・連結メッセージ・TE/CL の fixture を追加する
- バイト単位の consumed/remaining とエラーの期待値を記録する

## 完了条件

- [ ] 失敗する現状は TODO として明示しテストを消さない
- [ ] `moon test --target native` で fixture が発見される
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/encoder_chunk_test.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/encoder_chunk_test.mbt)
- Rust: [`tests/test_decoder/streaming.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/tests/test_decoder/streaming.rs)
- Rust: [`tests/test_decoder/head.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/tests/test_decoder/head.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
