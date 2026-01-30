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
