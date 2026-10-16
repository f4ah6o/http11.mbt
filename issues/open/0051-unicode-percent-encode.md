# 0051: URI パーセント符号化を UTF-8 byte 単位で検証

- Priority: P1 (Medium)
- Created: 2026-10-16
- Status: open
- Area: 追加モジュール
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現行 uri percent helper は String 操作を行い Unicode の wire byte と要比較。

## 実装方針

- UTF-8 multi-byte と raw byte の両方を検証する
- 不正 `%` escape の error を定義する

## 完了条件

- [ ] 日本語/emoji が正しい percent byte になる
- [ ] `%ZZ`/末尾 `%` を拒否
- [ ] 非 UTF8 byte を無言変換しない
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 依存 Issue

[0050](./0050-uri-resolve-normalize.md)

## 対象・上流参照

- MoonBit: [`src/uri.mbt`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/uri.mbt)
- Rust: [`src/uri.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/uri.rs)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
