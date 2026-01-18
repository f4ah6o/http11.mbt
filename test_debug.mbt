fn init {
  let test_str = "bytes=0-499"
  let eq_pos = rg_find_char(test_str, 61)
  match eq_pos {
    Some(pos) => println("Found = at position: " + rg_u64_to_string(pos.to_uint64()))
    None => println("NOT FOUND")
  }
}
