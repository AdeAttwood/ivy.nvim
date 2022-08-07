#!/bin/bash

while IFS= read -r file; do
    fixture_file="/tmp/ivy-trees/kubernetes/$file"
    fixture_dir="$(dirname $fixture_file)"

    if [[ ! -d "$fixture_dir" ]]; then
        mkdir -p "$fixture_dir"
    fi

    if [[ ! -f "$fixture_file" ]]; then
        echo "Making $fixture_file"
        touch "$fixture_file"
    fi
done <"fixtures/kubernetes.txt"
