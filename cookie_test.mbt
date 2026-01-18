  // Test SameSite::to_string
  if SameSite::Strict.to_string() == "Strict" &&
     SameSite::Lax.to_string() == "Lax" &&
     SameSiteNone.to_string() == "None" {
    println("cookie.mbt: SameSite to_string OK")
  } else {
    println("cookie.mbt: SameSite to_string FAILED")
  }
