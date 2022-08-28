use super::matcher;
use rayon::prelude::*;
use std::os::raw::{c_char, c_int};
use std::ffi::CString;

#[repr(C)]
pub struct Match {
    pub score: c_int,
    pub content: *const c_char
    // pub score: i64,
    // pub content: String,
}

unsafe impl Send for Match {}

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
            score: matcher.score(candidate.as_str()) as i32,
            content: CString::new(candidate.clone().to_string()).unwrap().into_raw(),
        })
        .filter(|m| m.score > options.minimum_score as i32)
        .collect::<Vec<Match>>();
    matches.par_sort_unstable_by(|a, b| a.score.cmp(&b.score));
    matches
}
