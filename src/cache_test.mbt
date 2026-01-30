///|
fn init {
  // Test CacheControl::parse with max-age
  let cc1 = CacheControl::parse("max-age=3600").unwrap()
  match cc1.max_age() {
    Some(3600) => println("cache.mbt: Parse max-age OK")
    _ => println("cache.mbt: Parse max-age FAILED")
  }

  // Test CacheControl::parse with multiple directives
  let cc2 = CacheControl::parse("max-age=3600, public, no-transform").unwrap()
  match cc2.max_age() {
    Some(3600) =>
      if cc2.is_public() && cc2.is_no_transform() {
        println("cache.mbt: Parse multiple directives OK")
      } else {
        println("cache.mbt: Parse multiple directives FAILED")
      }
    _ => println("cache.mbt: Parse multiple directives FAILED")
  }

  // Test CacheControl::parse with no-store
  let cc3 = CacheControl::parse("no-store").unwrap()
  if cc3.is_no_store() && !cc3.is_cacheable() {
    println("cache.mbt: Parse no-store OK")
  } else {
    println("cache.mbt: Parse no-store FAILED")
  }

  // Test CacheControl::parse with private
  let cc4 = CacheControl::parse("private, max-age=600").unwrap()
  match cc4.max_age() {
    Some(600) =>
      if cc4.is_private() {
        println("cache.mbt: Parse private OK")
      } else {
        println("cache.mbt: Parse private FAILED")
      }
    _ => println("cache.mbt: Parse private FAILED")
  }

  // Test CacheControl::parse with s-maxage
  let cc5 = CacheControl::parse("public, s-maxage=86400").unwrap()
  match cc5.s_maxage() {
    Some(86400) =>
      if cc5.is_public() {
        println("cache.mbt: Parse s-maxage OK")
      } else {
        println("cache.mbt: Parse s-maxage FAILED")
      }
    _ => println("cache.mbt: Parse s-maxage FAILED")
  }

  // Test CacheControl::parse with must-revalidate
  let cc6 = CacheControl::parse("max-age=0, must-revalidate").unwrap()
  match cc6.max_age() {
    Some(0) =>
      if cc6.is_must_revalidate() {
        println("cache.mbt: Parse must-revalidate OK")
      } else {
        println("cache.mbt: Parse must-revalidate FAILED")
      }
    _ => println("cache.mbt: Parse must-revalidate FAILED")
  }

  // Test CacheControl::parse with immutable
  let cc7 = CacheControl::parse("max-age=31536000, immutable").unwrap()
  match cc7.max_age() {
    Some(31536000) =>
      if cc7.is_immutable() {
        println("cache.mbt: Parse immutable OK")
      } else {
        println("cache.mbt: Parse immutable FAILED")
      }
    _ => println("cache.mbt: Parse immutable FAILED")
  }

  // Test CacheControl::parse with empty string
  let cc8 = CacheControl::parse("").unwrap()
  match cc8.max_age() {
    None =>
      if !cc8.is_public() {
        println("cache.mbt: Parse empty string OK")
      } else {
        println("cache.mbt: Parse empty string FAILED")
      }
    _ => println("cache.mbt: Parse empty string FAILED")
  }

  // Test CacheControl builder
  let cc9 = CacheControl::new()
    .with_max_age(3600)
    .with_public()
    .with_no_transform()
  match cc9.max_age() {
    Some(3600) =>
      if cc9.is_public() && cc9.is_no_transform() {
        println("cache.mbt: Builder pattern OK")
      } else {
        println("cache.mbt: Builder pattern FAILED")
      }
    _ => println("cache.mbt: Builder pattern FAILED")
  }

  // Test CacheControl::to_string
  let cc10 = CacheControl::new().with_max_age(3600).with_public()
  let str10 = cc10.to_string()
  if cc_string_contains(str10, "max-age=3600") &&
    cc_string_contains(str10, "public") {
    println("cache.mbt: to_string OK")
  } else {
    println("cache.mbt: to_string FAILED")
  }

  // Test CacheControl::is_cacheable
  let cc11 = CacheControl::new().with_max_age(3600)
  if cc11.is_cacheable() {
    println("cache.mbt: is_cacheable (true) OK")
  } else {
    println("cache.mbt: is_cacheable (true) FAILED")
  }
  let cc12 = CacheControl::new().with_no_store()
  if !cc12.is_cacheable() {
    println("cache.mbt: is_cacheable (false) OK")
  } else {
    println("cache.mbt: is_cacheable (false) FAILED")
  }

  // Test Age::parse
  let age1 = Age::parse("120").unwrap()
  if age1.seconds() == 120 {
    println("cache.mbt: Age parse OK")
  } else {
    println("cache.mbt: Age parse FAILED")
  }

  // Test Age::parse with zero
  let age2 = Age::parse("0").unwrap()
  if age2.seconds() == 0 {
    println("cache.mbt: Age parse zero OK")
  } else {
    println("cache.mbt: Age parse zero FAILED")
  }

  // Test Age::parse with empty string
  let age3 = Age::parse("")
  match age3 {
    Ok(_) => println("cache.mbt: Age parse empty FAILED")
    Err(_) => println("cache.mbt: Age parse empty OK")
  }

  // Test Age::parse with invalid input
  let age4 = Age::parse("abc")
  match age4 {
    Ok(_) => println("cache.mbt: Age parse invalid FAILED")
    Err(_) => println("cache.mbt: Age parse invalid OK")
  }

  // Test Age::to_string
  let age5 = Age::new(120)
  if age5.to_string() == "120" {
    println("cache.mbt: Age to_string OK")
  } else {
    println("cache.mbt: Age to_string FAILED")
  }

  // Test Expires::parse
  let expires1 = Expires::parse("Sun, 06 Nov 1994 08:49:37 GMT").unwrap()
  let date1 = expires1.date()
  if date1.year() == 1994 && date1.month() == 11 && date1.day() == 6 {
    println("cache.mbt: Expires parse OK")
  } else {
    println("cache.mbt: Expires parse FAILED")
  }

  // Test Expires::parse with invalid date
  let expires2 = Expires::parse("invalid date")
  match expires2 {
    Ok(_) => println("cache.mbt: Expires parse invalid FAILED")
    Err(_) => println("cache.mbt: Expires parse invalid OK")
  }

  // Test Expires::parse with empty string
  let expires3 = Expires::parse("")
  match expires3 {
    Ok(_) => println("cache.mbt: Expires parse empty FAILED")
    Err(_) => println("cache.mbt: Expires parse empty OK")
  }

  // Test Expires::to_string
  let expires4 = Expires::parse("Sun, 06 Nov 1994 08:49:37 GMT").unwrap()
  let str4 = expires4.to_string()
  if cc_string_contains(str4, "1994") && cc_string_contains(str4, "Nov") {
    println("cache.mbt: Expires to_string OK")
  } else {
    println("cache.mbt: Expires to_string FAILED")
  }

  // Test CacheControl roundtrip
  let original = CacheControl::new()
    .with_max_age(3600)
    .with_public()
    .with_must_revalidate()
  let header = original.to_string()
  let reparsed = CacheControl::parse(header).unwrap()
  match reparsed.max_age() {
    Some(3600) =>
      if reparsed.is_public() && reparsed.is_must_revalidate() {
        println("cache.mbt: CacheControl roundtrip OK")
      } else {
        println("cache.mbt: CacheControl roundtrip FAILED")
      }
    _ => println("cache.mbt: CacheControl roundtrip FAILED")
  }

  // Test Age roundtrip
  let age_orig = Age::new(3600)
  let age_header = age_orig.to_string()
  let age_reparsed = Age::parse(age_header).unwrap()
  if age_orig.seconds() == age_reparsed.seconds() {
    println("cache.mbt: Age roundtrip OK")
  } else {
    println("cache.mbt: Age roundtrip FAILED")
  }

  // Test Expires roundtrip
  let exp_orig = Expires::parse("Sun, 06 Nov 1994 08:49:37 GMT").unwrap()
  let exp_header = exp_orig.to_string()
  let exp_reparsed = Expires::parse(exp_header).unwrap()
  let orig_date = exp_orig.date()
  let rep_date = exp_reparsed.date()
  if orig_date.year() == rep_date.year() &&
    orig_date.month() == rep_date.month() &&
    orig_date.day() == rep_date.day() {
    println("cache.mbt: Expires roundtrip OK")
  } else {
    println("cache.mbt: Expires roundtrip FAILED")
  }

  // Test CacheControl with all delta-seconds directives
  let cc_all = CacheControl::parse(
    "max-age=100, s-maxage=200, max-stale=300, min-fresh=400, stale-while-revalidate=500, stale-if-error=600",
  ).unwrap()
  let test_all = match cc_all.max_age() {
    Some(100) =>
      match cc_all.s_maxage() {
        Some(200) =>
          match cc_all.max_stale() {
            Some(300) =>
              match cc_all.min_fresh() {
                Some(400) =>
                  match cc_all.stale_while_revalidate() {
                    Some(500) =>
                      match cc_all.stale_if_error() {
                        Some(600) => true
                        _ => false
                      }
                    _ => false
                  }
                _ => false
              }
            _ => false
          }
        _ => false
      }
    _ => false
  }
  if test_all {
    println("cache.mbt: All delta-seconds directives OK")
  } else {
    println("cache.mbt: All delta-seconds directives FAILED")
  }

  // Test CacheControl with all boolean flags
  let cc_flags = CacheControl::parse(
    "no-cache, no-store, no-transform, only-if-cached, must-revalidate, proxy-revalidate, must-understand, public, private, immutable",
  ).unwrap()
  let test_flags = cc_flags.is_no_cache() &&
    cc_flags.is_no_store() &&
    cc_flags.is_no_transform() &&
    cc_flags.is_only_if_cached() &&
    cc_flags.is_must_revalidate() &&
    cc_flags.is_proxy_revalidate() &&
    cc_flags.is_must_understand() &&
    cc_flags.is_public() &&
    cc_flags.is_private() &&
    cc_flags.is_immutable()
  if test_flags {
    println("cache.mbt: All boolean flags OK")
  } else {
    println("cache.mbt: All boolean flags FAILED")
  }
  println("cache.mbt: All tests completed")
}

///|
fn cc_string_contains(s : String, substr : String) -> Bool {
  if substr.length() == 0 {
    return true
  }
  if substr.length() > s.length() {
    return false
  }
  let mut idx = 0
  while idx <= s.length() - substr.length() {
    let mut is_match = true
    let mut j = 0
    while j < substr.length() {
      if s[idx + j] != substr[j] {
        is_match = false
        break
      }
      j = j + 1
    }
    if is_match {
      return true
    }
    idx = idx + 1
  }
  false
}
