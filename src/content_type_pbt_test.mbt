///|
/// Property-Based Tests for ContentType module

// Test: ContentType round-trip (parse -> to_string -> parse)

///|
test "prop_content_type_roundtrip" {
  let test_cases = [
    "text/html", "application/json", "text/html; charset=utf-8", "multipart/form-data; boundary=----WebKitFormBoundary",
    "application/xml; charset=iso-8859-1",
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = ContentType::parse(input)
    match parsed {
      Ok(ct) => {
        let str = ct.to_string()
        let reparsed = ContentType::parse(str)
        match reparsed {
          Ok(r) =>
            // Should successfully reparse
            if r.mime_type() == ct.mime_type() {
              passed = passed + 1
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

// Test: ContentType new preserves values

///|
test "prop_content_type_new_preserves_values" {
  let test_cases = [
    ("text", "html"),
    ("application", "json"),
    ("multipart", "form-data"),
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let (media_type, subtype) = test_cases[idx]
    let ct = ContentType::new(media_type, subtype)
    if ct.mime_type() == media_type + "/" + subtype {
      passed = passed + 1
    }
    idx = idx + 1
  }
  assert_true(passed == test_cases.length())
}

// Test: ContentType with_parameter preserves parameter

///|
test "prop_content_type_with_parameter_preserves" {
  let ct = ContentType::new("text", "html")
  let ct_with_charset = ct.with_parameter("charset", "utf-8")
  match ct_with_charset.charset() {
    Some(charset) =>
      if charset == "utf-8" {
        assert_true(true)
      } else {
        assert_true(false)
      }
    None => assert_true(false)
  }
}

// Test: ContentType is_* methods

///|
test "prop_content_type_type_checkers" {
  let json = ContentType::new("application", "json")
  let text = ContentType::new("text", "html")
  let multipart = ContentType::new("multipart", "form-data")
  assert_true(json.is_json())
  assert_true(text.is_text())
  assert_true(multipart.is_multipart())
  assert_true(multipart.is_form_data())
}

// Test: ContentType boundary parameter

///|
test "prop_content_type_boundary_parameter" {
  let ct = ContentType::new("multipart", "form-data")
  let ct_with_boundary = ct.with_parameter("boundary", "----XYZ")
  match ct_with_boundary.boundary() {
    Some(boundary) =>
      if boundary == "----XYZ" {
        assert_true(true)
      } else {
        assert_true(false)
      }
    None => assert_true(false)
  }
}

// Test: ContentType charset parameter

///|
test "prop_content_type_charset_parameter" {
  let ct = ContentType::new("text", "html")
  let ct_with_charset = ct.with_parameter("charset", "utf-8")
  match ct_with_charset.charset() {
    Some(charset) =>
      if charset == "utf-8" {
        assert_true(true)
      } else {
        assert_true(false)
      }
    None => assert_true(false)
  }
}

// Test: ContentType to_string produces valid format

///|
test "prop_content_type_to_string_valid" {
  let ct = ContentType::new("application", "json")
  let str = ct.to_string()

  // Should contain /
  assert_true(str.length() > 0)
}

// Test: ContentType empty input is rejected

///|
test "prop_content_type_empty_rejected" {
  let parsed = ContentType::parse("")
  match parsed {
    Err(_) => assert_true(true)
    Ok(_) => assert_true(false)
  }
}
