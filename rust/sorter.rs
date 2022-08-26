use super::matcher;
use super::thread_pool;

use std::sync::mpsc;
use std::sync::Arc;

pub struct Match {
    pub score: i64,
    pub content: String,
}

pub struct Options {
    pub pattern: String,
    pub minimun_score: i64,
}

impl Options {
    pub fn new(pattern: String) -> Self {
        Self {
            pattern,
            minimun_score: 20,
        }
    }
}

pub fn sort_strings(options: Options, strings: Vec<String>) -> Vec<Match> {
    let matcher = matcher::Matcher::new(options.pattern);

    let mut matches = strings
        .into_iter()
        .map(|candidate| Match {
            score: matcher.score(candidate.as_str()),
            content: candidate,
        })
        .filter(|m| m.score > 25)
        .collect::<Vec<Match>>();
    matches.sort_by(|a, b| a.score.cmp(&b.score));
    matches
}
