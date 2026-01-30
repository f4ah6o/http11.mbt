///|
/// Accept header (RFC 9110 Section 12.5)
pub(all) struct Accept {
  items : Array[MediaRange]
} derive(Eq)

///|
pub fn Accept::parse(input : String) -> Result[Accept, AcceptError] {
  let s = acc_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = acc_split_with_quotes(s, 44) // ,
  let mut items : Array[MediaRange] = []
  let mut part_idx = 0
  while part_idx < parts.length() {
    let part = acc_trim_string(parts[part_idx])
    if part.length() > 0 {
      let parse_result = acc_parse_media_range_item(part)
      match parse_result {
        Ok(item) => {
          let new_items = []
          let mut idx = 0
          while idx < items.length() {
            new_items.push(items[idx])
            idx = idx + 1
          }
          new_items.push(item)
          items = new_items
        }
        Err(e) => return Err(e)
      }
    }
    part_idx = part_idx + 1
  }
  if items.length() == 0 {
    return Err(Empty)
  }
  Ok({ items, })
}

///|
pub fn Accept::items(self : Accept) -> Array[MediaRange] {
  self.items
}

///|
pub fn Accept::to_string(self : Accept) -> String {
  let strs = acc_map_items(self.items, fn(i) { i.to_string() })
  acc_join_strings(strs, ", ")
}

///|
/// Media range for Accept header
pub(all) struct MediaRange {
  media_type : String
  subtype : String
  parameters : Array[(String, String)]
  q : QValue
} derive(Eq)

///|
pub fn MediaRange::media_type(self : MediaRange) -> String {
  self.media_type
}

///|
pub fn MediaRange::subtype(self : MediaRange) -> String {
  self.subtype
}

///|
pub fn MediaRange::parameters(self : MediaRange) -> Array[(String, String)] {
  self.parameters
}

///|
pub fn MediaRange::qvalue(self : MediaRange) -> QValue {
  self.q
}

///|
pub fn MediaRange::to_string(self : MediaRange) -> String {
  let mut result = self.media_type + "/" + self.subtype
  let mut idx = 0
  while idx < self.parameters.length() {
    let (name, value) = self.parameters[idx]
    if acc_needs_quoting(value) {
      result = result + "; " + name + "=\"" + acc_escape_quotes(value) + "\""
    } else {
      result = result + "; " + name + "=" + value
    }
    idx = idx + 1
  }
  if self.q.value < 1000 {
    result = result + "; q=" + self.q.to_string()
  }
  result
}
