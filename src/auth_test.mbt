///|
fn init {
  // Test BasicAuth::new
  let auth = @http11.BasicAuth::new("user", "pass")
  if auth.username() == "user" && auth.password() == "pass" {
    println("auth.mbt: BasicAuth::new OK")
  } else {
    println("auth.mbt: BasicAuth::new FAILED")
  }

  // Test BasicAuth::parse
  let auth2 = @http11.BasicAuth::parse("Basic dXNlcjpwYXNzd29yZA==").unwrap()
  if auth2.username() == "user" && auth2.password() == "password" {
    println("auth.mbt: BasicAuth::parse OK")
  } else {
    println("auth.mbt: BasicAuth::parse FAILED")
  }

  // Test BasicAuth::parse lowercase
  let auth3 = @http11.BasicAuth::parse("basic dXNlcjpwYXNzd29yZA==").unwrap()
  if auth3.username() == "user" && auth3.password() == "password" {
    println("auth.mbt: BasicAuth::parse lowercase OK")
  } else {
    println("auth.mbt: BasicAuth::parse lowercase FAILED")
  }

  // Test BasicAuth::parse empty password
  let auth4 = @http11.BasicAuth::parse("Basic dXNlcjo=").unwrap()
  if auth4.username() == "user" && auth4.password() == "" {
    println("auth.mbt: BasicAuth::parse empty password OK")
  } else {
    println("auth.mbt: BasicAuth::parse empty password FAILED")
  }

  // Test BasicAuth empty input
  match @http11.BasicAuth::parse("") {
    Ok(_) => println("auth.mbt: BasicAuth::parse empty FAILED")
    Err(_) => println("auth.mbt: BasicAuth::parse empty OK")
  }

  // Test BasicAuth not basic scheme
  match @http11.BasicAuth::parse("Bearer token") {
    Ok(_) => println("auth.mbt: BasicAuth::parse not basic FAILED")
    Err(_) => println("auth.mbt: BasicAuth::parse not basic OK")
  }

  // Test BasicAuth::to_header_value
  let auth5 = @http11.BasicAuth::new("user", "password")
  let header = auth5.to_header_value()
  if header == "Basic dXNlcjpwYXNzd29yZA==" {
    println("auth.mbt: BasicAuth::to_header_value OK")
  } else {
    println("auth.mbt: BasicAuth::to_header_value FAILED: " + header)
  }

  // Test BasicAuth roundtrip
  let original = @http11.BasicAuth::new("testuser", "testpass123")
  let header2 = original.to_header_value()
  let parsed = @http11.BasicAuth::parse(header2).unwrap()
  if parsed.username() == original.username() &&
    parsed.password() == original.password() {
    println("auth.mbt: BasicAuth roundtrip OK")
  } else {
    println("auth.mbt: BasicAuth roundtrip FAILED")
  }

  // Test WwwAuthenticate::basic
  let www = @http11.WwwAuthenticate::basic("example.com")
  if www.realm() == "example.com" && www.charset() == None {
    println("auth.mbt: WwwAuthenticate::basic OK")
  } else {
    println("auth.mbt: WwwAuthenticate::basic FAILED")
  }

  // Test WwwAuthenticate::with_charset
  let www2 = @http11.WwwAuthenticate::basic("example.com").with_charset("UTF-8")
  if www2.realm() == "example.com" && www2.charset() == Some("UTF-8") {
    println("auth.mbt: WwwAuthenticate::with_charset OK")
  } else {
    println("auth.mbt: WwwAuthenticate::with_charset FAILED")
  }

  // Test WwwAuthenticate::parse
  let www3 = @http11.WwwAuthenticate::parse("Basic realm=\"example.com\"").unwrap()
  if www3.realm() == "example.com" && www3.charset() == None {
    println("auth.mbt: WwwAuthenticate::parse OK")
  } else {
    println("auth.mbt: WwwAuthenticate::parse FAILED")
  }

  // Test WwwAuthenticate::parse with charset
  let www4 = @http11.WwwAuthenticate::parse(
    "Basic realm=\"example.com\", charset=\"UTF-8\"",
  ).unwrap()
  if www4.realm() == "example.com" && www4.charset() == Some("UTF-8") {
    println("auth.mbt: WwwAuthenticate::parse with charset OK")
  } else {
    println("auth.mbt: WwwAuthenticate::parse with charset FAILED")
  }

  // Test WwwAuthenticate::to_string
  let www5 = @http11.WwwAuthenticate::basic("example.com")
  if www5.to_string() == "Basic realm=\"example.com\"" {
    println("auth.mbt: WwwAuthenticate::to_string OK")
  } else {
    println("auth.mbt: WwwAuthenticate::to_string FAILED: " + www5.to_string())
  }

  // Test DigestAuth::parse
  let digest = @http11.DigestAuth::parse(
    "Digest username=\"Mufasa\", realm=\"test\", nonce=\"abc\", uri=\"/\", response=\"xyz\"",
  ).unwrap()
  if digest.username() == Some("Mufasa") && digest.realm() == Some("test") {
    println("auth.mbt: DigestAuth::parse OK")
  } else {
    println("auth.mbt: DigestAuth::parse FAILED")
  }

  // Test DigestAuth::parse missing param
  match
    @http11.DigestAuth::parse("Digest username=\"Mufasa\", realm=\"test\"") {
    Ok(_) => println("auth.mbt: DigestAuth::parse missing param FAILED")
    Err(_) => println("auth.mbt: DigestAuth::parse missing param OK")
  }

  // Test DigestChallenge::parse
  let challenge = @http11.DigestChallenge::parse(
    "Digest realm=\"test\", nonce=\"abc\"",
  ).unwrap()
  if challenge.realm() == Some("test") && challenge.nonce() == Some("abc") {
    println("auth.mbt: DigestChallenge::parse OK")
  } else {
    println("auth.mbt: DigestChallenge::parse FAILED")
  }

  // Test BearerToken::parse
  let bearer = @http11.BearerToken::parse("Bearer abc.def.ghi").unwrap()
  if bearer.token() == "abc.def.ghi" {
    println("auth.mbt: BearerToken::parse OK")
  } else {
    println("auth.mbt: BearerToken::parse FAILED")
  }

  // Test BearerToken::to_header_value
  let bearer2 = @http11.BearerToken::parse("Bearer abc.def").unwrap()
  if bearer2.to_header_value() == "Bearer abc.def" {
    println("auth.mbt: BearerToken::to_header_value OK")
  } else {
    println("auth.mbt: BearerToken::to_header_value FAILED")
  }

  // Test BearerToken empty
  match @http11.BearerToken::parse("") {
    Ok(_) => println("auth.mbt: BearerToken::parse empty FAILED")
    Err(_) => println("auth.mbt: BearerToken::parse empty OK")
  }

  // Test BearerChallenge::parse
  let b_challenge = @http11.BearerChallenge::parse(
    "Bearer realm=\"example\", error=\"invalid_token\"",
  ).unwrap()
  if b_challenge.param("realm") == Some("example") &&
    b_challenge.param("error") == Some("invalid_token") {
    println("auth.mbt: BearerChallenge::parse OK")
  } else {
    println("auth.mbt: BearerChallenge::parse FAILED")
  }

  // Test Authorization::parse
  let authz = @http11.Authorization::parse("Bearer token123").unwrap()
  match authz {
    Bearer(_) => println("auth.mbt: Authorization::parse Bearer OK")
    _ => println("auth.mbt: Authorization::parse Bearer FAILED")
  }

  // Test Authorization::parse Basic
  let authz2 = @http11.Authorization::parse("Basic dXNlcjpwYXNz").unwrap()
  match authz2 {
    Basic(_) => println("auth.mbt: Authorization::parse Basic OK")
    _ => println("auth.mbt: Authorization::parse Basic FAILED")
  }

  // Test Authorization::parse Digest
  let authz3 = @http11.Authorization::parse(
    "Digest username=\"user\", realm=\"test\", nonce=\"abc\", uri=\"/\", response=\"xyz\"",
  ).unwrap()
  match authz3 {
    Digest(_) => println("auth.mbt: Authorization::parse Digest OK")
    _ => println("auth.mbt: Authorization::parse Digest FAILED")
  }

  // Test AuthChallenge::parse
  let ac = @http11.AuthChallenge::parse("Basic realm=\"test\"").unwrap()
  match ac {
    Basic(_) => println("auth.mbt: AuthChallenge::parse OK")
    _ => println("auth.mbt: AuthChallenge::parse FAILED")
  }

  // Test ProxyAuthorization::parse
  let pa = @http11.ProxyAuthorization::parse("Basic dXNlcjpwYXNzd29yZA==").unwrap()
  match pa.authorization() {
    Basic(_) => println("auth.mbt: ProxyAuthorization::parse OK")
    _ => println("auth.mbt: ProxyAuthorization::parse FAILED")
  }

  // Test ProxyAuthenticate::parse
  let pauth = @http11.ProxyAuthenticate::parse("Basic realm=\"proxy\"").unwrap()
  match pauth.challenge() {
    Basic(_) => println("auth.mbt: ProxyAuthenticate::parse OK")
    _ => println("auth.mbt: ProxyAuthenticate::parse FAILED")
  }
  println("auth.mbt: All basic tests completed")
}
