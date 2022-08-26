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
    let mut matches = Vec::new();
    let matcher = Arc::new(matcher::Matcher::new(options.pattern));

    let pool = thread_pool::ThreadPool::new(std::thread::available_parallelism().unwrap().get());

    let (tx, rx) = mpsc::channel::<Match>();

    for string in strings {
        let thread_matcher = Arc::clone(&matcher);
        let thread_transmitter = tx.clone();
        pool.execute(move || {
            let score = thread_matcher.score(string.to_string());
            if score > 25 {
                thread_transmitter
                    .send(Match {
                        score,
                        content: string,
                    })
                    .expect("Failed to push data to channel");
            }
        })
    }

    drop(pool);
    drop(tx);

    while let Ok(result) = rx.recv() {
        matches.push(result)
    }

    matches.sort_by(|a, b| a.score.cmp(&b.score));
    matches
}
