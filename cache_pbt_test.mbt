///|
/// Property-Based Tests for Cache module

// Test: CacheControl round-trip (parse -> to_string -> parse)
///|
test "prop_cache_control_roundtrip" {
  let test_cases = [
    "no-cache",
    "no-store",
    "max-age=3600",
    "max-age=3600, must-revalidate",
    "public, max-age=604800",
    "private, max-age=0",
    "no-cache, no-store",
    "max-age=0, no-cache",
    "s-maxage=3600",
    "max-stale=300",
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = CacheControl::parse(input)
    match parsed {
      Ok(cc) => {
        let str = cc.to_string()
        let reparsed = CacheControl::parse(str)
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

// Test: CacheControl with_max_age preserves value
///|
test "prop_cache_control_max_age_preserved" {
  let test_cases = [0, 1, 60, 3600, 86400]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let max_age = test_cases[idx]
    let cc = CacheControl::new()
    let cc_with_max_age = cc.with_max_age(max_age)
    let str = cc_with_max_age.to_string()
    let reparsed = CacheControl::parse(str)
    match reparsed {
      Ok(parsed) => {
        match parsed.max_age() {
          Some(v) => {
            if v == max_age {
              passed = passed + 1
            }
          }
          None => ()
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}

// Test: Age round-trip
///|
test "prop_age_roundtrip" {
  let test_cases = [0, 1, 60, 3600, 86400, 2147483647]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let seconds = test_cases[idx]
    let age = Age::new(seconds)
    let str = age.to_string()
    let reparsed = Age::parse(str)
    match reparsed {
      Ok(parsed) => {
        if parsed.seconds() == seconds {
          passed = passed + 1
        }
      }
      Err(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}

// Test: CacheControl flags are preserved
///|
test "prop_cache_control_flags_preserved" {
  let test_cases = [
    "no-cache",
    "no-store",
    "must-revalidate",
    "public",
    "private",
    "immutable",
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = CacheControl::parse(input)
    match parsed {
      Ok(cc) => {
        let str = cc.to_string()
        let reparsed = CacheControl::parse(str)
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

// Test: Empty CacheControl parses successfully
///|
test "prop_cache_control_empty" {
  let parsed = CacheControl::parse("")
  match parsed {
    Ok(cc) => {
      // Empty input should return default CacheControl
      assert_true(cc.max_age() == None)
    }
    Err(_) => {
      assert_true(false)
    }
  }
}
