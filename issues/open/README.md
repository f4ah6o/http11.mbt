# http11.mbt resume-porting backlog

- Created: 2026-10-16
- MoonBit baseline: [`53dc00f389d1`](https://github.com/f4ah6o/http11.mbt/commit/53dc00f389d10da54ab08c71e4da976c084da81d)
- Rust oracle baseline: [`864650119660`](https://github.com/shiguredo/http11-rs/commit/86465011966005160b8798d6ba06a1697bc1342f) (`develop`)
- Individual issues: 68 (P0 25, P1 33, P2 10)

## 運用

1. P0: framing、smuggling 対策、入力・出力バイト安全性を最優先にする。
2. P1: streaming/型/拡張機能/互換性ゲートを依存関係に沿って独立 PR へ分割する。
3. P2: ヘッダー差分、実例、性能、公開ドキュメントを後追いで整備する。

各 Markdown は GitHub Issues を API で発行したものではなく、リポジトリ内の作業 backlog。実装済みかどうかの変更は検証結果を見て判断する。

## 調査・基盤

- [0001 移植基準の固定と Rust/MoonBit 機能対応表](./0001-pin-upstream-parity-baseline.md) — P0
- [0002 HTTP framing の正常・異常 fixture を先に保存](./0002-seed-framing-fixtures.md) — P0

## デコード・正当性

- [0003 入力断片で UnexpectedEof を返さず待機する](./0003-need-more-not-eof.md) — P0; 依存: 0002
- [0004 Complete/reset で次メッセージの未消費 byte を失わない](./0004-preserve-pipelining.md) — P0; 依存: 0002, 0003
- [0005 RequestDecoder の chunked 本文を復元](./0005-chunked-request-body.md) — P0; 依存: 0003, 0004
- [0006 ResponseDecoder の chunked 本文を復元](./0006-chunked-response-body.md) — P0; 依存: 0003, 0004, 0005
- [0007 chunk-size の16進オーバーフローと拡張構文を検証](./0007-chunk-extension-hex-overflow.md) — P0; 依存: 0005, 0006
- [0008 chunked Trailer を最終空行まで解析](./0008-chunked-trailers.md) — P0; 依存: 0005, 0006, 0007
- [0009 Content-Length の厳格な整数解釈と桁あふれ対策](./0009-content-length-u64.md) — P0; 依存: 0002
- [0010 重複 Content-Length の矛盾と統合値を扱う](./0010-duplicate-content-length.md) — P0; 依存: 0009
- [0011 TE/CL の同時受信を安全に拒否](./0011-te-cl-conflict.md) — P0; 依存: 0009, 0010
- [0012 Transfer-Encoding の coding リスト・並び順を解釈](./0012-transfer-encoding-list.md) — P0; 依存: 0005, 0006, 0011
- [0013 DecoderLimits.max_body_size を本文全体に強制](./0013-enforce-max-body.md) — P0; 依存: 0005, 0006, 0009
- [0014 CRLF が無い状態でも行長・件数制限を強制](./0014-header-line-prelimit.md) — P0; 依存: 0002, 0003
- [0015 request-line の method・target・version を厳格に検証](./0015-request-line-strict.md) — P0; 依存: 0002
- [0016 status-line の HTTP version と3桁 code を検証](./0016-status-line-strict.md) — P0; 依存: 0002, 0003
- [0017 ヘッダー名/値の検証と CRLF 注入対策](./0017-header-name-value-validation.md) — P0; 依存: 0002
- [0018 Host 必須性・重複と authority を検証](./0018-host-header-authority.md) — P0; 依存: 0015, 0017
- [0019 1xx/204/304/205 の本文フレーミングを修正](./0019-bodyless-status.md) — P0; 依存: 0009, 0016
- [0020 HEAD のレスポンス本文を読まないモード](./0020-head-request-context.md) — P0; 依存: 0019
- [0021 CONNECT 要求/2xx 応答から tunnel モードに入る](./0021-connect-tunnel.md) — P0; 依存: 0015, 0016, 0018
- [0022 ResponseDecoder の close-delimited 本文と mark_eof](./0022-close-delimited-eof.md) — P0; 依存: 0003, 0016
- [0023 Connection token と HTTP/1.0 keep-alive の判定](./0023-connection-token-keepalive.md) — P1; 依存: 0017
- [0024 feed 超過・parse 失敗時の Decoder 状態契約](./0024-feed-error-transactionality.md) — P1; 依存: 0003, 0013, 0014

## エンコード・安全性

- [0025 encode_request/response を検証付き Result にする](./0025-fallible-encoder.md) — P0; 依存: 0015, 0016, 0017
- [0026 Request エンコード時の Content-Length 自動設定と整合性](./0026-request-content-length-auto.md) — P0; 依存: 0009, 0011, 0025
- [0027 Response エンコード時の CL/TE・特殊 status 検証](./0027-response-content-length-logic.md) — P0; 依存: 0019, 0020, 0025
- [0028 chunked 終端と Trailer の送信 API](./0028-chunk-trailer-encoder.md) — P1; 依存: 0008, 0025

## ストリーミング

- [0029 RequestHead/ResponseHead と decode_headers API](./0029-head-types-decode-headers.md) — P1; 依存: 0015, 0016, 0017, 0019
- [0030 peek_body / consume_body / progress のストリーミング実装](./0030-peek-consume-progress.md) — P1; 依存: 0005, 0006, 0008, 0013, 0021, 0022, 0029
- [0031 低コピーの受信バッファ API を実装・評価](./0031-direct-buffer-feed.md) — P1; 依存: 0013, 0024, 0030
- [0032 chunk state machine の任意分割・ゼロ進捗を検証](./0032-chunk-state-progress-tests.md) — P1; 依存: 0005, 0006, 0007, 0008, 0030

## 公開 API

- [0033 検証済み Method 型と標準メソッド定数](./0033-typed-method-query.md) — P1; 依存: 0015
- [0034 検証済み HeaderName 型と大文字小文字非依存比較](./0034-typed-header-name.md) — P1; 依存: 0017
- [0035 4種類の request-target と Method 制約](./0035-request-target-forms.md) — P1; 依存: 0015, 0018, 0033
- [0036 StatusCode・StatusClass と canonical phrase](./0036-status-code-type.md) — P1; 依存: 0016, 0019
- [0037 HTTP-version の比較と検証を共通化](./0037-http-version-validation.md) — P1; 依存: 0015, 0016, 0023
- [0038 Request/Response の不変条件と検証付きコンストラクター](./0038-validated-constructors.md) — P1; 依存: 0025, 0033, 0034, 0035, 0036, 0037
- [0039 Request/Response の add/set/clear と get_headers を揃える](./0039-mutators-and-header-list.md) — P1; 依存: 0034, 0038
- [0040 HttpHead 共通ロジックでヘッダー判定を統一](./0040-shared-http-head.md) — P1; 依存: 0009, 0010, 0012, 0023, 0029, 0039
- [0041 空本文・本文なし・送信抑止フラグの区別](./0041-optional-body-omit.md) — P1; 依存: 0019, 0020, 0026, 0027, 0038
- [0042 Decode/Encode/Compression/Multipart のエラー体系](./0042-error-type-contract.md) — P1; 依存: 0003, 0009, 0013, 0025

## 追加モジュール

- [0043 Compressor/Decompressor/NoCompression の拡張 API](./0043-compression-interfaces.md) — P1
- [0044 RequestEncoder/ResponseEncoder に圧縮器を注入](./0044-streaming-compression-encoder.md) — P1; 依存: 0027, 0028, 0043
- [0045 Decoder に展開器を注入し展開後サイズを制限](./0045-streaming-decompressor.md) — P1; 依存: 0013, 0030, 0043
- [0046 multipart/form-data Part と Builder の移植](./0046-multipart-part-builder.md) — P1; 依存: 0017
- [0047 incremental MultipartParser を追加](./0047-multipart-streaming-parser.md) — P1; 依存: 0014, 0046
- [0048 multipart delimiter・padding・buffer 上限の防御](./0048-multipart-malformed-limits.md) — P1; 依存: 0046, 0047
- [0049 QUERY method と Accept-Query（RFC 10008/9651）](./0049-accept-query-rfc10008.md) — P1; 依存: 0033
- [0050 RFC3986 相対解決と URI 正規化を移植](./0050-uri-resolve-normalize.md) — P1; 依存: 0001
- [0051 URI パーセント符号化を UTF-8 byte 単位で検証](./0051-unicode-percent-encode.md) — P1; 依存: 0050

## ヘッダー互換

- [0052 Cookie/Set-Cookie の Max-Age・Domain・Path 境界](./0052-cookie-6265bis-parity.md) — P2; 依存: 0017, 0057
- [0053 DigestAuth username*・quoted-pair・パラメーター上限](./0053-digest-auth-username-star.md) — P2; 依存: 0017, 0057
- [0054 filename* と Content-Disposition quoted-string の互換](./0054-content-disposition-extended.md) — P2; 依存: 0017, 0051, 0057
- [0055 Accept 系 qvalue・quoted list の境界値照合](./0055-accept-qvalue-edge-cases.md) — P2; 依存: 0057
- [0056 Content-/Repr-/Want-Digest の RFC9530 バイト互換](./0056-digest-fields-9530.md) — P2; 依存: 0057
- [0057 OWS/tchar/quoted-string の共有バリデーター](./0057-common-validators.md) — P1; 依存: 0017, 0034

## テスト・CI

- [0058 上流 Rust から golden fixture を継続生成](./0058-rust-moonbit-oracle-fixtures.md) — P1; 依存: 0001, 0002
- [0059 デコーダーの分割/残余/リミット不変条件 PBT](./0059-pbt-decoder-fragmentation.md) — P1; 依存: 0004, 0005, 0006, 0009, 0013, 0014
- [0060 不正 byte corpus と roundtrip fuzz 回帰](./0060-fuzz-http-parsers.md) — P1; 依存: 0009, 0011, 0013, 0014, 0025, 0058, 0059
- [0061 CI へ固定 Rust oracle 互換ゲートを導入](./0061-ci-rust-oracle-gate.md) — P1; 依存: 0001, 0058
- [0062 native/js/wasm-gc 間で同じ fixture を比較](./0062-cross-target-conformance.md) — P1; 依存: 0009, 0013, 0058

## 統合・運用

- [0063 native client/server と curl の実通信 E2E](./0063-tcp-client-server-e2e.md) — P1; 依存: 0005, 0006, 0013, 0025, 0026, 0027
- [0064 サーバー例で keep-alive・複数要求・upload を動作させる](./0064-server-keepalive-example.md) — P2; 依存: 0004, 0005, 0023, 0030, 0063
- [0065 native client の URL/IPv6/query 処理と応答境界を修正](./0065-client-ipv6-url.md) — P2; 依存: 0020, 0021, 0022, 0050, 0063
- [0066 reverse proxy の Sans I/O 実例を追加](./0066-sans-io-reverse-proxy-example.md) — P2; 依存: 0011, 0018, 0021, 0022, 0023, 0030, 0063
- [0067 Decoder コピー量・CPU・メモリのベンチマーク](./0067-decoder-memory-bench.md) — P2; 依存: 0014, 0024, 0030, 0031
- [0068 README・サンプル・バージョニングを実装実態へ揃える](./0068-readme-release-parity.md) — P2; 依存: 0001, 0061, 0062

## 実装完了の共通基準

- `moon fmt --check`、`moon check --deny-warn --target native`、`moon test --target native/js/wasm-gc` の必要なコマンドと結果を記録する。
- Rust oracle が利用できない場合は **未実行 / unverified** と記載する。未実行テストを PASS としない。
- 上流 API を MoonBit の所有権・対象ターゲット上で直輸入できない場合は、代替 API と意味の差を明文化する。
- この backlog の追加自体ではコア実装や各テストは変更していない。
