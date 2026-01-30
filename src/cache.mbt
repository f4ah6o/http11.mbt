///|
/// Cache header parsing errors
pub(all) enum CacheError {
  Empty
  InvalidFormat
  InvalidNumber
  InvalidDate
} derive(Show, Eq)

///|
/// Cache-Control header (RFC 9111 Section 5.2)
pub(all) struct CacheControl {
  max_age : Int?
  s_maxage : Int?
  max_stale : Int?
  min_fresh : Int?
  stale_while_revalidate : Int?
  stale_if_error : Int?
  no_cache : Bool
  no_store : Bool
  no_transform : Bool
  only_if_cached : Bool
  must_revalidate : Bool
  proxy_revalidate : Bool
  must_understand : Bool
  public : Bool
  private : Bool
  immutable : Bool
} derive(Eq)

///|
pub fn CacheControl::new() -> CacheControl {
  {
    max_age: None,
    s_maxage: None,
    max_stale: None,
    min_fresh: None,
    stale_while_revalidate: None,
    stale_if_error: None,
    no_cache: false,
    no_store: false,
    no_transform: false,
    only_if_cached: false,
    must_revalidate: false,
    proxy_revalidate: false,
    must_understand: false,
    public: false,
    private: false,
    immutable: false,
  }
}

///|
pub fn CacheControl::parse(input : String) -> Result[CacheControl, CacheError] {
  let s = cc_trim_string(input)
  if s.length() == 0 {
    return Ok(CacheControl::new())
  }
  let mut cc = CacheControl::new()
  let parts = cc_split_string(s, ",")
  let mut idx = 0
  while idx < parts.length() {
    let directive = cc_trim_string(parts[idx])
    if directive.length() > 0 {
      let parse_result = cc_parse_directive(directive, cc)
      match parse_result {
        Ok(updated_cc) => cc = updated_cc
        Err(e) => return Err(e)
      }
    }
    idx = idx + 1
  }
  Ok(cc)
}

///|
pub fn CacheControl::with_max_age(
  self : CacheControl,
  seconds : Int,
) -> CacheControl {
  {
    max_age: Some(seconds),
    s_maxage: self.s_maxage,
    max_stale: self.max_stale,
    min_fresh: self.min_fresh,
    stale_while_revalidate: self.stale_while_revalidate,
    stale_if_error: self.stale_if_error,
    no_cache: self.no_cache,
    no_store: self.no_store,
    no_transform: self.no_transform,
    only_if_cached: self.only_if_cached,
    must_revalidate: self.must_revalidate,
    proxy_revalidate: self.proxy_revalidate,
    must_understand: self.must_understand,
    public: self.public,
    private: self.private,
    immutable: self.immutable,
  }
}

///|
pub fn CacheControl::with_s_maxage(
  self : CacheControl,
  seconds : Int,
) -> CacheControl {
  {
    max_age: self.max_age,
    s_maxage: Some(seconds),
    max_stale: self.max_stale,
    min_fresh: self.min_fresh,
    stale_while_revalidate: self.stale_while_revalidate,
    stale_if_error: self.stale_if_error,
    no_cache: self.no_cache,
    no_store: self.no_store,
    no_transform: self.no_transform,
    only_if_cached: self.only_if_cached,
    must_revalidate: self.must_revalidate,
    proxy_revalidate: self.proxy_revalidate,
    must_understand: self.must_understand,
    public: self.public,
    private: self.private,
    immutable: self.immutable,
  }
}

///|
pub fn CacheControl::with_no_cache(self : CacheControl) -> CacheControl {
  {
    max_age: self.max_age,
    s_maxage: self.s_maxage,
    max_stale: self.max_stale,
    min_fresh: self.min_fresh,
    stale_while_revalidate: self.stale_while_revalidate,
    stale_if_error: self.stale_if_error,
    no_cache: true,
    no_store: self.no_store,
    no_transform: self.no_transform,
    only_if_cached: self.only_if_cached,
    must_revalidate: self.must_revalidate,
    proxy_revalidate: self.proxy_revalidate,
    must_understand: self.must_understand,
    public: self.public,
    private: self.private,
    immutable: self.immutable,
  }
}

