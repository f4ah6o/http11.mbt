///|
fn init {
  // Test parse single range
  match Range::parse("bytes=0-499") {
    Ok(range1) => {
      if range1.unit() == "bytes" && range1.is_bytes() {
        println("range.mbt: Parse single range OK")
      } else {
        println("range.mbt: Parse single range FAILED")
      }

      let specs1 = range1.ranges()
      if specs1.length() == 1 {
        match specs1[0] {
          Range(s, e) => {
            if s == 0UL && e == 499UL {
              println("range.mbt: Single range values OK")
            } else {
              println("range.mbt: Single range values FAILED")
            }
          }
          _ => println("range.mbt: Single range type FAILED")
        }
      } else {
        println("range.mbt: Single range count FAILED")
      }
    }
    Err(e) => {
      println("range.mbt: Parse ERROR: " + e.to_string())
    }
  }

  // Test parse multiple ranges
  let range2 = Range::parse("bytes=0-499, 1000-1499").unwrap()
  let specs2 = range2.ranges()
  if specs2.length() == 2 {
    println("range.mbt: Parse multiple ranges OK")
  } else {
    println("range.mbt: Parse multiple ranges FAILED")
  }

  // Test parse suffix range
  let range3 = Range::parse("bytes=-500").unwrap()
  match range3.first() {
    Some(Suffix(l)) => {
      if l == 500UL {
        println("range.mbt: Parse suffix range OK")
      } else {
        println("range.mbt: Parse suffix range FAILED")
      }
    }
    _ => println("range.mbt: Parse suffix range type FAILED")
  }

  // Test parse from_start range
  let range4 = Range::parse("bytes=500-").unwrap()
  match range4.first() {
    Some(FromStart(s)) => {
      if s == 500UL {
        println("range.mbt: Parse from_start range OK")
      } else {
        println("range.mbt: Parse from_start range FAILED")
      }
    }
    _ => println("range.mbt: Parse from_start range type FAILED")
  }

  // Test invalid bounds
  let invalid1 = Range::parse("bytes=500-100")
  match invalid1 {
    Ok(_) => println("range.mbt: Invalid bounds FAILED")
    Err(InvalidBounds) => println("range.mbt: Invalid bounds OK")
    _ => println("range.mbt: Invalid bounds error type FAILED")
  }

  // Test empty input
  let empty = Range::parse("")
  match empty {
    Ok(_) => println("range.mbt: Empty parse FAILED")
    Err(Empty) => println("range.mbt: Empty parse OK")
    _ => println("range.mbt: Empty parse error type FAILED")
  }

  // Test RangeSpec::to_bounds via Range parsing
  let total = 1000UL

  // Test Range to_bounds via parsed range
  let range_bounds = Range::parse("bytes=0-499").unwrap()
  let spec1 = range_bounds.first()
  match spec1 {
    Some(s) => {
      match s.to_bounds(total) {
        Some((start, end)) => {
          if start == 0UL && end == 499UL {
            println("range.mbt: Range to_bounds OK")
          } else {
            println("range.mbt: Range to_bounds FAILED")
          }
        }
        None => println("range.mbt: Range to_bounds FAILED (None)")
      }
    }
    None => println("range.mbt: Range to_bounds FAILED (no spec)")
  }

  // Test FromStart to_bounds via parsed range
  let range_from = Range::parse("bytes=500-").unwrap()
  let spec2 = range_from.first()
  match spec2 {
    Some(s) => {
      match s.to_bounds(total) {
        Some((start, end)) => {
          if start == 500UL && end == 999UL {
            println("range.mbt: FromStart to_bounds OK")
          } else {
            println("range.mbt: FromStart to_bounds FAILED")
          }
        }
        None => println("range.mbt: FromStart to_bounds FAILED (None)")
      }
    }
    None => println("range.mbt: FromStart to_bounds FAILED (no spec)")
  }

  // Test Suffix to_bounds via parsed range
  let range_suffix = Range::parse("bytes=-200").unwrap()
  let spec3 = range_suffix.first()
  match spec3 {
    Some(s) => {
      match s.to_bounds(total) {
        Some((start, end)) => {
          if start == 800UL && end == 999UL {
            println("range.mbt: Suffix to_bounds OK")
          } else {
            println("range.mbt: Suffix to_bounds FAILED")
          }
        }
        None => println("range.mbt: Suffix to_bounds FAILED (None)")
      }
    }
    None => println("range.mbt: Suffix to_bounds FAILED (no spec)")
  }

  // Test out of bounds via parsed range
  let range_oob = Range::parse("bytes=1000-1500").unwrap()
  let spec4 = range_oob.first()
  match spec4 {
    Some(s) => {
      match s.to_bounds(total) {
        None => println("range.mbt: Out of bounds OK")
        Some(_) => println("range.mbt: Out of bounds FAILED")
      }
    }
    None => println("range.mbt: Out of bounds FAILED (no spec)")
  }

  // Test Range::to_string
  let range5 = Range::parse("bytes=0-499, 1000-1499").unwrap()
  let str5 = range5.to_string()
  if str5 == "bytes=0-499, 1000-1499" {
    println("range.mbt: Range to_string OK")
  } else {
    println("range.mbt: Range to_string FAILED")
  }

  // Test ContentRange::parse
  let cr1 = ContentRange::parse("bytes 0-499/1000").unwrap()
  if cr1.unit() == "bytes" && cr1.start() == Some(0UL) && cr1.end() == Some(499UL) && cr1.complete_length() == Some(1000UL) {
    println("range.mbt: ContentRange parse OK")
  } else {
    println("range.mbt: ContentRange parse FAILED")
  }

  let len1 = cr1.length()
  match len1 {
    Some(l) => {
      if l == 500UL {
        println("range.mbt: ContentRange length OK")
      } else {
        println("range.mbt: ContentRange length FAILED")
      }
    }
    None => println("range.mbt: ContentRange length FAILED (None)")
  }

  // Test ContentRange unknown length
  let cr2 = ContentRange::parse("bytes 0-499/*").unwrap()
  match cr2.complete_length() {
    None => println("range.mbt: ContentRange unknown length OK")
    Some(_) => println("range.mbt: ContentRange unknown length FAILED")
  }

  // Test ContentRange unsatisfied
  let cr3 = ContentRange::parse("bytes */1000").unwrap()
  if cr3.is_unsatisfied() && cr3.complete_length() == Some(1000UL) {
    println("range.mbt: ContentRange unsatisfied OK")
  } else {
    println("range.mbt: ContentRange unsatisfied FAILED")
  }

  // Test ContentRange::new_bytes
  let cr4 = ContentRange::new_bytes(0UL, 499UL, Some(1000UL))
  let str4 = cr4.to_string()
  if str4 == "bytes 0-499/1000" {
    println("range.mbt: ContentRange new_bytes OK")
  } else {
    println("range.mbt: ContentRange new_bytes FAILED: " + str4)
  }

  // Test ContentRange::unsatisfied
  let cr5 = ContentRange::unsatisfied("bytes", 1000UL)
  let str5 = cr5.to_string()
  if str5 == "bytes */1000" {
    println("range.mbt: ContentRange unsatisfied static OK")
  } else {
    println("range.mbt: ContentRange unsatisfied static FAILED: " + str5)
  }

  // Test AcceptRanges::parse bytes
  let ar1 = AcceptRanges::parse("bytes").unwrap()
  if ar1.accepts_bytes() && !ar1.is_none() {
    println("range.mbt: AcceptRanges bytes OK")
  } else {
    println("range.mbt: AcceptRanges bytes FAILED")
  }

  // Test AcceptRanges::parse none
  let ar2 = AcceptRanges::parse("none").unwrap()
  if ar2.is_none() && !ar2.accepts_bytes() {
    println("range.mbt: AcceptRanges none OK")
  } else {
    println("range.mbt: AcceptRanges none FAILED")
  }

  // Test AcceptRanges::bytes
  let ar3 = AcceptRanges::bytes()
  let str3 = ar3.to_string()
  if str3 == "bytes" && ar3.accepts_bytes() {
    println("range.mbt: AcceptRanges bytes static OK")
  } else {
    println("range.mbt: AcceptRanges bytes static FAILED")
  }

  // Test AcceptRanges::none
  let ar4 = AcceptRanges::none()
  let str4_ar = ar4.to_string()
  if str4_ar == "none" && ar4.is_none() {
    println("range.mbt: AcceptRanges none static OK")
  } else {
    println("range.mbt: AcceptRanges none static FAILED")
  }

  // Test u64_to_string
  let test_str = rg_u64_to_string(0UL)
  if test_str == "0" {
    println("range.mbt: u64_to_string(0) OK")
  } else {
    println("range.mbt: u64_to_string(0) FAILED: " + test_str)
  }

  let test_str2 = rg_u64_to_string(12345UL)
  if test_str2 == "12345" {
    println("range.mbt: u64_to_string(12345) OK")
  } else {
    println("range.mbt: u64_to_string(12345) FAILED: " + test_str2)
  }

  // Test parse_u64
  match rg_parse_u64("0") {
    Some(n) => {
      if n == 0UL {
        println("range.mbt: parse_u64(0) OK")
      } else {
        println("range.mbt: parse_u64(0) FAILED")
      }
    }
    None => println("range.mbt: parse_u64(0) FAILED")
  }

  match rg_parse_u64("12345") {
    Some(n) => {
      if n == 12345UL {
        println("range.mbt: parse_u64(12345) OK")
      } else {
        println("range.mbt: parse_u64(12345) FAILED")
      }
    }
    None => println("range.mbt: parse_u64(12345) FAILED")
  }

  // Test large u64 values (boundary testing)
  let large_val = 18446744073709551615UL
  let large_str = rg_u64_to_string(large_val)
  if large_str == "18446744073709551615" {
    println("range.mbt: u64_to_string(max) OK")
  } else {
    println("range.mbt: u64_to_string(max) FAILED: " + large_str)
  }

  match rg_parse_u64("18446744073709551615") {
    Some(n) => {
      if n == large_val {
        println("range.mbt: parse_u64(max) OK")
      } else {
        println("range.mbt: parse_u64(max) FAILED")
      }
    }
    None => println("range.mbt: parse_u64(max) FAILED")
  }

  // Test invalid parse_u64 (overflow)
  match rg_parse_u64("18446744073709551616") {
    None => println("range.mbt: parse_u64(overflow) OK")
    Some(_) => println("range.mbt: parse_u64(overflow) FAILED")
  }

  println("range.mbt: All basic tests completed")
}
