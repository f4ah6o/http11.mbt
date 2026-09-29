///|
test "Show trait remains available for HTTP values" {
  inspect(Show::to_string(@http11.ContentCoding::Gzip), content="gzip")
  inspect(
    Show::to_string(@http11.Uri::parse("https://example.com/a").unwrap()),
    content="https://example.com/a",
  )
  inspect(
    Show::to_string(
      @http11.HttpDate::new(@http11.DayOfWeek::Sunday, 6, 11, 1994, 8, 49, 37).unwrap(),
    ),
    content="Sun, 06 Nov 1994 08:49:37 GMT",
  )
  inspect(
    Show::to_string(@http11.AcceptError::InvalidFormat),
    content="InvalidFormat",
  )
}
