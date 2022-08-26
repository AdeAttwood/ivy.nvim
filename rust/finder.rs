use ignore::WalkBuilder;
use std::fs;

pub struct Options {
    pub directory: String,
}

pub fn find_files(options: Options) -> Vec<String> {
    let mut files: Vec<String> = Vec::new();
    let base_path = &fs::canonicalize(options.directory).unwrap();

    let mut builder = WalkBuilder::new(base_path);
    builder.ignore(true).hidden(true);

    for result in builder.build() {
        let absolute_candidate = result.unwrap();
        let candidate_path = absolute_candidate.path().strip_prefix(base_path).unwrap();
        if candidate_path.is_dir() {
            continue;
        }

        files.push(candidate_path.to_str().unwrap().to_string());
    }

    files
}
