///|
/// Accept-Language header
pub(all) struct AcceptLanguage {
  items : Array[LanguageRange]
} derive(Eq)

///|
pub fn AcceptLanguage::parse(
  input : String,
) -> Result[AcceptLanguage, AcceptError] {
  let parse_result = acc_parse_weighted_tokens_with_validator(
    input, false, true, acc_validate_language_range,
  )
  match parse_result {
    Err(e) => Err(e)
    Ok(pairs) => {
      let mut items : Array[LanguageRange] = []
      let mut idx = 0
      while idx < pairs.length() {
        let (value, q) = pairs[idx]
        let new_items = []
        let mut j = 0
        while j < items.length() {
          new_items.push(items[j])
          j = j + 1
        }
        new_items.push({ language: value, q })
        items = new_items
        idx = idx + 1
      }
      Ok({ items, })
    }
  }
}

///|
pub fn AcceptLanguage::items(self : AcceptLanguage) -> Array[LanguageRange] {
  self.items
}

///|
/// Language range for Accept-Language
pub(all) struct LanguageRange {
  language : String
  q : QValue
} derive(Eq)

///|
pub fn LanguageRange::language(self : LanguageRange) -> String {
  self.language
}

///|
pub fn LanguageRange::qvalue(self : LanguageRange) -> QValue {
  self.q
}

///|
pub fn LanguageRange::to_string(self : LanguageRange) -> String {
  if self.q.value < 1000 {
    self.language + "; q=" + self.q.to_string()
  } else {
    self.language
  }
}
