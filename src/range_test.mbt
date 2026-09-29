///|
fn init {
  println("range.mbt: init started")
  // Test parse single range
  match @http11.Range::parse("bytes=0-499") {
    Ok(_) => println("range.mbt: Parse OK")
    Err(_) => println("range.mbt: Parse ERROR")
  }
}
