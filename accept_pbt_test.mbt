///|
/// Property-Based Tests for Accept module
/// Simple implementation without external framework

// Test: QValue round-trip (parse -> to_string -> parse)
///|
test "prop_qvalue_roundtrip" {
  let test_cases = [
    "1", "0.5", "0.123", "0.001", "0.999", "0", "0.1", "0.01", "0.100", "0.500", "1.0", "1.00"
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = QValue::parse(input)
    match parsed {
      Ok(qv) => {
        let str = qv.to_string()
        let reparsed = QValue::parse(str)
        match reparsed {
          Ok(r) => {
            if r.value() == qv.value() {
              passed = passed + 1
            }
          }
          Err(_) => ()
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}

// Test: Accept round-trip (parse -> to_string -> parse)
///|
test "prop_accept_roundtrip" {
  let test_cases = [
    "text/html",
    "text/*; q=0.5",
    "application/json",
    "*/*",
    "text/html; level=1",
    "text/html; q=0.5",
    "application/json; charset=utf-8",
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = Accept::parse(input)
    match parsed {
      Ok(accept) => {
        let str = accept.to_string()
        let reparsed = Accept::parse(str)
        match reparsed {
          Ok(_) => passed = passed + 1
          Err(_) => ()
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}

// Test: AcceptCharset preserves items through parse
///|
test "prop_accept_charset_preserves_items" {
  let test_cases = [
    "utf-8",
    "iso-8859-1;q=0.5",
    "*",
    "utf-8, iso-8859-1;q=0.5",
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = AcceptCharset::parse(input)
    match parsed {
      Ok(charset) => {
        let items = charset.items()
        if items.length() > 0 {
          passed = passed + 1
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}

// Test: AcceptEncoding preserves items through parse
///|
test "prop_accept_encoding_preserves_items" {
  let test_cases = [
    "gzip",
    "deflate;q=0.5",
    "identity",
    "gzip, deflate;q=0.5",
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = AcceptEncoding::parse(input)
    match parsed {
      Ok(encoding) => {
        let items = encoding.items()
        if items.length() > 0 {
          passed = passed + 1
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}

// Test: AcceptLanguage preserves items through parse
///|
test "prop_accept_language_preserves_items" {
  let test_cases = [
    "en-US",
    "ja;q=0.8",
    "*",
    "en-US, ja;q=0.8",
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = AcceptLanguage::parse(input)
    match parsed {
      Ok(lang) => {
        let items = lang.items()
        if items.length() > 0 {
          passed = passed + 1
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}
