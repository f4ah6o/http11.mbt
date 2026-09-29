///|
fn init {
  // Test SameSite::to_string
  if @http11.SameSite::Strict.to_string() == "Strict" &&
    @http11.SameSite::Lax.to_string() == "Lax" &&
    @http11.SameSite::SameSiteNone.to_string() == "None" {
    println("cookie.mbt: SameSite to_string OK")
  } else {
    println("cookie.mbt: SameSite to_string FAILED")
  }

  // More tests would go here
  println("cookie.mbt: All basic tests completed")
}
