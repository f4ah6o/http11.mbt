///|
fn init {
  // Test Accept::parse simple
  let accept1 = Accept::parse("text/html").unwrap()
  let item1 = accept1.items()[0]
  if item1.media_type() == "text" &&
    item1.subtype() == "html" &&
    item1.qvalue().value() == 1000 {
    println("accept.mbt: Accept simple parse OK")
  } else {
    println("accept.mbt: Accept simple parse FAILED")
  }

  // Test Accept::parse wildcard
  let accept2 = Accept::parse("text/*; q=0.5").unwrap()
  let item2 = accept2.items()[0]
  if item2.subtype() == "*" && item2.qvalue().value() == 500 {
    println("accept.mbt: Accept wildcard OK")
  } else {
    println("accept.mbt: Accept wildcard FAILED")
  }

  // Test Accept::parse with params
  let accept3 = Accept::parse("text/html; level=1; q=0.7").unwrap()
  let item3 = accept3.items()[0]
  if item3.parameters()[0].0 == "level" &&
    item3.parameters()[0].1 == "1" &&
    item3.qvalue().value() == 700 {
    println("accept.mbt: Accept with params OK")
  } else {
    println("accept.mbt: Accept with params FAILED")
  }

  // Test Accept::to_string
  let accept4 = Accept::parse("text/html; q=0.5").unwrap()
  let str4 = accept4.to_string()
  if str4 == "text/html; q=0.5" {
    println("accept.mbt: Accept to_string OK")
  } else {
    println("accept.mbt: Accept to_string FAILED: got " + str4)
  }

  // Test AcceptCharset::parse
  let ac = AcceptCharset::parse("utf-8, iso-8859-1;q=0.5").unwrap()
  if ac.items().length() == 2 && ac.items()[1].qvalue().value() == 500 {
    println("accept.mbt: AcceptCharset parse OK")
  } else {
    println("accept.mbt: AcceptCharset parse FAILED")
  }

  // Test AcceptEncoding::parse
  let ae = AcceptEncoding::parse("gzip, identity;q=0.2").unwrap()
  if ae.items()[0].coding() == "gzip" && ae.items()[1].qvalue().value() == 200 {
    println("accept.mbt: AcceptEncoding parse OK")
  } else {
    println("accept.mbt: AcceptEncoding parse FAILED")
  }

  // Test AcceptLanguage::parse
  let al = AcceptLanguage::parse("en-US, ja;q=0.8").unwrap()
  if al.items()[0].language() == "en-US" &&
    al.items()[1].qvalue().value() == 800 {
    println("accept.mbt: AcceptLanguage parse OK")
  } else {
    println("accept.mbt: AcceptLanguage parse FAILED")
  }

  // Test QValue::parse
  let q1 = QValue::parse("1").unwrap()
  let q2 = QValue::parse("0.5").unwrap()
  let q3 = QValue::parse("0.123").unwrap()
  if q1.value() == 1000 && q2.value() == 500 && q3.value() == 123 {
    println("accept.mbt: QValue parse OK")
  } else {
    println("accept.mbt: QValue parse FAILED")
  }

  // Test QValue::to_string
  let q4 = QValue::parse("0.500").unwrap()
  let q5 = QValue::parse("0.050").unwrap()
  let q6 = QValue::parse("0.005").unwrap()
  if q4.to_string() == "0.5" &&
    q5.to_string() == "0.05" &&
    q6.to_string() == "0.005" {
    println("accept.mbt: QValue to_string OK")
  } else {
    println("accept.mbt: QValue to_string FAILED")
  }

  // Test invalid q value
  let q_err = QValue::parse("1.5")
  match q_err {
    Ok(_) => println("accept.mbt: Invalid q value FAILED")
    Err(_) => println("accept.mbt: Invalid q value OK")
  }

  // Test empty input
  let accept_err = Accept::parse("")
  match accept_err {
    Ok(_) => println("accept.mbt: Empty input FAILED")
    Err(_) => println("accept.mbt: Empty input OK")
  }

  // Test wildcard media range
  let accept5 = Accept::parse("*/*").unwrap()
  let item5 = accept5.items()[0]
  if item5.media_type() == "*" && item5.subtype() == "*" {
    println("accept.mbt: Wildcard media range OK")
  } else {
    println("accept.mbt: Wildcard media range FAILED")
  }

  // Test wildcard charset
  let ac2 = AcceptCharset::parse("*").unwrap()
  if ac2.items()[0].charset() == "*" {
    println("accept.mbt: Wildcard charset OK")
  } else {
    println("accept.mbt: Wildcard charset FAILED")
  }
  println("accept.mbt: All tests completed")
}
