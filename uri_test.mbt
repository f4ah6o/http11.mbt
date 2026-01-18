///|
fn init {
  // Test percent encoding
  let encoded = percent_encode("hello world")
  if encoded == "hello%20world" {
    println("uri.mbt: percent_encode basic OK")
  } else {
    println("uri.mbt: percent_encode basic FAILED")
  }

  let encoded2 = percent_encode("foo=bar")
  if encoded2 == "foo%3Dbar" {
    println("uri.mbt: percent_encode with = OK")
  } else {
    println("uri.mbt: percent_encode with = FAILED")
  }

  // Test percent decoding
  match percent_decode("hello%20world") {
    Ok(decoded) => {
      if decoded == "hello world" {
        println("uri.mbt: percent_decode basic OK")
      } else {
        println("uri.mbt: percent_decode basic FAILED")
      }
    }
    Err(_) => println("uri.mbt: percent_decode basic FAILED")
  }

  // Test invalid percent encoding
  match percent_decode("%") {
    Ok(_) => println("uri.mbt: invalid percent decode FAILED")
    Err(_) => println("uri.mbt: invalid percent decode OK")
  }

  // Test URI parsing - full URL
  match Uri::parse("https://example.com:8080/path?query=value#fragment") {
    Ok(uri) => {
      let scheme = uri.scheme()
      let host = uri.host()
      let port = uri.port()
      let path = uri.path()
      let query = uri.query()
      let fragment = uri.fragment()

      if scheme == Some("https") && host == Some("example.com") &&
         port == Some(8080) && path == "/path" &&
         query == Some("query=value") && fragment == Some("fragment") {
        println("uri.mbt: full URI parse OK")
      } else {
        println("uri.mbt: full URI parse FAILED")
      }
    }
    Err(_) => println("uri.mbt: full URI parse FAILED")
  }

  // Test URI parsing - simple
  match Uri::parse("http://example.com") {
    Ok(uri) => {
      if uri.scheme() == Some("http") && uri.host() == Some("example.com") &&
         uri.port() == None && uri.path() == "" {
        println("uri.mbt: simple URI parse OK")
      } else {
        println("uri.mbt: simple URI parse FAILED")
      }
    }
    Err(_) => println("uri.mbt: simple URI parse FAILED")
  }

  // Test URI parsing - path only
  match Uri::parse("/path/to/resource") {
    Ok(uri) => {
      if uri.scheme() == None && uri.host() == None && uri.path() == "/path/to/resource" {
        println("uri.mbt: path-only URI parse OK")
      } else {
        println("uri.mbt: path-only URI parse FAILED")
      }
    }
    Err(_) => println("uri.mbt: path-only URI parse FAILED")
  }

  // Test URI parsing - relative
  match Uri::parse("../other/path") {
    Ok(uri) => {
      if uri.scheme() == None && uri.is_relative() && uri.path() == "../other/path" {
        println("uri.mbt: relative URI parse OK")
      } else {
        println("uri.mbt: relative URI parse FAILED")
      }
    }
    Err(_) => println("uri.mbt: relative URI parse FAILED")
  }

  // Test origin form
  match Uri::parse("http://example.com/path?query") {
    Ok(uri) => {
      let p = uri.path()
      let q = uri.query()
      if p == "/path" {
        println("uri.mbt: path extraction OK")
      } else {
        println("uri.mbt: path extraction FAILED")
      }
      match q {
        Some("query") => println("uri.mbt: query extraction OK")
        _ => println("uri.mbt: query extraction FAILED")
      }
      let origin = uri.origin_form()
      if origin == "/path?query" {
        println("uri.mbt: origin_form with query OK")
      } else {
        println("uri.mbt: origin_form with query FAILED")
      }
    }
    Err(_) => println("uri.mbt: origin_form with query FAILED")
  }

  match Uri::parse("http://example.com") {
    Ok(uri) => {
      if uri.origin_form() == "/" {
        println("uri.mbt: origin_form without query OK")
      } else {
        println("uri.mbt: origin_form without query FAILED")
      }
    }
    Err(_) => println("uri.mbt: origin_form without query FAILED")
  }

  // Test empty input
  match Uri::parse("") {
    Ok(_) => println("uri.mbt: empty parse FAILED")
    Err(_) => println("uri.mbt: empty parse OK")
  }

  println("uri.mbt: All basic tests completed")
}