///|
pub fn CacheControl::with_no_store(self : CacheControl) -> CacheControl {
  {
    max_age: self.max_age,
    s_maxage: self.s_maxage,
    max_stale: self.max_stale,
    min_fresh: self.min_fresh,
    stale_while_revalidate: self.stale_while_revalidate,
    stale_if_error: self.stale_if_error,
    no_cache: self.no_cache,
    no_store: true,
    no_transform: self.no_transform,
    only_if_cached: self.only_if_cached,
    must_revalidate: self.must_revalidate,
    proxy_revalidate: self.proxy_revalidate,
    must_understand: self.must_understand,
    public: self.public,
    private: self.private,
    immutable: self.immutable,
  }
}

///|
pub fn CacheControl::with_no_transform(self : CacheControl) -> CacheControl {
  {
    max_age: self.max_age,
    s_maxage: self.s_maxage,
    max_stale: self.max_stale,
    min_fresh: self.min_fresh,
    stale_while_revalidate: self.stale_while_revalidate,
    stale_if_error: self.stale_if_error,
    no_cache: self.no_cache,
    no_store: self.no_store,
    no_transform: true,
    only_if_cached: self.only_if_cached,
    must_revalidate: self.must_revalidate,
    proxy_revalidate: self.proxy_revalidate,
    must_understand: self.must_understand,
    public: self.public,
    private: self.private,
    immutable: self.immutable,
  }
}

///|
pub fn CacheControl::with_only_if_cached(self : CacheControl) -> CacheControl {
  {
    max_age: self.max_age,
    s_maxage: self.s_maxage,
    max_stale: self.max_stale,
    min_fresh: self.min_fresh,
    stale_while_revalidate: self.stale_while_revalidate,
    stale_if_error: self.stale_if_error,
    no_cache: self.no_cache,
    no_store: self.no_store,
    no_transform: self.no_transform,
    only_if_cached: true,
    must_revalidate: self.must_revalidate,
    proxy_revalidate: self.proxy_revalidate,
    must_understand: self.must_understand,
    public: self.public,
    private: self.private,
    immutable: self.immutable,
  }
}

///|
pub fn CacheControl::with_must_revalidate(self : CacheControl) -> CacheControl {
  {
    max_age: self.max_age,
    s_maxage: self.s_maxage,
    max_stale: self.max_stale,
    min_fresh: self.min_fresh,
    stale_while_revalidate: self.stale_while_revalidate,
    stale_if_error: self.stale_if_error,
    no_cache: self.no_cache,
    no_store: self.no_store,
    no_transform: self.no_transform,
    only_if_cached: self.only_if_cached,
    must_revalidate: true,
    proxy_revalidate: self.proxy_revalidate,
    must_understand: self.must_understand,
    public: self.public,
    private: self.private,
    immutable: self.immutable,
  }
}

///|
pub fn CacheControl::with_proxy_revalidate(self : CacheControl) -> CacheControl {
  {
    max_age: self.max_age,
    s_maxage: self.s_maxage,
    max_stale: self.max_stale,
    min_fresh: self.min_fresh,
    stale_while_revalidate: self.stale_while_revalidate,
    stale_if_error: self.stale_if_error,
    no_cache: self.no_cache,
    no_store: self.no_store,
    no_transform: self.no_transform,
    only_if_cached: self.only_if_cached,
    must_revalidate: self.must_revalidate,
    proxy_revalidate: true,
    must_understand: self.must_understand,
    public: self.public,
    private: self.private,
    immutable: self.immutable,
  }
}

///|
pub fn CacheControl::with_public(self : CacheControl) -> CacheControl {
  {
    max_age: self.max_age,
    s_maxage: self.s_maxage,
    max_stale: self.max_stale,
    min_fresh: self.min_fresh,
    stale_while_revalidate: self.stale_while_revalidate,
    stale_if_error: self.stale_if_error,
    no_cache: self.no_cache,
    no_store: self.no_store,
    no_transform: self.no_transform,
    only_if_cached: self.only_if_cached,
    must_revalidate: self.must_revalidate,
    proxy_revalidate: self.proxy_revalidate,
    must_understand: self.must_understand,
    public: true,
    private: self.private,
    immutable: self.immutable,
  }
}

