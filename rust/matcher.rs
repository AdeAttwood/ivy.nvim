use fuzzy_matcher::FuzzyMatcher;
use fuzzy_matcher::skim::SkimMatcherV2;

pub struct Matcher {
    /// The search pattern that we want to match against some text
    pub pattern: String,
    matcher: SkimMatcherV2,
}

impl Matcher {
    pub fn new(pattern: String) -> Self {
        return Self {
            pattern,
            matcher: SkimMatcherV2::default(),
        }
    }

    pub fn score(self: &Self, text: String) -> i64 {
        if let Some((score, _indices)) =  self.matcher.fuzzy_indices(&text, &self.pattern) {
            return score;
        }

        return 0;
    }
}
