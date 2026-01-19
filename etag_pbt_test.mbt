///|
/// Property-Based Tests for ETag module

// Test: EntityTag strong round-trip (strong -> to_string -> parse)
///|
test "prop_entity_tag_strong_roundtrip" {
  let test_cases = [
    "abc123",
    "xyz789",
    "v1.0.0",
    "33a64df551425fcc55e4d42a148795d9f25f89d4",
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let tag = test_cases[idx]
    let etag = EntityTag::strong(tag)
    match etag {
      Ok(e) => {
        let str = e.to_string()
        let reparsed = EntityTag::parse(str)
        match reparsed {
          Ok(r) => {
            if !r.is_weak() && r.tag() == tag {
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

// Test: EntityTag weak round-trip (weak -> to_string -> parse)
///|
test "prop_entity_tag_weak_roundtrip" {
  let test_cases = [
    "abc123",
    "xyz789",
    "v1.0.0",
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let tag = test_cases[idx]
    let etag = EntityTag::weak(tag)
    match etag {
      Ok(e) => {
        let str = e.to_string()
        let reparsed = EntityTag::parse(str)
        match reparsed {
          Ok(r) => {
            if r.is_weak() && r.tag() == tag {
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

// Test: EntityTag strong_compare
///|
test "prop_entity_tag_strong_compare" {
  let tag1 = EntityTag::strong("abc123")
  let tag2 = EntityTag::strong("abc123")
  let tag3 = EntityTag::strong("xyz789")

  match (tag1, tag2, tag3) {
    (Ok(t1), Ok(t2), Ok(t3)) => {
      // Same tags should match
      assert_true(t1.strong_compare(t2))
      // Different tags should not match
      assert_true(!t1.strong_compare(t3))
    }
    _ => assert_true(false)
  }
}

// Test: EntityTag weak_compare
///|
test "prop_entity_tag_weak_compare" {
  let tag1 = EntityTag::strong("abc123")
  let tag2 = EntityTag::weak("abc123")
  let tag3 = EntityTag::weak("xyz789")

  match (tag1, tag2, tag3) {
    (Ok(t1), Ok(t2), Ok(t3)) => {
      // Same tag, different strength should match for weak compare
      assert_true(t1.weak_compare(t2))
      // Different tags should not match
      assert_true(!t1.weak_compare(t3))
    }
    _ => assert_true(false)
  }
}

// Test: EntityTag to_string format
///|
test "prop_entity_tag_to_string_format" {
  let strong = EntityTag::strong("abc123")
  let weak = EntityTag::weak("abc123")

  match (strong, weak) {
    (Ok(s), Ok(w)) => {
      let s_str = s.to_string()
      let w_str = w.to_string()
      // Strong should not have W/ prefix
      assert_true(!s_str.starts_with("W/"))
      // Weak should have W/ prefix
      assert_true(w_str.starts_with("W/"))
    }
    _ => assert_true(false)
  }
}

// Test: ETagList parse
///|
test "prop_etag_list_parse" {
  let test_cases = [
    "\"abc123\", \"xyz789\"",
    "W/\"v1\", \"v2\"",
    "*",
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = parse_etag_list(input)
    match parsed {
      Ok(_) => passed = passed + 1
      Err(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}

// Test: ETagList is_any
///|
test "prop_etag_list_is_any" {
  let any_list = parse_etag_list("*")
  let tags_list = parse_etag_list("\"abc123\"")

  match (any_list, tags_list) {
    (Ok(any), Ok(tags)) => {
      assert_true(any.is_any())
      assert_true(!tags.is_any())
    }
    _ => assert_true(false)
  }
}

// Test: EntityTag invalid inputs are rejected
///|
test "prop_entity_tag_invalid_inputs_rejected" {
  let test_cases = [
    "",           // Empty
    "abc",        // No quotes
    "\"a bc\"",   // Invalid character (space)
  ]

  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = EntityTag::parse(input)
    match parsed {
      Err(_) => passed = passed + 1
      Ok(_) => ()
    }
    idx = idx + 1
  }

  assert_true(passed == test_cases.length())
}
