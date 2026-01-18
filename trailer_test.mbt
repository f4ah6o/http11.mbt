///|
fn init {
  // Test Trailer with fields
  match Trailer::parse("Expires, X-Test") {
    Ok(trailer) => {
      let fields = trailer.fields()
      if fields.length() == 2 {
        println("trailer.mbt: Trailer fields OK")
      } else {
        println("trailer.mbt: Trailer fields FAILED")
      }
    }
    Err(_) => println("trailer.mbt: Trailer fields FAILED")
  }

  // Test empty input
  match Trailer::parse("") {
    Ok(_) => println("trailer.mbt: empty input FAILED")
    Err(_) => println("trailer.mbt: empty input OK")
  }

  // Test invalid token
  match Trailer::parse("bad value") {
    Ok(_) => println("trailer.mbt: invalid token FAILED")
    Err(_) => println("trailer.mbt: invalid token OK")
  }

  // Test to_string
  match Trailer::parse("Expires, X-Test") {
    Ok(trailer) => {
      let str = trailer.to_string()
      if str == "expires, x-test" {
        println("trailer.mbt: to_string OK")
      } else {
        println("trailer.mbt: to_string FAILED")
      }
    }
    Err(_) => println("trailer.mbt: to_string FAILED")
  }

  println("trailer.mbt: All basic tests completed")
}
