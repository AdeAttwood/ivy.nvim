use ignore::{overrides::OverrideBuilder, WalkBuilder};
use std::fs;

pub struct Options {
    pub directory: String,
}

pub fn find_files(options: Options) -> Vec<String> {
    let mut files: Vec<String> = Vec::new();
    let base_path = &fs::canonicalize(options.directory).unwrap();

    let mut builder = WalkBuilder::new(base_path);
    // Search for hidden files and directories
    builder.hidden(false);
    // Don't require a git repo to use .gitignore files. We want to use the .gitignore files
    // wherever we are
    builder.require_git(false);

    // TODO(ade): Remove unwraps and find a good way to get the errors into the UI. Currently there
    // is no way to handel errors in the rust library
    let mut override_builder = OverrideBuilder::new("");
    override_builder.add("!.git").unwrap();

    let overrides = override_builder.build().unwrap();
    builder.overrides(overrides);

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
