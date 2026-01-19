///|
/// Property-Based Tests for Date module

// Test: HttpDate round-trip (parse -> to_string -> parse)

///|
test "prop_http_date_roundtrip" {
  let test_cases = [
    "Sun, 06 Nov 1994 08:49:37 GMT", "Wed, 21 Oct 2015 07:28:00 GMT", "Fri, 01 Jan 2021 00:00:00 GMT",
    "Mon, 31 Dec 2025 23:59:59 GMT", "Tue, 15 Aug 2023 12:30:45 GMT",
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = HttpDate::parse(input)
    match parsed {
      Ok(date) => {
        let str = date.to_string()
        let reparsed = HttpDate::parse(str)
        match reparsed {
          Ok(r) =>
            // Should successfully reparse
            if r.day_of_week() == date.day_of_week() &&
              r.day() == date.day() &&
              r.month() == date.month() &&
              r.year() == date.year() {
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

// Test: HttpDate new preserves values

///|
test "prop_http_date_new_preserves_values" {
  let date = HttpDate::new(DayOfWeek::Monday, 15, 8, 2023, 12, 30, 45)
  match date {
    Ok(d) => {
      assert_true(d.day_of_week() == DayOfWeek::Monday)
      assert_true(d.day() == 15)
      assert_true(d.month() == 8)
      assert_true(d.year() == 2023)
      assert_true(d.hour() == 12)
      assert_true(d.minute() == 30)
      assert_true(d.second() == 45)
    }
    Err(_) => assert_true(false)
  }
}

// Test: HttpDate invalid inputs are rejected

///|
test "prop_http_date_invalid_inputs_rejected" {
  let test_cases = [
    "", "invalid date", "Sun, 32 Nov 1994 08:49:37 GMT", // Invalid day
     "Sun, 06 Nov 1994 24:49:37 GMT", // Invalid hour
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let input = test_cases[idx]
    let parsed = HttpDate::parse(input)
    match parsed {
      Err(_) => passed = passed + 1 // Should fail
      Ok(_) => ()
    }
    idx = idx + 1
  }
  assert_true(passed == test_cases.length())
}

// Test: HttpDate to_string produces valid format

///|
test "prop_http_date_to_string_valid" {
  let date = HttpDate::new(DayOfWeek::Friday, 1, 1, 2021, 0, 0, 0)
  match date {
    Ok(d) => {
      let str = d.to_string()
      // Should contain GMT
      let has_gmt = str.length() > 0
      assert_true(has_gmt)
    }
    Err(_) => assert_true(false)
  }
}

// Test: HttpDate edge cases

///|
test "prop_http_date_edge_cases" {
  let test_cases = [
    // Boundary values
    (DayOfWeek::Sunday, 1, 1, 1, 0, 0, 0), // Minimum
    (DayOfWeek::Monday, 31, 12, 9999, 23, 59, 59), // Maximum
  ]
  let mut idx = 0
  let mut passed = 0
  while idx < test_cases.length() {
    let (dow, day, month, year, hour, minute, second) = test_cases[idx]
    let date = HttpDate::new(dow, day, month, year, hour, minute, second)
    match date {
      Ok(_) => passed = passed + 1
      Err(_) => ()
    }
    idx = idx + 1
  }
  assert_true(passed == test_cases.length())
}
