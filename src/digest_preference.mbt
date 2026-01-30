///|
/// Digest preference (algorithm + weight 0-10)
pub(all) struct DigestPreference {
  algorithm : String
  weight : Int
} derive(Eq)

///|
pub fn DigestPreference::new(
  algorithm : String,
  weight : Int,
) -> DigestPreference {
  { algorithm, weight }
}

///|
pub fn DigestPreference::algorithm(self : DigestPreference) -> String {
  self.algorithm
}

///|
pub fn DigestPreference::weight(self : DigestPreference) -> Int {
  self.weight
}

///|
pub fn DigestPreference::to_string(self : DigestPreference) -> String {
  self.algorithm + "=" + df_int_to_string(self.weight)
}
