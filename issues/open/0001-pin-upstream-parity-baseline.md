# 0001: 移植基準の固定と Rust/MoonBit 機能対応表

- Priority: P0 (High)
- Created: 2026-10-16
- Status: open
- Area: 調査・基盤
- Baseline: `http11.mbt@53dc00f389d1` / `http11-rs@864650119660`

## 目的・現状

現在のポート範囲と上流 develop の API/振る舞いを同じ SHA で再現できる対応表がない。

## 実装方針

- 公開 API と decoder/encoder/header/streaming の差分を implemented・partial・missing・unverified に分類する
- 各 gap を個別 Issue にリンクし upstream SHA の更新手順を記す

## 完了条件

- [ ] 上流を無言で latest に切り替えない
- [ ] 未検証を合格扱いしない
- [ ] 機能ごとに根拠ファイルが分かる
- [ ] 正常系と異常系の自動回帰テストを追加し、実際に実行した target/コマンド/結果を PR に記録する
- [ ] 公開 API を変えた場合は `moon info` の interface 差分と互換性影響を確認する

## 対象・上流参照

- MoonBit: [`README.md`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/README.md)
- MoonBit: [`src/pkg.generated.mbti`](https://github.com/f4ah6o/http11.mbt/blob/53dc00f389d10da54ab08c71e4da976c084da81d/src/pkg.generated.mbti)
- Rust: [`src/lib.rs`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/src/lib.rs)
- Rust: [`README.md`](https://github.com/shiguredo/http11-rs/blob/86465011966005160b8798d6ba06a1697bc1342f/README.md)

## 非対象

- 依存する別 Issue の実装や上流への Issue 投稿は、この Issue の完了条件に含めない。
