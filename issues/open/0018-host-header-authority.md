# 0018: Host 必須性・重複と authority を検証

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: デコード・正当性
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

RequestDecoder は HTTP/1.1 Host 欠落や複数 Host を拒否する経路が見当たらない。

## 実装方針

- HTTP/1.1 の Host 必須と有効値を検証する
- absolute-form と authority-form を区別する

## 完了条件

- [ ] Host 無し・重複は拒否
- [ ] HTTP/1.0 と proxy absolute-form は別ケースで確認
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0015](./0015-request-line-strict.md)、[0017](./0017-header-name-value-validation.md)

## 対象・上流参照

- MoonBit: [`src/decoder.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/decoder.mbt)
- MoonBit: [`src/host.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/host.mbt)
- Rust: [`src/decoder/request.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/decoder/request.rs)
- Rust: [`src/request_target.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/request_target.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
