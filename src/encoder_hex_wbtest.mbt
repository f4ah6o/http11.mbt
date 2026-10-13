///|
/// The public chunk encoder supplies an array length, so this private helper's
/// domain is nonnegative Int32. Compare with core's independent radix formatter,
/// rather than copying the implementation or relying on a self round-trip.
test "hex size agrees with core radix oracle" {
  @quickcheck.check(
    (n : Int32) => int_to_hex(n) == n.to_string(radix=16),
    filter=n => n >= 0,
    count=2000,
    max_size=2147483647,
    max_shrinks=1000,
    seed=20261012,
  )
}

///|
test "hex size zero and radix boundaries" {
  for
    (n, expected) in [
      (0, "0"),
      (1, "1"),
      (15, "f"),
      (16, "10"),
      (17, "11"),
      (255, "ff"),
      (256, "100"),
      (257, "101"),
      (4095, "fff"),
      (4096, "1000"),
      (4097, "1001"),
      (65535, "ffff"),
      (65536, "10000"),
      (65537, "10001"),
      (1048575, "fffff"),
      (1048576, "100000"),
      (1048577, "100001"),
      (16777215, "ffffff"),
      (16777216, "1000000"),
      (16777217, "1000001"),
      (268435455, "fffffff"),
      (268435456, "10000000"),
      (268435457, "10000001"),
      (2147483647, "7fffffff"),
    ] {
    assert_eq(int_to_hex(n), expected)
  }
}
