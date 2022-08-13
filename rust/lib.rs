mod matcher;
mod finder;
mod sorter;
mod thread_pool;

use std::sync::Mutex;
use std::collections::HashMap;
use std::os::raw::{c_int, c_char};
use std::ffi::CString;
use std::ffi::CStr;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref GLOBAL_FILE_CACHE: Mutex<HashMap<String, Vec<String>>> = return Mutex::new(HashMap::new()) ;    
}

fn to_string(input: *const c_char) -> String {
    return unsafe { CStr::from_ptr(input) }.to_str().unwrap().to_string();
}

fn get_files(directory: &String) -> Vec<String> {
    let mut cache = GLOBAL_FILE_CACHE.lock().unwrap();
    if !cache.contains_key(directory) {
        let finder_options = finder::Options{ directory: directory.clone() };
        cache.insert( directory.clone(), finder::find_files(finder_options));
    }

    return cache.get(directory).unwrap().to_vec();
}

#[no_mangle]
pub extern "C" fn ivy_init() {}

#[no_mangle]
pub extern "C" fn ivy_match(c_pattern: *const c_char, c_text: *const c_char) -> c_int {
    let pattern = to_string(c_pattern);
    let text = to_string(c_text);

    let m = matcher::Matcher{ pattern };
    return m.score(text) as i32;
}

#[no_mangle]
pub extern "C" fn ivy_files(c_pattern: *const c_char, c_base_dir: *const c_char) -> *const c_char {
    let pattern = to_string(c_pattern);
    let directory = to_string(c_base_dir);

    // Bail out early if the pattern is empty its never going to find anything
    if pattern.is_empty() {
        return CString::new("").unwrap().into_raw()
    }

    let files = get_files(&directory);

    let mut output = String::new();
    let sorter_options = sorter::Options::new(pattern);

    let files = sorter::sort_strings(sorter_options, files);
    for file in files.lock().unwrap().iter() {
        output.push_str(&file.content);
        output.push('\n');
    }

    return CString::new(output).unwrap().into_raw()
}

