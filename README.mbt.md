# f4ah6o/http11

MoonBit で実装された Sans I/O な HTTP/1.1 パーサー・エンコーダーライブラリ。

## 概要

本ライブラリは [shiguredo/http11-rs](https://github.com/shiguredo/http11-rs) を MoonBit に移植したものです。Sans I/O 設計により、I/O 処理を完全に分離しているため、任意のトランスポート（TCP、TLS、WebSocket 等）で使用できます。

- **依存ライブラリなし**: MoonBit 標準ライブラリのみで動作
- **DoS 攻撃対策**: デコーダーリミット機能でリソース枯渇攻撃を防御
- **HTTP/1.1 準拠**: Content-Length および chunked 転送エンコーディングに対応

## モジュール構成

| ファイル | 説明 |
|---------|------|
| `error.mbt` | `HttpError` enum - パースエラーの種類 |
| `limits.mbt` | `DecoderLimits` struct - デコーダー制限値 |
| `request.mbt` | `Request` struct - HTTP リクエスト表現 |
| `response.mbt` | `Response` struct - HTTP レスポンス表現 |
| `encoder.mbt` | リクエスト/レスポンスのエンコード関数 |
| `decoder.mbt` | `RequestDecoder`, `ResponseDecoder` - Sans I/O デコーダー |

## エラー型

```moonbit
///|
pub enum HttpError {
  InvalidData(String) // 不正なデータ
  BufferOverflow(Int, Int) // (size, limit)
  TooManyHeaders(Int, Int) // (count, limit)
  HeaderLineTooLong(Int, Int) // (size, limit)
  BodyTooLarge(Int, Int) // (size, limit)
  UnexpectedEof // 予期しない EOF
  InvalidHeaderValue // 不正なヘッダー値
  InvalidStatusCode // 不正なステータスコード
  InvalidChunkSize // 不正なチャンクサイズ
}
```

## デコーダーリミット

```moonbit
///|
pub struct DecoderLimits {
  max_buffer_size : Int // デフォルト: 65536
  max_headers_count : Int // デフォルト: 100
  max_header_line_size : Int // デフォルト: 8192
  max_body_size : Int // デフォルト: 10485760 (10MB)
}

// デフォルトリミットで作成

///|
let decoder = RequestDecoder::new()

// カスタムリミットで作成

///|
let limits = {
  max_buffer_size: 32768,
  max_headers_count: 50,
  max_header_line_size: 4096,
  max_body_size: 5242880,
}

///|
let decoder = RequestDecoder::with_limits(limits)

// 無制限（テスト用途）

///|
let decoder = RequestDecoder::with_limits(DecoderLimits::unlimited())
```

## リクエスト

### 作成とエンコード

```moonbit
// 基本的なリクエスト作成
///|
let req = Request::new("GET", "/test")
  .header("Host", "example.com")
  .header("Connection", "keep-alive")

// ボディ付きリクエスト

///|
let req = Request::new("POST", "/api")
  .header("Content-Type", "application/json")
  .body("{\"key\":\"value\"}".to_bytes())

// バージョン指定

///|
let req = Request::with_version("GET", "/", "HTTP/1.0")

// エンコード

///|
let encoded = encode_request(req)
// GET /test HTTP/1.1\r\nHost: example.com\r\nConnection: keep-alive\r\n\r\n
```

### ヘルパーメソッド

```moonbit
req.method()              // "GET"
req.get_header("Host")    // Some("example.com")
req.has_header("Host")    // true
req.is_keep_alive()       // true
req.content_length()      // Some(123)
req.is_chunked()          // false
```

## レスポンス

### 作成とエンコード

```moonbit
// 基本的なレスポンス作成
///|
let resp = Response::new(200, "OK")
  .header("Content-Type", "text/plain")
  .header("Content-Length", "5")

// ボディ付きレスポンス

///|
let resp = Response::new(404, "Not Found")
  .header("Content-Type", "text/html")
  .body("<h1>Not Found</h1>".to_bytes())

// エンコード

///|
let encoded = encode_response(resp)
// HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 5\r\n\r\n
```

### ステータスチェック

```moonbit
resp.is_success()      // 200-299
resp.is_redirect()     // 300-399
resp.is_client_error() // 400-499
resp.is_server_error() // 500-599
```

## デコーダー（Sans I/O）

### リクエストデコード

```moonbit
let decoder = RequestDecoder::new()

// データをフィード
decoder.feed(data)?

// デコード試行
match decoder.decode() {
  Ok(Some(request)) => // リクエスト完了
    // request.http_method, request.uri, request.headers, request.body
  Ok(None) => // データが不十分 - 更にデータを feed して再試行
  Err(e) => // エラー処理
}

// デコーダーをリセットして次のリクエストに備える
decoder.reset()

// 未処理のデータを取得
let remaining = decoder.remaining()
```

### レスポンスデコード

```moonbit
let decoder = ResponseDecoder::new()

decoder.feed(data)?
match decoder.decode() {
  Ok(Some(response)) => // レスポンス完了
    // response.status_code, response.reason_phrase, response.headers, response.body
  Ok(None) => // データが不十分
  Err(e) => // エラー処理
}
```

## Chunked 転送エンコーディング

```moonbit
// チャンクエンコード
///|
let chunk1 = "Hello, ".to_bytes()

///|
let chunk2 = "world!".to_bytes()

///|
let encoded = encode_chunks([chunk1, chunk2])
// 7\r\nHello, \r\n6\r\nworld!\r\n0\r\n\r\n

// 単一チャンク

///|
let encoded = encode_chunk("data".to_bytes())
// 4\r\ndata\r\n
```

## サンプル

本ライブラリには実行可能なサンプルプログラムが含まれています。

### 実行方法

```bash
moon run cmd/main
```

### 出力例

```
========================================
http11.mbt Example Program
========================================

1. GET Request Example
---
Encoded GET request:
GET /api/users HTTP/1.1\r\n
Host: example.com\r\n
Connection: keep-alive\r\n
Accept: application/json\r\n
\r\n

2. POST Request with Body Example
---
Encoded POST request:
POST /api/users HTTP/1.1\r\n
Host: example.com\r\n
Content-Type: application/json\r\n
\r\n
{"name":"Alice","age":30}

3. Response Example
---
Encoded response:
HTTP/1.1 200 OK\r\n
Content-Type: text/plain\r\n
Content-Length: 13\r\n
\r\n
Hello, World!

4. Chunked Transfer Encoding Example
---
Encoded chunked data:
7\r\n
Hello, \r\n
6\r\n
world!\r\n
0\r\n
\r\n

5. Request Decoder Example
---
RequestDecoder API usage:
  let decoder = @lib.RequestDecoder::new()
  decoder.feed(data)  // Feed raw bytes
  decoder.decode()    // Try to decode a request
  Note: Decoder is intended for use with network I/O

6. Response Decoder Example
---
ResponseDecoder API usage:
  let decoder = @lib.ResponseDecoder::new()
  decoder.feed(data)  // Feed raw bytes
  decoder.decode()    // Try to decode a response
  Note: Decoder is intended for use with network I/O

========================================
All examples completed successfully!
========================================
```

## ライセンス

```
Portions derived from https://github.com/shiguredo/http11-rs
Copyright 2026 Shiguredo Inc.
Licensed under the Apache License, Version 2.0
```

本ライブラリ全体も Apache License 2.0 でライセンスされています。
