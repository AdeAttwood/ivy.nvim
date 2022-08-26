use criterion::{black_box, criterion_group, criterion_main, Criterion};

use ivyrs::inner_files;

pub fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("ivy_files(kubernetes)", |b| {
        b.iter(|| {
            inner_files(
                black_box("file.go".to_owned()),
                black_box("/tmp/ivy-trees/kubernetes".to_owned()),
            )
        })
    });
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
