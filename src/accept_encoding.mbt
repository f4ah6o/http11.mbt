///|
/// Accept-Encoding header
pub(all) struct AcceptEncoding {
  items : Array[EncodingRange]
} derive(Eq)

///|
pub fn AcceptEncoding::parse(
  input : String,
) -> Result[AcceptEncoding, AcceptError] {
  let parse_result = acc_parse_weighted_tokens(input, true, true)
  match parse_result {
    Err(e) => Err(e)
    Ok(pairs) => {
      let mut items : Array[EncodingRange] = []
      let mut idx = 0
      while idx < pairs.length() {
        let (value, q) = pairs[idx]
        let new_items = []
        let mut j = 0
        while j < items.length() {
          new_items.push(items[j])
          j = j + 1
        }
        new_items.push({ coding: value, q })
        items = new_items
        idx = idx + 1
      }
      Ok({ items, })
    }
  }
}

///|
pub fn AcceptEncoding::items(self : AcceptEncoding) -> Array[EncodingRange] {
  self.items
}

///|
/// Encoding range for Accept-Encoding
pub(all) struct EncodingRange {
  coding : String
  q : QValue
} derive(Eq)

///|
pub fn EncodingRange::coding(self : EncodingRange) -> String {
  self.coding
}

///|
pub fn EncodingRange::qvalue(self : EncodingRange) -> QValue {
  self.q
}

///|
pub fn EncodingRange::to_string(self : EncodingRange) -> String {
  if self.q.value < 1000 {
    self.coding + "; q=" + self.q.to_string()
  } else {
    self.coding
  }
}