///|
pub fn CacheControl::with_private(self : CacheControl) -> CacheControl {
  {
    max_age: self.max_age,
    s_maxage: self.s_maxage,
    max_stale: self.max_stale,
    min_fresh: self.min_fresh,
    stale_while_revalidate: self.stale_while_revalidate,
    stale_if_error: self.stale_if_error,
    no_cache: self.no_cache,
    no_store: self.no_store,
    no_transform: self.no_transform,
    only_if_cached: self.only_if_cached,
    must_revalidate: self.must_revalidate,
    proxy_revalidate: self.proxy_revalidate,
    must_understand: self.must_understand,
    public: self.public,
    private: true,
    immutable: self.immutable,
  }
}

///|
pub fn CacheControl::with_immutable(self : CacheControl) -> CacheControl {
  {
    max_age: self.max_age,
    s_maxage: self.s_maxage,
    max_stale: self.max_stale,
    min_fresh: self.min_fresh,
    stale_while_revalidate: self.stale_while_revalidate,
    stale_if_error: self.stale_if_error,
    no_cache: self.no_cache,
    no_store: self.no_store,
    no_transform: self.no_transform,
    only_if_cached: self.only_if_cached,
    must_revalidate: self.must_revalidate,
    proxy_revalidate: self.proxy_revalidate,
    must_understand: self.must_understand,
    public: self.public,
    private: self.private,
    immutable: true,
  }
}

///|
pub fn CacheControl::max_age(self : CacheControl) -> Int? {
  self.max_age
}

///|
pub fn CacheControl::s_maxage(self : CacheControl) -> Int? {
  self.s_maxage
}

///|
pub fn CacheControl::max_stale(self : CacheControl) -> Int? {
  self.max_stale
}

///|
pub fn CacheControl::min_fresh(self : CacheControl) -> Int? {
  self.min_fresh
}

///|
pub fn CacheControl::stale_while_revalidate(self : CacheControl) -> Int? {
  self.stale_while_revalidate
}

///|
pub fn CacheControl::stale_if_error(self : CacheControl) -> Int? {
  self.stale_if_error
}

///|
pub fn CacheControl::is_no_cache(self : CacheControl) -> Bool {
  self.no_cache
}

///|
pub fn CacheControl::is_no_store(self : CacheControl) -> Bool {
  self.no_store
}

///|
pub fn CacheControl::is_no_transform(self : CacheControl) -> Bool {
  self.no_transform
}

///|
pub fn CacheControl::is_only_if_cached(self : CacheControl) -> Bool {
  self.only_if_cached
}

///|
pub fn CacheControl::is_must_revalidate(self : CacheControl) -> Bool {
  self.must_revalidate
}

///|
pub fn CacheControl::is_proxy_revalidate(self : CacheControl) -> Bool {
  self.proxy_revalidate
}

///|
pub fn CacheControl::is_must_understand(self : CacheControl) -> Bool {
  self.must_understand
}

///|
pub fn CacheControl::is_public(self : CacheControl) -> Bool {
  self.public
}

///|
pub fn CacheControl::is_private(self : CacheControl) -> Bool {
  self.private
}

///|
pub fn CacheControl::is_immutable(self : CacheControl) -> Bool {
  self.immutable
}

///|
pub fn CacheControl::is_cacheable(self : CacheControl) -> Bool {
  !self.no_store &&
  (self.public || self.max_age is Some(_) || self.s_maxage is Some(_))
}

///|
pub fn CacheControl::to_string(self : CacheControl) -> String {
  let parts : Array[String] = []
  match self.max_age {
    Some(secs) => parts.push("max-age=" + secs.to_string())
    None => ()
  }
  match self.s_maxage {
    Some(secs) => parts.push("s-maxage=" + secs.to_string())
    None => ()
  }
  match self.max_stale {
    Some(secs) =>
      if secs == 2147483647 {
        parts.push("max-stale")
      } else {
        parts.push("max-stale=" + secs.to_string())
      }
    None => ()
  }
  match self.min_fresh {
    Some(secs) => parts.push("min-fresh=" + secs.to_string())
    None => ()
  }
  match self.stale_while_revalidate {
    Some(secs) => parts.push("stale-while-revalidate=" + secs.to_string())
    None => ()
  }
  match self.stale_if_error {
    Some(secs) => parts.push("stale-if-error=" + secs.to_string())
    None => ()
  }
  if self.no_cache {
    parts.push("no-cache")
  }
  if self.no_store {
    parts.push("no-store")
  }
  if self.no_transform {
    parts.push("no-transform")
  }
  if self.only_if_cached {
    parts.push("only-if-cached")
  }
  if self.must_revalidate {
    parts.push("must-revalidate")
  }
  if self.proxy_revalidate {
    parts.push("proxy-revalidate")
  }
  if self.must_understand {
    parts.push("must-understand")
  }
  if self.public {
    parts.push("public")
  }
  if self.private {
    parts.push("private")
  }
  if self.immutable {
    parts.push("immutable")
  }
  cc_join_strings(parts, ", ")
}

