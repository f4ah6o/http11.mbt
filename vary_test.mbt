///|
fn init {
  // Test Vary "*"
  match Vary::parse("*") {
    Ok(vary) => {
      if vary.is_any() {
        println("vary.mbt: Vary * OK")
      } else {
        println("vary.mbt: Vary * FAILED")
      }
    }
    Err(_) => println("vary.mbt: Vary * FAILED")
  }

  // Test Vary with fields
  match Vary::parse("Accept-Encoding, User-Agent") {
    Ok(vary) => {
      let fields = vary.fields()
      if !vary.is_any() && fields.length() == 2 {
        println("vary.mbt: Vary fields OK")
      } else {
        println("vary.mbt: Vary fields FAILED")
      }
    }
    Err(_) => println("vary.mbt: Vary fields FAILED")
  }

  // Test empty input
  match Vary::parse("") {
    Ok(_) => println("vary.mbt: empty input FAILED")
    Err(_) => println("vary.mbt: empty input OK")
  }

  // Test invalid token
  match Vary::parse("bad value") {
    Ok(_) => println("vary.mbt: invalid token FAILED")
    Err(_) => println("vary.mbt: invalid token OK")
  }

  // Test to_string
  match Vary::parse("Accept-Encoding, User-Agent") {
    Ok(vary) => {
      let str = vary.to_string()
      if str == "accept-encoding, user-agent" {
        println("vary.mbt: to_string OK")
      } else {
        println("vary.mbt: to_string FAILED")
      }
    }
    Err(_) => println("vary.mbt: to_string FAILED")
  }

  println("vary.mbt: All basic tests completed")
}
