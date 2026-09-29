///|
pub impl Show for AcceptError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend AcceptError with Show::{output, to_string}

///|
pub impl Show for AuthError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend AuthError with Show::{output, to_string}

///|
pub impl Show for CacheError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend CacheError with Show::{output, to_string}

///|
pub impl Show for ConditionalError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend ConditionalError with Show::{output, to_string}

///|
pub impl Show for ContentCoding with fn output(self, logger) {
  logger.write_string(ContentCoding::to_string(self))
}

///|
pub extend ContentCoding with Show::{output}

///|
pub impl Show for ContentDispositionError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend ContentDispositionError with Show::{output, to_string}

///|
pub impl Show for ContentEncodingError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend ContentEncodingError with Show::{output, to_string}

///|
pub impl Show for ContentLanguageError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend ContentLanguageError with Show::{output, to_string}

///|
pub impl Show for ContentLocationError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend ContentLocationError with Show::{output, to_string}

///|
pub impl Show for ContentTypeError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend ContentTypeError with Show::{output, to_string}

///|
pub impl Show for CookieError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend CookieError with Show::{output, to_string}

///|
pub impl Show for DateError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend DateError with Show::{output, to_string}

///|
pub impl Show for DayOfWeek with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend DayOfWeek with Show::{output, to_string}

///|
pub impl Show for DecodeState with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend DecodeState with Show::{output, to_string}

///|
pub impl Show for DecoderLimits with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend DecoderLimits with Show::{output, to_string}

///|
pub impl Show for DigestFieldsError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend DigestFieldsError with Show::{output, to_string}

///|
pub impl Show for ETagError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend ETagError with Show::{output, to_string}

///|
pub impl Show for ETagList with fn output(self, logger) {
  logger.write_string(ETagList::to_string(self))
}

///|
pub extend ETagList with Show::{output}

///|
pub impl Show for EntityTag with fn output(self, logger) {
  logger.write_string(EntityTag::to_string(self))
}

///|
pub extend EntityTag with Show::{output}

///|
pub impl Show for Expect with fn output(self, logger) {
  logger.write_string(Expect::to_string(self))
}

///|
pub extend Expect with Show::{output}

///|
pub impl Show for ExpectError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend ExpectError with Show::{output, to_string}

///|
pub impl Show for Expectation with fn output(self, logger) {
  logger.write_string(Expectation::to_string(self))
}

///|
pub extend Expectation with Show::{output}

///|
pub impl Show for Host with fn output(self, logger) {
  logger.write_string(Host::to_string(self))
}

///|
pub extend Host with Show::{output}

///|
pub impl Show for HostError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend HostError with Show::{output, to_string}

///|
pub impl Show for HttpDate with fn output(self, logger) {
  logger.write_string(HttpDate::to_string(self))
}

///|
pub extend HttpDate with Show::{output}

///|
pub impl Show for HttpError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend HttpError with Show::{output, to_string}

///|
pub impl Show for Protocol with fn output(self, logger) {
  logger.write_string(Protocol::to_string(self))
}

///|
pub extend Protocol with Show::{output}

///|
pub impl Show for RangeError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend RangeError with Show::{output, to_string}

///|
pub impl Show for Request with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend Request with Show::{output, to_string}

///|
pub impl Show for RequestDecoder with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend RequestDecoder with Show::{output, to_string}

///|
pub impl Show for Response with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend Response with Show::{output, to_string}

///|
pub impl Show for ResponseDecoder with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend ResponseDecoder with Show::{output, to_string}

///|
pub impl Show for Trailer with fn output(self, logger) {
  logger.write_string(Trailer::to_string(self))
}

///|
pub extend Trailer with Show::{output}

///|
pub impl Show for TrailerError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend TrailerError with Show::{output, to_string}

///|
pub impl Show for Upgrade with fn output(self, logger) {
  logger.write_string(Upgrade::to_string(self))
}

///|
pub extend Upgrade with Show::{output}

///|
pub impl Show for UpgradeError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend UpgradeError with Show::{output, to_string}

///|
pub impl Show for Uri with fn output(self, logger) {
  logger.write_string(Uri::to_string(self))
}

///|
pub extend Uri with Show::{output}

///|
pub impl Show for UriError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend UriError with Show::{output, to_string}

///|
pub impl Show for Vary with fn output(self, logger) {
  logger.write_string(Vary::to_string(self))
}

///|
pub extend Vary with Show::{output}

///|
pub impl Show for VaryError with fn output(self, logger) {
  logger.write_string(@debug.to_string(self))
}

///|
pub extend VaryError with Show::{output, to_string}