///|
/// Age header (RFC 9111 Section 5.1)
pub(all) struct Age {
  seconds : Int
} derive(Eq)

///|
pub fn Age::new(seconds : Int) -> Age {
  { seconds, }
}

///|
pub fn Age::parse(input : String) -> Result[Age, CacheError] {
  let s = cc_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  match cc_parse_u64(s) {
    Some(secs) => Ok({ seconds: secs })
    None => Err(InvalidNumber)
  }
}

///|
pub fn Age::seconds(self : Age) -> Int {
  self.seconds
}

///|
pub fn Age::to_string(self : Age) -> String {
  self.seconds.to_string()
}

///|
/// Expires header (RFC 9111 Section 5.3)
pub(all) struct Expires {
  date : HttpDate
} derive(Eq)

///|
pub fn Expires::new(date : HttpDate) -> Expires {
  { date, }
}

///|
pub fn Expires::parse(input : String) -> Result[Expires, CacheError] {
  match HttpDate::parse(input) {
    Ok(date) => Ok({ date, })
    Err(_) => Err(InvalidDate)
  }
}

///|
pub fn Expires::date(self : Expires) -> HttpDate {
  self.date
}

///|
pub fn Expires::to_string(self : Expires) -> String {
  self.date.to_string()
}

///|

///|
/// Helper functions

///|

///|
fn cc_parse_directive(
  directive : String,
  cc : CacheControl,
) -> Result[CacheControl, CacheError] {
  let eq_pos = cc_find_char(directive, 61)
  match eq_pos {
    Some(pos) => {
      let name = cc_to_lower_case(
        cc_trim_string(cc_string_slice(directive, 0, pos)),
      )
      let value = cc_trim_string(cc_string_slice_from(directive, pos + 1))
      let value_unquoted = if value.length() >= 2 &&
        cc_char_at(value, 0) == 34 &&
        cc_char_at(value, value.length() - 1) == 34 {
        cc_string_slice(value, 1, value.length() - 1)
      } else {
        value
      }
      match name {
        "max-age" =>
          match cc_parse_u64(value_unquoted) {
            Some(secs) => Ok(cc_set_max_age(cc, secs))
            None => Err(InvalidNumber)
          }
        "s-maxage" =>
          match cc_parse_u64(value_unquoted) {
            Some(secs) => Ok(cc_set_s_maxage(cc, secs))
            None => Err(InvalidNumber)
          }
        "max-stale" =>
          match cc_parse_u64(value_unquoted) {
            Some(secs) => Ok(cc_set_max_stale(cc, secs))
            None => Err(InvalidNumber)
          }
        "min-fresh" =>
          match cc_parse_u64(value_unquoted) {
            Some(secs) => Ok(cc_set_min_fresh(cc, secs))
            None => Err(InvalidNumber)
          }
        "stale-while-revalidate" =>
          match cc_parse_u64(value_unquoted) {
            Some(secs) => Ok(cc_set_stale_while_revalidate(cc, secs))
            None => Err(InvalidNumber)
          }
        "stale-if-error" =>
          match cc_parse_u64(value_unquoted) {
            Some(secs) => Ok(cc_set_stale_if_error(cc, secs))
            None => Err(InvalidNumber)
          }
        _ => Ok(cc)
      }
    }
    None => {
      let name = cc_to_lower_case(directive)
      match name {
        "no-cache" => Ok(cc_set_no_cache(cc))
        "no-store" => Ok(cc_set_no_store(cc))
        "no-transform" => Ok(cc_set_no_transform(cc))
        "only-if-cached" => Ok(cc_set_only_if_cached(cc))
        "must-revalidate" => Ok(cc_set_must_revalidate(cc))
        "proxy-revalidate" => Ok(cc_set_proxy_revalidate(cc))
        "must-understand" => Ok(cc_set_must_understand(cc))
        "public" => Ok(cc_set_public(cc))
        "private" => Ok(cc_set_private(cc))
        "immutable" => Ok(cc_set_immutable(cc))
        "max-stale" => Ok(cc_set_max_stale_unlimited(cc))
        _ => Ok(cc)
      }
    }
  }
}

