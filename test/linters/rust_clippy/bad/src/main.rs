use std::fs::OpenOptions;
use std::os::unix::fs::OpenOptionsExt;

fn main() {
    let mut options = OpenOptions::new();
    options.mode(644);
}
