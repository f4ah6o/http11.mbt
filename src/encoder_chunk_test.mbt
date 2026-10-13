///|
/// Regression for the QuickCheck counterexample n = 1: a string code unit
/// must be rendered as the hexadecimal character, not its decimal code point.
test "chunk size one is a hexadecimal digit on the wire" {
  assert_eq(@http11.encode_chunk([b'A']), [
    b'1', b'\r', b'\n', b'A', b'\r', b'\n',
  ])
}
