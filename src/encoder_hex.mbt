///|
fn int_to_hex(n : Int) -> String {
  let hex = "0123456789abcdef"
  if n == 0 {
    return "0"
  }
  let mut result = ""
  let mut num = n
  while num > 0 {
    let digit = num % 16
    result = hex[digit].to_char().unwrap().to_string() + result
    num = num / 16
  }
  result
}
