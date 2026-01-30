///|
/// Content-Disposition header (RFC 6266)
pub(all) struct ContentDisposition {
  disposition_type : DispositionType
  filename : String?
  filename_ext : String?
  name : String?
  parameters : Array[(String, String)]
} derive(Eq)

///|
pub fn ContentDisposition::parse(
  input : String,
) -> Result[ContentDisposition, ContentDispositionError] {
  let s = cd_trim_string(input)
  if s.length() == 0 {
    return Err(Empty)
  }
  let parts = cd_split_params(s)
  if parts.length() == 0 {
    return Err(InvalidFormat)
  }
  let type_str = cd_to_lower_case(cd_trim_string(parts[0]))
  let disp_type = cd_parse_disposition_type(type_str)
  match disp_type {
    Err(e) => return Err(e)
    Ok(dt) => {
      let mut cd = {
        disposition_type: dt,
        filename: None,
        filename_ext: None,
        name: None,
        parameters: [],
      }
      let mut part_idx = 1
      while part_idx < parts.length() {
        let part = cd_trim_string(parts[part_idx])
        if part.length() > 0 {
          let eq_pos = cd_find_char(part, 61) // =
          match eq_pos {
            Some(pos) => {
              let param_name = cd_to_lower_case(
                cd_trim_string(cd_string_slice(part, 0, pos)),
              )
              let param_value = cd_trim_string(
                cd_string_slice_from(part, pos + 1),
              )
              match param_name {
                "filename" => {
                  let parse_result = cd_parse_param_value(param_value)
                  match parse_result {
                    Ok(value) =>
                      cd = {
                        disposition_type: cd.disposition_type,
                        filename: Some(value),
                        filename_ext: cd.filename_ext,
                        name: cd.name,
                        parameters: cd.parameters,
                      }
                    Err(e) => return Err(e)
                  }
                }
                "filename*" => {
                  let parse_result = cd_parse_ext_value(param_value)
                  match parse_result {
                    Ok(value) =>
                      cd = {
                        disposition_type: cd.disposition_type,
                        filename: cd.filename,
                        filename_ext: Some(value),
                        name: cd.name,
                        parameters: cd.parameters,
                      }
                    Err(e) => return Err(e)
                  }
                }
                "name" => {
                  let parse_result = cd_parse_param_value(param_value)
                  match parse_result {
                    Ok(value) =>
                      cd = {
                        disposition_type: cd.disposition_type,
                        filename: cd.filename,
                        filename_ext: cd.filename_ext,
                        name: Some(value),
                        parameters: cd.parameters,
                      }
                    Err(e) => return Err(e)
                  }
                }
                _ => {
                  let parse_result = cd_parse_param_value(param_value)
                  match parse_result {
                    Ok(value) => {
                      let new_params = []
                      let mut j = 0
                      while j < cd.parameters.length() {
                        new_params.push(cd.parameters[j])
                        j = j + 1
                      }
                      new_params.push((param_name, value))
                      cd = {
                        disposition_type: cd.disposition_type,
                        filename: cd.filename,
                        filename_ext: cd.filename_ext,
                        name: cd.name,
                        parameters: new_params,
                      }
                    }
                    Err(e) => return Err(e)
                  }
                }
              }
            }
            None => {
              let _ = ()

            }
          }
        }
        part_idx = part_idx + 1
      }
      Ok(cd)
    }
  }
}

///|
pub fn ContentDisposition::new(
  disposition_type : DispositionType,
) -> ContentDisposition {
  {
    disposition_type,
    filename: None,
    filename_ext: None,
    name: None,
    parameters: [],
  }
}

///|
pub fn ContentDisposition::disposition_type(
  self : ContentDisposition,
) -> DispositionType {
  self.disposition_type
}

///|
pub fn ContentDisposition::filename(self : ContentDisposition) -> String? {
  match self.filename_ext {
    Some(fe) => Some(fe)
    None => self.filename
  }
}

///|
pub fn ContentDisposition::filename_ascii(self : ContentDisposition) -> String? {
  self.filename
}

///|
pub fn ContentDisposition::filename_ext(self : ContentDisposition) -> String? {
  self.filename_ext
}

///|
pub fn ContentDisposition::name(self : ContentDisposition) -> String? {
  self.name
}

///|
pub fn ContentDisposition::parameter(
  self : ContentDisposition,
  name : String,
) -> String? {
  let name_lower = cd_to_lower_case(name)
  let mut idx = 0
  while idx < self.parameters.length() {
    let (k, v) = self.parameters[idx]
    if k == name_lower {
      return Some(v)
    }
    idx = idx + 1
  }
  None
}

///|
pub fn ContentDisposition::is_inline(self : ContentDisposition) -> Bool {
  match self.disposition_type {
    Inline => true
    _ => false
  }
}

///|
pub fn ContentDisposition::is_attachment(self : ContentDisposition) -> Bool {
  match self.disposition_type {
    Attachment => true
    _ => false
  }
}

///|
pub fn ContentDisposition::is_form_data(self : ContentDisposition) -> Bool {
  match self.disposition_type {
    FormData => true
    _ => false
  }
}

///|
pub fn ContentDisposition::with_filename(
  self : ContentDisposition,
  filename : String,
) -> ContentDisposition {
  {
    disposition_type: self.disposition_type,
    filename: Some(filename),
    filename_ext: self.filename_ext,
    name: self.name,
    parameters: self.parameters,
  }
}

///|
pub fn ContentDisposition::with_filename_ext(
  self : ContentDisposition,
  filename_ext : String,
) -> ContentDisposition {
  {
    disposition_type: self.disposition_type,
    filename: self.filename,
    filename_ext: Some(filename_ext),
    name: self.name,
    parameters: self.parameters,
  }
}

///|
pub fn ContentDisposition::with_name(
  self : ContentDisposition,
  name : String,
) -> ContentDisposition {
  {
    disposition_type: self.disposition_type,
    filename: self.filename,
    filename_ext: self.filename_ext,
    name: Some(name),
    parameters: self.parameters,
  }
}

///|
pub fn ContentDisposition::to_string(self : ContentDisposition) -> String {
  let mut result = self.disposition_type.to_string()
  match self.name {
    Some(n) => result = result + "; name=\"" + cd_escape_quoted_string(n) + "\""
    None => {
      let _ = ()

    }
  }
  match self.filename {
    Some(f) =>
      result = result + "; filename=\"" + cd_escape_quoted_string(f) + "\""
    None => {
      let _ = ()

    }
  }
  match self.filename_ext {
    Some(fe) =>
      result = result + "; filename*=UTF-8''" + cd_encode_ext_value(fe)
    None => {
      let _ = ()

    }
  }
  let mut idx = 0
  while idx < self.parameters.length() {
    let (name, value) = self.parameters[idx]
    result = result +
      "; " +
      name +
      "=\"" +
      cd_escape_quoted_string(value) +
      "\""
    idx = idx + 1
  }
  result
}
