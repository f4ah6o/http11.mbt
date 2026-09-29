///|
fn init {
  // Test basic ETag parsing
  let etag1 = @http11.EntityTag::parse("\"abc123\"").unwrap()
  let str1 = etag1.to_string()
  if str1 == "\"abc123\"" {
    println("etag.mbt: Strong ETag parse OK")
  } else {
    println("etag.mbt: Strong ETag parse FAILED")
  }

  // Test weak ETag parsing
  let etag2 = @http11.EntityTag::parse("W/\"xyz789\"").unwrap()
  let str2 = etag2.to_string()
  if str2 == "W/\"xyz789\"" && etag2.is_weak() {
    println("etag.mbt: Weak ETag parse OK")
  } else {
    println("etag.mbt: Weak ETag parse FAILED")
  }

  // Test strong constructor
  let etag3 = @http11.EntityTag::strong("mytag").unwrap()
  if !etag3.is_weak() && etag3.tag() == "mytag" {
    println("etag.mbt: Strong constructor OK")
  } else {
    println("etag.mbt: Strong constructor FAILED")
  }

  // Test weak constructor
  let etag4 = @http11.EntityTag::weak("mytag").unwrap()
  if etag4.is_weak() && etag4.tag() == "mytag" {
    println("etag.mbt: Weak constructor OK")
  } else {
    println("etag.mbt: Weak constructor FAILED")
  }

  // Test strong compare
  let strong1 = @http11.EntityTag::strong("same").unwrap()
  let strong2 = @http11.EntityTag::strong("same").unwrap()
  let weak = @http11.EntityTag::weak("same").unwrap()
  if strong1.strong_compare(strong2) && !strong1.strong_compare(weak) {
    println("etag.mbt: Strong compare OK")
  } else {
    println("etag.mbt: Strong compare FAILED")
  }

  // Test weak compare
  if strong1.weak_compare(weak) && weak.weak_compare(strong1) {
    println("etag.mbt: Weak compare OK")
  } else {
    println("etag.mbt: Weak compare FAILED")
  }

  // Test ETagList wildcard
  let list1 = @http11.parse_etag_list("*").unwrap()
  if list1.is_any() {
    println("etag.mbt: ETagList wildcard OK")
  } else {
    println("etag.mbt: ETagList wildcard FAILED")
  }

  // Test ETagList multiple tags
  let list2 = @http11.parse_etag_list("\"a\", \"b\", W/\"c\"").unwrap()
  let tag_a = @http11.EntityTag::strong("a").unwrap()
  let tag_c = @http11.EntityTag::strong("c").unwrap()
  if list2.contains_strong(tag_a) && !list2.contains_strong(tag_c) {
    println("etag.mbt: ETagList contains_strong OK")
  } else {
    println("etag.mbt: ETagList contains_strong FAILED")
  }

  // Test ETagList contains_weak
  let tag_c_weak = @http11.EntityTag::weak("c").unwrap()
  if list2.contains_weak(tag_c_weak) {
    println("etag.mbt: ETagList contains_weak OK")
  } else {
    println("etag.mbt: ETagList contains_weak FAILED")
  }

  // Test invalid ETag (missing quotes)
  let invalid = @http11.EntityTag::parse("noquotes")
  match invalid {
    Ok(_) => println("etag.mbt: Invalid ETag FAILED")
    Err(_) => println("etag.mbt: Invalid ETag OK")
  }

  // Test empty input
  let empty = @http11.EntityTag::parse("")
  match empty {
    Ok(_) => println("etag.mbt: Empty parse FAILED")
    Err(_) => println("etag.mbt: Empty parse OK")
  }
  println("etag.mbt: All basic tests completed")
}
