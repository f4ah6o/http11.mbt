///|
/// Disposition type
pub(all) enum DispositionType {
  Inline
  Attachment
  FormData
} derive(Eq)

///|
pub fn DispositionType::to_string(self : DispositionType) -> String {
  match self {
    Inline => "inline"
    Attachment => "attachment"
    FormData => "form-data"
  }
}
