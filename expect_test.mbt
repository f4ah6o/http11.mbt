///|
fn init {
  // Test simple 100-continue
  match Expect::parse("100-continue") {
    Ok(exp) => {
      if exp.has_100_continue() && exp.items().length() == 1 {
        println("expect.mbt: simple 100-continue OK")
      } else {
        println("expect.mbt: simple 100-continue FAILED")
      }
    }
    Err(_) => println("expect.mbt: simple 100-continue FAILED")
  }

  // Test extension
  match Expect::parse("foo=bar, 100-continue") {
    Ok(exp) => {
      if exp.items().length() == 2 {
        let first = exp.items()[0]
        if first.token() == "foo" && first.value() == Some("bar") {
          println("expect.mbt: extension parse OK")
        } else {
          println("expect.mbt: extension parse FAILED")
        }
      } else {
        println("expect.mbt: extension parse FAILED")
      }
    }
    Err(_) => println("expect.mbt: extension parse FAILED")
  }

  // Test quoted value
  match Expect::parse("token=\"value\"") {
    Ok(exp) => {
      let first = exp.items()[0]
      if first.value() == Some("value") {
        println("expect.mbt: quoted value OK")
      } else {
        println("expect.mbt: quoted value FAILED")
      }
    }
    Err(_) => println("expect.mbt: quoted value FAILED")
  }

  // Test empty input
  match Expect::parse("") {
    Ok(_) => println("expect.mbt: empty input FAILED")
    Err(_) => println("expect.mbt: empty input OK")
  }

  // Test invalid token
  match Expect::parse("bad value") {
    Ok(_) => println("expect.mbt: invalid token FAILED")
    Err(_) => println("expect.mbt: invalid token OK")
  }

  // Test token=
  match Expect::parse("token=") {
    Ok(_) => println("expect.mbt: empty value FAILED")
    Err(_) => println("expect.mbt: empty value OK")
  }

  // Test to_string
  match Expect::parse("foo=bar, 100-continue") {
    Ok(exp) => {
      if exp.to_string() == "foo=bar, 100-continue" {
        println("expect.mbt: to_string OK")
      } else {
        println("expect.mbt: to_string FAILED")
      }
    }
    Err(_) => println("expect.mbt: to_string FAILED")
  }

  // Test empty value round-trip
  match Expect::parse("token=\"\"") {
    Ok(exp) => {
      let first = exp.items()[0]
      if first.value() == Some("") {
        println("expect.mbt: empty value OK")
      } else {
        println("expect.mbt: empty value FAILED")
      }
    }
    Err(_) => println("expect.mbt: empty value FAILED")
  }

  println("expect.mbt: All basic tests completed")
}
