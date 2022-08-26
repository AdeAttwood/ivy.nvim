use ivyrs::inner_files;

pub fn main() {
    let res = inner_files("file.go".to_owned(), "/tmp/ivy-trees/kubernetes".to_owned());

    println!("{}", res);
}
