///|
fn init {
  let date = HttpDate::parse("Sun, 06 Nov 1994 08:49:37 GMT").unwrap()
  let round = date.to_string()
  if round == "Sun, 06 Nov 1994 08:49:37 GMT" {
    println("date.mbt: Parse and round-trip OK")
  } else {
    println("date.mbt: Parse and round-trip FAILED")
  }

  // Test RFC 850 format
  let date2 = HttpDate::parse("Sunday, 06-Nov-94 08:49:37 GMT").unwrap()
  let year2 = date2.year()
  if year2 == 1994 {
    println("date.mbt: RFC850 2-digit year OK")
  } else {
    println("date.mbt: RFC 2-digit year FAILED")
  }

  // Test empty input
  let empty_result = HttpDate::parse("")
  match empty_result {
    Ok(_) => println("date.mbt: Empty parse FAILED")
    Err(_) => println("date.mbt: Empty parse OK")
  }

  // Test invalid format
  let invalid = HttpDate::parse("not a date")
  match invalid {
    Ok(_) => println("date.mbt: Invalid format FAILED")
    Err(_) => println("date.mbt: Invalid format OK")
  }
  let date3 = HttpDate::parse("Sun, 06 Nov 1994 23:59:60 GMT").unwrap()
  if date3.second() == 60 {
    println("date.mbt: Leap second OK")
  } else {
    println("date.mbt: Leap second FAILED")
  }
  println("date.mbt: All basic tests completed")
}
