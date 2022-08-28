mod finder;
mod matcher;
mod sorter;

use std::collections::HashMap;
use std::ffi::CStr;
use std::os::raw::{c_char, c_int};
use std::sync::Mutex;
use std::mem;

#[repr(C)]
pub struct FFiMatchList {
    len: c_int,
    matches: *mut sorter::Match
}

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref GLOBAL_FILE_CACHE: Mutex<HashMap<String, Vec<String>>> = Mutex::new(HashMap::new());
}

fn to_string(input: *const c_char) -> String {
    unsafe { CStr::from_ptr(input) }
        .to_str()
        .unwrap()
        .to_string()
}

fn to_ffi_match_list(mut list: Vec<sorter::Match>) -> *const FFiMatchList {
    list.shrink_to_fit();
    let matches = list.as_mut_ptr();
    let len: c_int = list.len().try_into().unwrap();
    mem::forget(list);

    return Box::into_raw(Box::new(FFiMatchList { len, matches }))
}

fn get_files(directory: &String) -> Vec<String> {
    let mut cache = GLOBAL_FILE_CACHE.lock().unwrap();
    if !cache.contains_key(directory) {
        let finder_options = finder::Options {
            directory: directory.clone(),
        };
        cache.insert(directory.clone(), finder::find_files(finder_options));
    }

    return cache.get(directory).unwrap().to_vec();
}

#[no_mangle]
pub extern "C" fn ivy_init(c_base_dir: *const c_char) {
    let directory = to_string(c_base_dir);
    get_files(&directory);
}

#[no_mangle]
pub extern "C" fn ivy_match(c_pattern: *const c_char, c_text: *const c_char) -> c_int {
    let pattern = to_string(c_pattern);
    let text = to_string(c_text);

    inner_match(pattern, text)
}

pub fn inner_match(pattern: String, text: String) -> i32 {
    let m = matcher::Matcher::new(pattern);

    m.score(text.as_str()) as i32
}

#[no_mangle]
pub extern "C" fn ivy_files(c_pattern: *const c_char, c_base_dir: *const c_char) -> *const FFiMatchList {
    let pattern = to_string(c_pattern);
    let directory = to_string(c_base_dir);

    return inner_files(pattern, directory);
}

pub fn inner_files(pattern: String, base_dir: String) -> *const FFiMatchList {
    // Bail out early if the pattern is empty; it's never going to find anything
    if pattern.is_empty() {
        return to_ffi_match_list(Vec::new());
    }

    let files = get_files(&base_dir);

    let sorter_options = sorter::Options::new(pattern);
    to_ffi_match_list(sorter::sort_strings(sorter_options, files))
}
