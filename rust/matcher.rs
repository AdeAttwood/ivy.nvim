use fuzzy_matcher::FuzzyMatcher;
use fuzzy_matcher::skim::SkimMatcherV2;

pub struct Matcher {
    /// The search pattern that we want to match against some text
    pub pattern: String,
}

impl Matcher {
    pub fn score(self: &Self, text: String) -> i64 {
        let matcher = SkimMatcherV2::default();
        if let Some((score, _indices)) =  matcher.fuzzy_indices(&text, &self.pattern) {
            return score;
        }

        return 0;
    }
}
