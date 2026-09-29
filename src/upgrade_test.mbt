///|
fn init {
  // Test simple protocol
  match @http11.Upgrade::parse("websocket") {
    Ok(upgrade) =>
      if upgrade.has_protocol("websocket") && upgrade.protocols().length() == 1 {
        println("upgrade.mbt: simple protocol OK")
      } else {
        println("upgrade.mbt: simple protocol FAILED")
      }
    Err(_) => println("upgrade.mbt: simple protocol FAILED")
  }

  // Test with version
  match @http11.Upgrade::parse("h2c/1.0, websocket") {
    Ok(upgrade) => {
      let procs = upgrade.protocols()
      if procs.length() == 2 {
        let first = procs[0]
        if first.name() == "h2c" && first.version() == Some("1.0") {
          println("upgrade.mbt: with version OK")
        } else {
          println("upgrade.mbt: with version FAILED")
        }
      } else {
        println("upgrade.mbt: with version FAILED")
      }
    }
    Err(_) => println("upgrade.mbt: with version FAILED")
  }

  // Test empty input
  match @http11.Upgrade::parse("") {
    Ok(_) => println("upgrade.mbt: empty input FAILED")
    Err(_) => println("upgrade.mbt: empty input OK")
  }

  // Test invalid token
  match @http11.Upgrade::parse("bad value") {
    Ok(_) => println("upgrade.mbt: invalid token FAILED")
    Err(_) => println("upgrade.mbt: invalid token OK")
  }

  // Test websocket/ (empty version)
  match @http11.Upgrade::parse("websocket/") {
    Ok(_) => println("upgrade.mbt: empty version FAILED")
    Err(_) => println("upgrade.mbt: empty version OK")
  }

  // Test websocket/1/2 (double slash)
  match @http11.Upgrade::parse("websocket/1/2") {
    Ok(_) => println("upgrade.mbt: double slash FAILED")
    Err(_) => println("upgrade.mbt: double slash OK")
  }

  // Test to_string
  match @http11.Upgrade::parse("websocket, h2c/1.0") {
    Ok(upgrade) => {
      let str = upgrade.to_string()
      if str == "websocket, h2c/1.0" {
        println("upgrade.mbt: to_string OK")
      } else {
        println("upgrade.mbt: to_string FAILED")
      }
    }
    Err(_) => println("upgrade.mbt: to_string FAILED")
  }
  println("upgrade.mbt: All basic tests completed")
}