///|
fn cc_set_max_age(cc : CacheControl, secs : Int) -> CacheControl {
  {
    max_age: Some(secs),
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_s_maxage(cc : CacheControl, secs : Int) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: Some(secs),
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_max_stale(cc : CacheControl, secs : Int) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: Some(secs),
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_min_fresh(cc : CacheControl, secs : Int) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: Some(secs),
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_stale_while_revalidate(cc : CacheControl, secs : Int) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: Some(secs),
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_stale_if_error(cc : CacheControl, secs : Int) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: Some(secs),
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_no_cache(cc : CacheControl) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: true,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_no_store(cc : CacheControl) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: true,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_no_transform(cc : CacheControl) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: true,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_only_if_cached(cc : CacheControl) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: true,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_must_revalidate(cc : CacheControl) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: true,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_proxy_revalidate(cc : CacheControl) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: true,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_must_understand(cc : CacheControl) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: true,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_public(cc : CacheControl) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: true,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_private(cc : CacheControl) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: true,
    immutable: cc.immutable,
  }
}

///|
fn cc_set_immutable(cc : CacheControl) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: cc.max_stale,
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: true,
  }
}

///|
fn cc_set_max_stale_unlimited(cc : CacheControl) -> CacheControl {
  {
    max_age: cc.max_age,
    s_maxage: cc.s_maxage,
    max_stale: Some(2147483647),
    min_fresh: cc.min_fresh,
    stale_while_revalidate: cc.stale_while_revalidate,
    stale_if_error: cc.stale_if_error,
    no_cache: cc.no_cache,
    no_store: cc.no_store,
    no_transform: cc.no_transform,
    only_if_cached: cc.only_if_cached,
    must_revalidate: cc.must_revalidate,
    proxy_revalidate: cc.proxy_revalidate,
    must_understand: cc.must_understand,
    public: cc.public,
    private: cc.private,
    immutable: cc.immutable,
  }
}

///|
fn cc_trim_string(s : String) -> String {
  str_trim_string(s)
}

///|
fn cc_char_at(s : String, idx : Int) -> Int {
  str_char_at(s, idx)
}

///|
fn cc_string_slice(s : String, start : Int, end : Int) -> String {
  str_string_slice(s, start, end)
}

///|
fn cc_string_slice_from(s : String, start : Int) -> String {
  str_string_slice_from(s, start)
}

///|
fn cc_find_char(s : String, target : Int) -> Int? {
  let mut idx = 0
  while idx < s.length() {
    if cc_char_at(s, idx) == target {
      return Some(idx)
    }
    idx = idx + 1
  }
  None
}

///|
fn cc_split_string(s : String, sep : String) -> Array[String] {
  str_split_string(s, sep)
}

///|
fn cc_to_lower_case(s : String) -> String {
  str_to_lower_case(s)
}

///|
fn cc_parse_u64(s : String) -> Int? {
  let mut result = 0
  let mut idx = 0
  let len = s.length()
  if len == 0 {
    return None
  }
  while idx < len {
    let ci = cc_char_at(s, idx)
    if ci >= 48 && ci <= 57 {
      result = result * 10 + (ci - 48)
      if result < 0 {
        return None
      }
    } else {
      return None
    }
    idx = idx + 1
  }
  Some(result)
}

///|
fn cc_join_strings(strs : Array[String], sep : String) -> String {
  let mut result = ""
  let mut idx = 0
  while idx < strs.length() {
    if idx > 0 {
      result = result + sep
    }
    result = result + strs[idx]
    idx = idx + 1
  }
  result
}
