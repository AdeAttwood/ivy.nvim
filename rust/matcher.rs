use fuzzy_matcher::skim::SkimMatcherV2;
use fuzzy_matcher::FuzzyMatcher;

pub struct Matcher {
    /// The search pattern that we want to match against some text
    pub pattern: String,
    matcher: SkimMatcherV2,
}

impl Matcher {
    pub fn new(pattern: String) -> Self {
        Self {
            pattern,
            matcher: SkimMatcherV2::default(),
        }
    }

    pub fn score(&self, text: String) -> i64 {
        self.matcher
            .fuzzy_indices(&text, &self.pattern)
            .map(|(score, _indices)| score)
            .unwrap_or_default()
    }
}
