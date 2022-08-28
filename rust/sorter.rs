use super::matcher;
use rayon::prelude::*;

pub struct Match {
    pub score: i64,
    pub content: String,
}

pub struct Options {
    pub pattern: String,
    pub minimum_score: i64,
}

impl Options {
    pub fn new(pattern: String) -> Self {
        Self {
            pattern,
            minimum_score: 25,
        }
    }
}

pub fn sort_strings(options: Options, strings: Vec<String>) -> Vec<Match> {
    let matcher = matcher::Matcher::new(options.pattern);

    let mut matches = strings
        .into_par_iter()
        .map(|candidate| Match {
            score: matcher.score(candidate.as_str()),
            content: candidate,
        })
        .filter(|m| m.score > options.minimum_score)
        .collect::<Vec<Match>>();
    matches.par_sort_unstable_by(|a, b| a.score.cmp(&b.score));
    matches
}
