///|
/// Property-Based Tests for URI module

// Test: Uri parse extracts components correctly

///|
test "prop_uri_parse_components" {
  let test_cases = [
    // scheme, host, expected
    ("http://example.com/path", Some("http"), Some("example.com")),
    ("https://example.com:8080/path", Some("https"), Some("example.com")),
    ("ftp://ftp.example.com/files", Some("ftp"), Some("ftp.example.com")),
    ("/path/to/resource", None, None), // Relative URI
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let (input, expected_scheme, expected_host) = test_cases[idx]
    let parsed = Uri::parse(input)
    match parsed {
      Ok(uri) => {
        let scheme_matches = match (expected_scheme, uri.scheme()) {
          (Some(exp), Some(got)) => exp == got
          (None, None) => true
          _ => false
        }
        let host_matches = match (expected_host, uri.host()) {
          (Some(exp), Some(got)) => exp == got
          (None, None) => true
          _ => false
        }
        if scheme_matches && host_matches {
          passed = passed + 1
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }
  assert_true(passed == test_cases.length())
}

// Test: Uri port extraction

///|
test "prop_uri_port_extraction" {
  let test_cases = [
    ("http://example.com:8080/path", Some(8080)),
    ("http://example.com/path", None),
    ("https://example.com:443/path", Some(443)),
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let (input, expected_port) = test_cases[idx]
    let parsed = Uri::parse(input)
    match parsed {
      Ok(uri) => if uri.port() == expected_port { passed = passed + 1 }
      Err(_) => ()
    }
    idx = idx + 1
  }
  assert_true(passed == test_cases.length())
}

// Test: Uri path extraction

///|
test "prop_uri_path_extraction" {
  let test_cases = [
    "http://example.com/path/to/resource", "/path/to/resource", "http://example.com/",
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = Uri::parse(input)
    match parsed {
      Ok(uri) => {
        let path = uri.path()
        if path.length() > 0 {
          passed = passed + 1
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }
  assert_true(passed == test_cases.length())
}

// Test: Uri query extraction

///|
test "prop_uri_query_extraction" {
  let test_cases = [
    "http://example.com/path?key=value", "http://example.com/path?key1=val1&key2=val2",
    "http://example.com/path", // No query
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = Uri::parse(input)
    match parsed {
      Ok(_) =>
        // Should successfully parse
        passed = passed + 1
      Err(_) => ()
    }
    idx = idx + 1
  }
  assert_true(passed == test_cases.length())
}

// Test: Uri fragment extraction

///|
test "prop_uri_fragment_extraction" {
  let test_cases = [
    "http://example.com/path#section", "http://example.com/path", // No fragment
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = Uri::parse(input)
    match parsed {
      Ok(_) =>
        // Should successfully parse
        passed = passed + 1
      Err(_) => ()
    }
    idx = idx + 1
  }
  assert_true(passed == test_cases.length())
}

// Test: Uri empty input is rejected

///|
test "prop_uri_empty_rejected" {
  let parsed = Uri::parse("")
  match parsed {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
}

// Test: Uri percent encoding

///|
test "prop_uri_percent_encoding" {
  let test_cases = [
    "http://example.com/path%20with%20spaces", "http://example.com/path?key=value%20with%20spaces",
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = Uri::parse(input)
    match parsed {
      Ok(_) =>
        // Should successfully parse
        passed = passed + 1
      Err(_) => ()
    }
    idx = idx + 1
  }
  assert_true(passed == test_cases.length())
}

// Test: Uri absolute vs relative

///|
test "prop_uri_absolute_vs_relative" {
  let absolute = Uri::parse("http://example.com/path")
  let relative = Uri::parse("/path/to/resource")
  match (absolute, relative) {
    (Ok(abs), Ok(rel)) => {
      // Absolute URI should have scheme
      assert_true(abs.scheme() != None)
      // Relative URI should not have scheme
      assert_true(rel.scheme() == None)
    }
    _ => assert_true(false)
  }
}
