use super::matcher;
use super::thread_pool;


use std::sync::Mutex;
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
        return Self { pattern, minimun_score: 20 };
    }
}

pub fn sort_strings(options: Options, strings: Vec<String>) -> Arc<Mutex<Vec<Match>>> {
    let matches: Arc<Mutex<Vec<Match>>> = Arc::new(Mutex::new(Vec::new()));
    let matcher = Arc::new(Mutex::new(matcher::Matcher{ pattern: options.pattern }));

    let pool = thread_pool::ThreadPool::new(std::thread::available_parallelism().unwrap().get());

    for string in strings {
        let thread_matcher = Arc::clone(&matcher);
        let thread_matches = Arc::clone(&matches);
        pool.execute(move || {
            let score = thread_matcher.lock().unwrap().score(string.to_string());
            if score > 25 {
                let mut tmp = thread_matches.lock().unwrap();
                let content = string.clone();
                tmp.push(Match{ score, content });
            }
        })
    }

    drop(pool);

    matches.lock().unwrap().sort_by(|a, b| a.score.cmp(&b.score));
    return matches;
}

