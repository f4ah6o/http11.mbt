///|
fn init {
  println("range.mbt: init started")
  // Test parse single range
  match Range::parse("bytes=0-499") {
    Ok(range1) => {
      println("range.mbt: Parse OK")
    }
    Err(_) => println("range.mbt: Parse ERROR")
  }
}
