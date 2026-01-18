///|
fn init {
  // Test IfMatch single
  let im1 = IfMatch::parse("\"abc\"").unwrap()
  let etag1 = EntityTag::strong("abc").unwrap()
  if im1.matches(etag1) {
    println("conditional.mbt: IfMatch single OK")
  } else {
    println("conditional.mbt: IfMatch single FAILED")
  }

  // Test IfMatch multiple
  let im2 = IfMatch::parse("\"a\", \"b\", \"c\"").unwrap()
  if im2.matches(EntityTag::strong("b").unwrap()) &&
    !im2.matches(EntityTag::strong("d").unwrap()) {
    println("conditional.mbt: IfMatch multiple OK")
  } else {
    println("conditional.mbt: IfMatch multiple FAILED")
  }

  // Test IfMatch wildcard
  let im3 = IfMatch::parse("*").unwrap()
  if im3.is_any() && im3.matches(EntityTag::strong("anything").unwrap()) {
    println("conditional.mbt: IfMatch wildcard OK")
  } else {
    println("conditional.mbt: IfMatch wildcard FAILED")
  }

  // Test IfMatch weak not matching
  let im4 = IfMatch::parse("W/\"abc\"").unwrap()
  if !im4.matches(EntityTag::strong("abc").unwrap()) {
    println("conditional.mbt: IfMatch weak not match OK")
  } else {
    println("conditional.mbt: IfMatch weak not match FAILED")
  }

  // Test IfNoneMatch single
  let inm1 = IfNoneMatch::parse("\"abc\"").unwrap()
  if !inm1.matches(EntityTag::strong("abc").unwrap()) &&
    inm1.matches(EntityTag::strong("xyz").unwrap()) {
    println("conditional.mbt: IfNoneMatch single OK")
  } else {
    println("conditional.mbt: IfNoneMatch single FAILED")
  }

  // Test IfNoneMatch wildcard
  let inm2 = IfNoneMatch::parse("*").unwrap()
  if inm2.is_any() && !inm2.matches(EntityTag::strong("anything").unwrap()) {
    println("conditional.mbt: IfNoneMatch wildcard OK")
  } else {
    println("conditional.mbt: IfNoneMatch wildcard FAILED")
  }

  // Test IfNoneMatch weak
  let inm3 = IfNoneMatch::parse("W/\"abc\"").unwrap()
  if !inm3.matches(EntityTag::strong("abc").unwrap()) {
    println("conditional.mbt: IfNoneMatch weak OK")
  } else {
    println("conditional.mbt: IfNoneMatch weak FAILED")
  }

  // Test IfModifiedSince
  let ims = IfModifiedSince::parse("Sun, 06 Nov 1994 08:49:37 GMT").unwrap()
  let d1 = ims.date()
  if d1.day() == 6 && d1.month() == 11 && d1.year() == 1994 {
    println("conditional.mbt: IfModifiedSince OK")
  } else {
    println("conditional.mbt: IfModifiedSince FAILED")
  }

  // Test IfUnmodifiedSince
  let ius = IfUnmodifiedSince::parse("Sun, 06 Nov 1994 08:49:37 GMT").unwrap()
  let d2 = ius.date()
  if d2.day() == 6 {
    println("conditional.mbt: IfUnmodifiedSince OK")
  } else {
    println("conditional.mbt: IfUnmodifiedSince FAILED")
  }

  // Test IfRange ETag
  let ir1 = IfRange::parse("\"abc123\"").unwrap()
  if ir1.is_etag() && ir1.etag().unwrap().tag() == "abc123" {
    println("conditional.mbt: IfRange ETag OK")
  } else {
    println("conditional.mbt: IfRange ETag FAILED")
  }

  // Test IfRange weak ETag
  let ir2 = IfRange::parse("W/\"abc123\"").unwrap()
  if ir2.is_etag() && ir2.etag().unwrap().is_weak() {
    println("conditional.mbt: IfRange weak ETag OK")
  } else {
    println("conditional.mbt: IfRange weak ETag FAILED")
  }

  // Test IfRange date
  let ir3 = IfRange::parse("Sun, 06 Nov 1994 08:49:37 GMT").unwrap()
  if ir3.is_date() && ir3.date().unwrap().day() == 6 {
    println("conditional.mbt: IfRange date OK")
  } else {
    println("conditional.mbt: IfRange date FAILED")
  }

  // Test empty input
  let err1 = IfMatch::parse("")
  match err1 {
    Ok(_) => println("conditional.mbt: Empty input FAILED")
    Err(_) => println("conditional.mbt: Empty input OK")
  }

  // Test to_string
  let im5 = IfMatch::parse("\"a\", \"b\"").unwrap()
  if im5.to_string() == "\"a\", \"b\"" {
    println("conditional.mbt: IfMatch to_string OK")
  } else {
    println("conditional.mbt: IfMatch to_string FAILED")
  }
  let ir4 = IfRange::parse("\"abc\"").unwrap()
  if ir4.to_string() == "\"abc\"" {
    println("conditional.mbt: IfRange to_string OK")
  } else {
    println("conditional.mbt: IfRange to_string FAILED")
  }
  println("conditional.mbt: All tests completed")
}
