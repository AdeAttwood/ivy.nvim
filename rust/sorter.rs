use super::matcher;
use rayon::prelude::*;

pub struct Match<'a> {
    pub score: i64,
    pub content: &'a str,
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

pub fn sort_strings(options: Options, strings: &[String]) -> Vec<Match<'_>> {
    let matcher = matcher::Matcher::new(options.pattern);

    let mut matches = strings
        .par_iter()
        .filter_map(|candidate| {
            let score = matcher.score(candidate.as_str());
            if score < options.minimum_score {
                None
            } else {
                Some(Match {
                    score,
                    content: candidate.as_str(),
                })
            }
        })
        .collect::<Vec<Match>>();

    matches.par_sort_unstable_by(|a, b| a.score.cmp(&b.score));
    matches
}
