# 0059: デコーダーの分割/残余/リミット不変条件 PBT

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: テスト・CI
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

quickcheck は多くのヘッダーで使用されるが Decoder 本体の生成的不変条件が不足。

## 実装方針

- valid-by-construction なメッセージを生成する
- 任意分割と body/header/trailer 上限を property 化する

## 完了条件

- [ ] 入力＝消費＋残余
- [ ] 分割に結果が依存しない
- [ ] 失敗 seed を保存
- [ ] generator 空振り検知
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0004](./0004-preserve-pipelining.md)、[0005](./0005-chunked-request-body.md)、[0006](./0006-chunked-response-body.md)、[0009](./0009-content-length-u64.md)、[0013](./0013-enforce-max-body.md)、[0014](./0014-header-line-prelimit.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/accept_pbt_test.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/accept_pbt_test.mbt)
- Rust: [`pbt/tests/prop_decoder/main.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/pbt/tests/prop_decoder/main.rs)
- Rust: [`pbt/tests/prop_decoder/body.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/pbt/tests/prop_decoder/body.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
