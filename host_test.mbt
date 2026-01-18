///|
fn init {
  // Test hostname parsing
  match Host::parse("example.com") {
    Ok(host) =>
      if host.host() == "example.com" && host.port() == None {
        println("host.mbt: hostname parse OK")
      } else {
        println("host.mbt: hostname parse FAILED")
      }
    Err(_) => println("host.mbt: hostname parse FAILED")
  }

  // Test hostname with port
  match Host::parse("example.com:8080") {
    Ok(host) =>
      if host.host() == "example.com" && host.port() == Some(8080) {
        println("host.mbt: hostname with port OK")
      } else {
        println("host.mbt: hostname with port FAILED")
      }
    Err(_) => println("host.mbt: hostname with port FAILED")
  }

  // Test IPv4
  match Host::parse("127.0.0.1") {
    Ok(host) =>
      if host.host() == "127.0.0.1" && host.port() == None {
        println("host.mbt: IPv4 parse OK")
      } else {
        println("host.mbt: IPv4 parse FAILED")
      }
    Err(_) => println("host.mbt: IPv4 parse FAILED")
  }

  // Test IPv6
  match Host::parse("[::1]") {
    Ok(host) =>
      if host.is_ipv6() && host.host() == "[::1]" {
        println("host.mbt: IPv6 parse OK")
      } else {
        println("host.mbt: IPv6 parse FAILED")
      }
    Err(_) => println("host.mbt: IPv6 parse FAILED")
  }

  // Test IPv6 with port
  match Host::parse("[::1]:8080") {
    Ok(host) =>
      if host.is_ipv6() && host.port() == Some(8080) {
        println("host.mbt: IPv6 with port OK")
      } else {
        println("host.mbt: IPv6 with port FAILED")
      }
    Err(_) => println("host.mbt: IPv6 with port FAILED")
  }

  // Test invalid inputs
  match Host::parse("") {
    Ok(_) => println("host.mbt: empty input FAILED")
    Err(_) => println("host.mbt: empty input OK")
  }
  match Host::parse("example.com:") {
    Ok(_) => println("host.mbt: trailing colon FAILED")
    Err(_) => println("host.mbt: trailing colon OK")
  }
  match Host::parse("example.com:abc") {
    Ok(_) => println("host.mbt: non-numeric port FAILED")
    Err(_) => println("host.mbt: non-numeric port OK")
  }
  match Host::parse("exa mple.com") {
    Ok(_) => println("host.mbt: whitespace FAILED")
    Err(_) => println("host.mbt: whitespace OK")
  }

  // Test to_string
  match Host::parse("example.com:8080") {
    Ok(host) =>
      if host.to_string() == "example.com:8080" {
        println("host.mbt: to_string OK")
      } else {
        println("host.mbt: to_string FAILED")
      }
    Err(_) => println("host.mbt: to_string FAILED")
  }
  match Host::parse("example.com") {
    Ok(host) =>
      if host.to_string() == "example.com" {
        println("host.mbt: to_string without port OK")
      } else {
        println("host.mbt: to_string without port FAILED")
      }
    Err(_) => println("host.mbt: to_string without port FAILED")
  }
  println("host.mbt: All basic tests completed")
}
