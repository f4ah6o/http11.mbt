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
