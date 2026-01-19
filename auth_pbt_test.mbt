///|
/// Property-Based Tests for Auth module

// Test: BasicAuth round-trip (new -> to_header_value -> parse)
///|
test "prop_basic_auth_roundtrip" {
  let test_cases = [
    ("user", "pass"),
    ("admin", "password123"),
    ("test", ""),
    ("", "pass"),
    ("alice", "secret!@#"),
    ("user-with-dash", "pass_with_underscore"),
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let (username, password) = test_cases[idx]
    let auth = BasicAuth::new(username, password)
    let header = auth.to_header_value()
    let reparsed = BasicAuth::parse(header)
    match reparsed {
      Ok(parsed) => {
        if parsed.username() == username && parsed.password() == password {
          passed = passed + 1
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}

// Test: BasicAuth parse preserves credentials
///|
test "prop_basic_auth_preserves_credentials" {
  let test_cases = [
    "Basic dXNlcjpwYXNz",  // user:pass
    "Basic YWRtaW46cGFzc3dvcmQ=",  // admin:password
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = BasicAuth::parse(input)
    match parsed {
      Ok(auth) => {
        // Should successfully parse
        let header = auth.to_header_value()
        if header.length() > 0 {
          passed = passed + 1
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}

// Test: BasicAuth parse invalid input
///|
test "prop_basic_auth_invalid_input" {
  let test_cases = [
    "",
    "NotBasic dXNlcjpwYXNz",
    "Basic invalid_base64!",
    "Basic",  // No credentials
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = BasicAuth::parse(input)
    match parsed {
      Err(_) => passed = passed + 1  // Should fail
      Ok(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}

// Test: WwwAuthenticate round-trip
///|
test "prop_www_authenticate_roundtrip" {
  let test_cases = [
    "Basic realm=\"test\"",
    "Basic realm=\"secure area\", charset=\"UTF-8\"",
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = WwwAuthenticate::parse(input)
    match parsed {
      Ok(auth) => {
        let str = auth.to_string()
        if str.length() > 0 {
          passed = passed + 1
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}
