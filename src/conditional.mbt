///|
/// Conditional request header parsing errors (RFC 9110 Section 13)
pub(all) enum ConditionalError {
  Empty
  InvalidFormat
  ETagError
  DateError
} derive(Show, Eq)

///|
/// If-Match header (RFC 9110 Section 13.1.1)
pub(all) struct IfMatch {
  etags : ETagList
} derive(Eq)

///|
pub fn IfMatch::parse(input : String) -> Result[IfMatch, ConditionalError] {
  let parse_result = parse_etag_list(input)
  match parse_result {
    Ok(list) => Ok({ etags: list })
    Err(_) => Err(ETagError)
  }
}

///|
pub fn IfMatch::is_any(self : IfMatch) -> Bool {
  self.etags.is_any()
}

///|
pub fn IfMatch::matches(self : IfMatch, etag : EntityTag) -> Bool {
  self.etags.contains_strong(etag)
}

///|
pub fn IfMatch::etags(self : IfMatch) -> ETagList {
  self.etags
}

///|
pub fn IfMatch::to_string(self : IfMatch) -> String {
  self.etags.to_string()
}

///|
/// If-None-Match header (RFC 9110 Section 13.1.2)
pub(all) struct IfNoneMatch {
  etags : ETagList
} derive(Eq)

///|
pub fn IfNoneMatch::parse(
  input : String,
) -> Result[IfNoneMatch, ConditionalError] {
  let parse_result = parse_etag_list(input)
  match parse_result {
    Ok(list) => Ok({ etags: list })
    Err(_) => Err(ETagError)
  }
}

///|
pub fn IfNoneMatch::is_any(self : IfNoneMatch) -> Bool {
  self.etags.is_any()
}

///|
pub fn IfNoneMatch::matches(self : IfNoneMatch, etag : EntityTag) -> Bool {
  !self.etags.contains_weak(etag)
}

///|
pub fn IfNoneMatch::etags(self : IfNoneMatch) -> ETagList {
  self.etags
}

///|
pub fn IfNoneMatch::to_string(self : IfNoneMatch) -> String {
  self.etags.to_string()
}

///|
/// If-Modified-Since header (RFC 9110 Section 13.1.3)
pub(all) struct IfModifiedSince {
  date : HttpDate
} derive(Eq)

///|
pub fn IfModifiedSince::parse(
  input : String,
) -> Result[IfModifiedSince, ConditionalError] {
  let parse_result = HttpDate::parse(input)
  match parse_result {
    Ok(d) => Ok({ date: d })
    Err(_) => Err(DateError)
  }
}

///|
pub fn IfModifiedSince::date(self : IfModifiedSince) -> HttpDate {
  self.date
}

///|
pub fn IfModifiedSince::to_string(self : IfModifiedSince) -> String {
  self.date.to_string()
}

///|
/// If-Unmodified-Since header (RFC 9110 Section 13.1.4)
pub(all) struct IfUnmodifiedSince {
  date : HttpDate
} derive(Eq)

///|
pub fn IfUnmodifiedSince::parse(
  input : String,
) -> Result[IfUnmodifiedSince, ConditionalError] {
  let parse_result = HttpDate::parse(input)
  match parse_result {
    Ok(d) => Ok({ date: d })
    Err(_) => Err(DateError)
  }
}

///|
pub fn IfUnmodifiedSince::date(self : IfUnmodifiedSince) -> HttpDate {
  self.date
}

///|
pub fn IfUnmodifiedSince::to_string(self : IfUnmodifiedSince) -> String {
  self.date.to_string()
}

///|
/// If-Range header (RFC 9110 Section 13.1.5)
pub(all) enum IfRange {
  ETag(EntityTag)
  Date(HttpDate)
} derive(Eq)

///|
pub fn IfRange::parse(input : String) -> Result[IfRange, ConditionalError] {
  let s = cond_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }

  // Check if it starts with " or W/ (ETag)
  let ch = cond_char_at(s, 0)
  if ch == 34 { // "
    let parse_result = EntityTag::parse(s)
    match parse_result {
      Ok(etag) => Ok(ETag(etag))
      Err(_) => Err(ETagError)
    }
  } else if s.length() >= 2 &&
    (ch == 87 || ch == 119) &&
    cond_char_at(s, 1) == 47 { // W/ or w/
    let parse_result = EntityTag::parse(s)
    match parse_result {
      Ok(etag) => Ok(ETag(etag))
      Err(_) => Err(ETagError)
    }
  } else {
    let parse_result = HttpDate::parse(s)
    match parse_result {
      Ok(d) => Ok(Date(d))
      Err(_) => Err(DateError)
    }
  }
}

///|
pub fn IfRange::is_etag(self : IfRange) -> Bool {
  match self {
    ETag(_) => true
    Date(_) => false
  }
}

///|
pub fn IfRange::is_date(self : IfRange) -> Bool {
  match self {
    ETag(_) => false
    Date(_) => true
  }
}

///|
pub fn IfRange::etag(self : IfRange) -> EntityTag? {
  match self {
    ETag(e) => Some(e)
    Date(_) => None
  }
}

///|
pub fn IfRange::date(self : IfRange) -> HttpDate? {
  match self {
    ETag(_) => None
    Date(d) => Some(d)
  }
}

///|
pub fn IfRange::to_string(self : IfRange) -> String {
  match self {
    ETag(e) => e.to_string()
    Date(d) => d.to_string()
  }
}

///|
/// Helper functions
///

///|
fn cond_trim_string(s : String) -> String {
  str_trim_string(s)
}

///|
fn cond_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
}
