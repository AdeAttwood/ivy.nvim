use criterion::{black_box, criterion_group, criterion_main, Criterion};

use ivyrs::inner_match;

pub fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("ivy_match(file.lua)", |b| {
        b.iter(|| {
            inner_match(
                black_box("file.lua".to_owned()),
                black_box("some/long/path/to/file/file.lua".to_owned()),
            )
        })
    });
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
