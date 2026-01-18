///|
fn init {
  // Test ContentDigest::parse
  let digest = ContentDigest::parse("sha-256=:YWJj:").unwrap()
  if digest.entries().length() == 1 {
    println("digest_fields.mbt: ContentDigest parse OK")
  } else {
    println("digest_fields.mbt: ContentDigest parse FAILED")
  }

  // Test ContentDigest::get
  match digest.get("sha-256") {
    Some(val) => {
      let bytes = val.bytes()
      if bytes.length() == 3 &&
        bytes[0].to_int() == 97 &&
        bytes[1].to_int() == 98 &&
        bytes[2].to_int() == 99 {
        println("digest_fields.mbt: ContentDigest::get OK")
      } else {
        println("digest_fields.mbt: ContentDigest::get FAILED")
      }
    }
    None => println("digest_fields.mbt: ContentDigest::get FAILED (None)")
  }

  // Test ContentDigest::to_string
  let str1 = digest.to_string()
  if str1 == "sha-256=:YWJj:" {
    println("digest_fields.mbt: ContentDigest::to_string OK")
  } else {
    println("digest_fields.mbt: ContentDigest::to_string FAILED: " + str1)
  }

  // Test empty input
  match ContentDigest::parse("") {
    Ok(_) => println("digest_fields.mbt: Empty parse FAILED")
    Err(e) =>
      match e {
        Empty => println("digest_fields.mbt: Empty parse OK")
        _ => println("digest_fields.mbt: Empty parse FAILED (wrong error)")
      }
  }

  // Test ReprDigest::parse
  let repr = ReprDigest::parse("sha-256=:YWJj:, sha-512=:Zg==:").unwrap()
  if repr.entries().length() == 2 {
    println("digest_fields.mbt: ReprDigest parse OK")
  } else {
    println("digest_fields.mbt: ReprDigest parse FAILED")
  }

  // Test WantContentDigest::parse
  let want = WantContentDigest::parse("sha-512=3, sha-256=10, unixsum=0").unwrap()
  if want.preferences().length() == 3 {
    println("digest_fields.mbt: WantContentDigest parse OK")
  } else {
    println("digest_fields.mbt: WantContentDigest parse FAILED")
  }

  // Test WantContentDigest::get
  match want.get("sha-256") {
    Some(w) =>
      if w == 10 {
        println("digest_fields.mbt: WantContentDigest::get OK")
      } else {
        println("digest_fields.mbt: WantContentDigest::get FAILED")
      }
    None => println("digest_fields.mbt: WantContentDigest::get FAILED (None)")
  }

  // Test base64 encode
  let bytes_str = "abc"
  let bytes : Array[Byte] = []
  let mut idx = 0
  while idx < bytes_str.length() {
    bytes.push(bytes_str[idx].to_int().to_byte())
    idx = idx + 1
  }
  let val = DigestValue::new(bytes)
  if val.to_string() == ":YWJj:" {
    println("digest_fields.mbt: Base64 encode OK")
  } else {
    println("digest_fields.mbt: Base64 encode FAILED")
  }

  // Test base64 decode (via DigestValue)
  match ContentDigest::parse("sha-256=:YWJj:") {
    Ok(digest) => {
      let entry = digest.get("sha-256")
      match entry {
        Some(v) =>
          if v.bytes().length() == 3 {
            println("digest_fields.mbt: Base64 decode OK")
          } else {
            println("digest_fields.mbt: Base64 decode FAILED")
          }
        None => println("digest_fields.mbt: Base64 decode FAILED (None)")
      }
    }
    Err(_) => println("digest_fields.mbt: Base64 decode FAILED (parse)")
  }
  println("digest_fields.mbt: All basic tests completed")
}
