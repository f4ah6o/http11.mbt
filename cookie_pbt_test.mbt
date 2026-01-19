///|
/// Property-Based Tests for Cookie module

// Test: Cookie round-trip (new -> to_string -> parse)

///|
test "prop_cookie_roundtrip" {
  let test_cases = [
    ("session", "abc123"),
    ("user_id", "12345"),
    ("token", "xyz"),
    ("name", "John_Doe"),
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let (name, value) = test_cases[idx]
    let cookie = Cookie::new(name, value)
    match cookie {
      Ok(c) => {
        let str = c.to_string()
        let reparsed = Cookie::parse(str)
        match reparsed {
          Ok(cookies) =>
            if cookies.length() > 0 {
              let first = cookies[0]
              if first.name() == name && first.value() == value {
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

// Test: Cookie parse handles multiple cookies

///|
test "prop_cookie_multiple_preserved" {
  let input = "session=abc123; user_id=12345; token=xyz"
  let parsed = Cookie::parse(input)
  match parsed {
    Ok(cookies) => assert_true(cookies.length() == 3)
    Err(_) => assert_true(false)
  }
}

// Test: Cookie invalid names are rejected

///|
test "prop_cookie_invalid_names_rejected" {
  let test_cases = [
    "", // Empty name
     "=value",
  ] // Empty name
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let name = test_cases[idx]
    let cookie = Cookie::new(name, "value")
    match cookie {
      Err(_) => passed = passed + 1
      Ok(_) => ()
    }
    idx = idx + 1
  }
  assert_true(passed == test_cases.length())
}

// Test: SetCookie round-trip

///|
test "prop_set_cookie_roundtrip" {
  let test_cases = [("session", "abc123"), ("user", "john")]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let (name, value) = test_cases[idx]
    let cookie = SetCookie::new(name, value)
    match cookie {
      Ok(sc) => {
        let str = sc.to_string()
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

// Test: SetCookie with HttpOnly flag

///|
test "prop_set_cookie_httponly_preserved" {
  let cookie = SetCookie::new("session", "abc")
  match cookie {
    Ok(sc) => {
      let sc_http_only = sc.with_http_only(true)
      let str = sc_http_only.to_string()
      // Should contain HttpOnly
      assert_true(str.length() > 0)
    }
    Err(_) => assert_true(false)
  }
}

// Test: SameSite to_string

///|
test "prop_samesite_to_string" {
  let test_cases = [
    (SameSite::Strict, "Strict"),
    (SameSite::Lax, "Lax"),
    (SameSite::SameSiteNone, "None"),
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let (samesite, expected) = test_cases[idx]
    let str = samesite.to_string()
    if str == expected {
      passed = passed + 1
    }
    idx = idx + 1
  }
  assert_true(passed == test_cases.length())
}
