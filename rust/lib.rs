mod finder;
mod matcher;
mod sorter;

use std::collections::HashMap;
use std::ffi::CStr;
use std::ffi::CString;
use std::os::raw::{c_char, c_int};
use std::sync::Mutex;
use std::sync::OnceLock;

// A store to the singleton instance of the ivy struct. This must not be accessed directly it must
// be use via the Ivy::global() function. Accessing this directly may cause a panic if its been
// initialized correctly.
static INSTANCE: OnceLock<Mutex<Ivy>> = OnceLock::new();

struct Ivy {
    // The file cache so we don't have to keep iterating the filesystem. The map key is the root
    // directory that has been search and the value an a vector containing all of the files that as
    // in the root. The value will be relative from the root.
    pub file_cache: HashMap<String, Vec<String>>,
    // The sequence number of the last iterator created. This will use as a pointer value to the
    // iterator so we can access it though lua and rust without having to copy strings.
    pub iter_sequence: i32,
    // A store of all the iterators that have been created. The key is the sequence number and the
    // value is the vector of matches that were matched in the search.
    pub iter_map: HashMap<i32, Vec<CString>>,
}

impl Ivy {
    // Get the global instance of the ivy struct. This will initialize the struct if it has not
    // initialized yet.
    pub fn global() -> &'static Mutex<Ivy> {
        INSTANCE.get_or_init(|| {
            Mutex::new(Ivy {
                file_cache: HashMap::new(),
                iter_sequence: 0,
                iter_map: HashMap::new(),
            })
        })
    }
}

fn to_string(input: *const c_char) -> String {
    unsafe { CStr::from_ptr(input) }
        .to_str()
        .unwrap()
        .to_string()
}

fn get_files(directory: &String) -> Vec<String> {
    let mut ivy = Ivy::global().lock().unwrap();
    if !ivy.file_cache.contains_key(directory) {
        let finder_options = finder::Options {
            directory: directory.clone(),
        };

        ivy.file_cache
            .insert(directory.clone(), finder::find_files(finder_options));
    }

    return ivy.file_cache.get(directory).unwrap().to_vec();
}

#[no_mangle]
pub extern "C" fn ivy_init(c_base_dir: *const c_char) {
    let directory = to_string(c_base_dir);
    get_files(&directory);
}

#[no_mangle]
pub extern "C" fn ivy_cwd() -> *const c_char {
    return CString::new(std::env::current_dir().unwrap().to_str().unwrap())
        .unwrap()
        .into_raw();
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

// Create a new iterator that will iterate over all the files in the given directory that match a
// pattern. It will return the pointer to the iterator so it can be retrieve later. The iterator
// can be deleted with `ivy_files_iter_delete`
#[no_mangle]
pub extern "C" fn ivy_files_iter(c_pattern: *const c_char, c_base_dir: *const c_char) -> i32 {
    let directory = to_string(c_base_dir);
    let pattern = to_string(c_pattern);

    let files = get_files(&directory);

    let mut ivy = Ivy::global().lock().unwrap();

    // Convert the matches into CStrings so we can pass the pointers out while still maintaining
    // ownership. If we didn't do this the CString would be dropped and the pointer would be freed
    // while its being used externally.
    let sorter_options = sorter::Options::new(pattern);
    let matches = sorter::sort_strings(sorter_options, files)
        .into_iter()
        .map(|m| CString::new(m.content.as_str()).unwrap())
        .collect::<Vec<CString>>();

    ivy.iter_sequence += 1;
    let new_sequence = ivy.iter_sequence;
    ivy.iter_map.insert(new_sequence, matches);

    new_sequence
}

// Delete the iterator with the given id. This will free the memory used by the iterator that was
// created with `ivy_files_iter`
#[no_mangle]
pub extern "C" fn ivy_files_iter_delete(iter_id: i32) {
    let mut ivy = Ivy::global().lock().unwrap();
    ivy.iter_map.remove(&iter_id);
}

// Returns the length of a given iterator. This will return the number of items that were matched
// when the iterator was created with `ivy_files_iter`
#[no_mangle]
pub extern "C" fn ivy_files_iter_len(iter_id: i32) -> i32 {
    let ivy = Ivy::global().lock().unwrap();

    let items = ivy.iter_map.get(&iter_id).unwrap();
    items.len() as i32
}

// Returns the item at the given index in the iterator. This will return the full match that was
// given in the iterator. This will return a pointer to the string so it can be used in lua.
#[no_mangle]
pub extern "C" fn ivy_files_iter_at(iter_id: i32, index: i32) -> *const c_char {
    let ivy = Ivy::global().lock().unwrap();

    let items = ivy.iter_map.get(&iter_id).unwrap();
    let item = items.get(index as usize).unwrap();

    item.as_ptr()
}

#[no_mangle]
pub extern "C" fn ivy_files(c_pattern: *const c_char, c_base_dir: *const c_char) -> *const c_char {
    let pattern = to_string(c_pattern);
    let directory = to_string(c_base_dir);

    let output = inner_files(pattern, directory);

    CString::new(output).unwrap().into_raw()
}

pub fn inner_files(pattern: String, base_dir: String) -> String {
    let mut output = String::new();

    // Bail out early if the pattern is empty; it's never going to find anything
    if pattern.is_empty() {
        return output;
    }

    let files = get_files(&base_dir);

    let sorter_options = sorter::Options::new(pattern);

    let files = sorter::sort_strings(sorter_options, files);
    for file in files.iter() {
        output.push_str(&file.content);
        output.push('\n');
    }

    output
}
