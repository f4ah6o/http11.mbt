///|
/// Accept-Charset header
pub(all) struct AcceptCharset {
  items : Array[CharsetRange]
} derive(Eq)

///|
pub fn AcceptCharset::parse(
  input : String,
) -> Result[AcceptCharset, AcceptError] {
  let parse_result = acc_parse_weighted_tokens(input, true, true)
  match parse_result {
    Err(e) => Err(e)
    Ok(pairs) => {
      let mut items : Array[CharsetRange] = []
      let mut idx = 0
      while idx < pairs.length() {
        let (value, q) = pairs[idx]
        let new_items = []
        let mut j = 0
        while j < items.length() {
          new_items.push(items[j])
          j = j + 1
        }
        new_items.push({ charset: value, q })
        items = new_items
        idx = idx + 1
      }
      Ok({ items, })
    }
  }
}

///|
pub fn AcceptCharset::items(self : AcceptCharset) -> Array[CharsetRange] {
  self.items
}

///|
/// Charset range for Accept-Charset
pub(all) struct CharsetRange {
  charset : String
  q : QValue
} derive(Eq)

///|
pub fn CharsetRange::charset(self : CharsetRange) -> String {
  self.charset
}

///|
pub fn CharsetRange::qvalue(self : CharsetRange) -> QValue {
  self.q
}

///|
pub fn CharsetRange::to_string(self : CharsetRange) -> String {
  if self.q.value < 1000 {
    self.charset + "; q=" + self.q.to_string()
  } else {
    self.charset
  }
}
