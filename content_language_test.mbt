///|
fn init {
  // Test parse simple language tag
  let cl1 = ContentLanguage::parse("en").unwrap()
  if cl1.tags().length() == 1 && cl1.tags()[0] == "en" {
    println("content_language.mbt: Simple parse OK")
  } else {
    println("content_language.mbt: Simple parse FAILED")
  }

  // Test parse multiple language tags
  let cl2 = ContentLanguage::parse("en-US, ja").unwrap()
  if cl2.tags().length() == 2 && cl2.tags()[0] == "en-US" && cl2.tags()[1] == "ja" {
    println("content_language.mbt: Multiple tags parse OK")
  } else {
    println("content_language.mbt: Multiple tags parse FAILED")
  }

  // Test to_string
  let cl3 = ContentLanguage::parse("en-US, ja").unwrap()
  let str3 = cl3.to_string()
  if str3 == "en-US, ja" {
    println("content_language.mbt: to_string OK")
  } else {
    println("content_language.mbt: to_string FAILED: got " + str3)
  }

  // Test empty input
  let cl4 = ContentLanguage::parse("")
  match cl4 {
    Ok(_) => println("content_language.mbt: Empty input FAILED")
    Err(Empty) => println("content_language.mbt: Empty input OK")
    Err(_) => println("content_language.mbt: Empty input wrong error")
  }

  // Test invalid tag (trailing hyphen)
  let cl5 = ContentLanguage::parse("en-")
  match cl5 {
    Ok(_) => println("content_language.mbt: Invalid tag (trailing hyphen) FAILED")
    Err(_) => println("content_language.mbt: Invalid tag (trailing hyphen) OK")
  }

  // Test invalid tag (double hyphen)
  let cl6 = ContentLanguage::parse("en--us")
  match cl6 {
    Ok(_) => println("content_language.mbt: Invalid tag (double hyphen) FAILED")
    Err(_) => println("content_language.mbt: Invalid tag (double hyphen) OK")
  }

  // Test valid tag with multiple subtags
  let cl7 = ContentLanguage::parse("zh-Hans-CN").unwrap()
  if cl7.tags().length() == 1 && cl7.tags()[0] == "zh-Hans-CN" {
    println("content_language.mbt: Multiple subtags OK")
  } else {
    println("content_language.mbt: Multiple subtags FAILED")
  }

  // Test trailing comma handling
  let cl8 = ContentLanguage::parse("en,")
  match cl8 {
    Ok(cl) => {
      if cl.tags().length() == 1 && cl.tags()[0] == "en" {
        println("content_language.mbt: Trailing comma OK")
      } else {
        println("content_language.mbt: Trailing comma FAILED")
      }
    }
    Err(_) => println("content_language.mbt: Trailing comma FAILED")
  }

  // Test case preservation
  let cl9 = ContentLanguage::parse("en-US").unwrap()
  if cl9.tags()[0] == "en-US" {
    println("content_language.mbt: Case preservation OK")
  } else {
    println("content_language.mbt: Case preservation FAILED")
  }

  println("content_language.mbt: All tests completed")
}
