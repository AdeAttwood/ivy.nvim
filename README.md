<div align="center">

# ivy.nvim

An [ivy-mode](https://github.com/abo-abo/swiper#ivy) port to neovim. Ivy is a
generic completion mechanism for ~~Emacs~~ Nvim

</div>

## Installation

### Manually

```sh
git clone https://github.com/AdeAttwood/ivy.nvim ~/.config/nvim/pack/bundle/start/ivy.nvim
```

### Plugin managers

TODO: Add docs in the plugin managers I don't use any

### Compiling

For the native searching, you will need to compile the shard library. You can
do that by running the below command in the root of the plugin.

```sh
cmake -DCMAKE_BUILD_TYPE=Release -B build/Release && (cd build/Release; make -j)
```

If you are missing build dependencies, you can install them via apt.

```sh
sudo apt-get install build-essential pkg-config cmake
```

## Features

### Commands

A command can be run that will launch the completion UI

| Command    | Key Map     | Description                                            |
| ---------- | ----------- | ------------------------------------------------------ |
| IvyFd      | \<leader\>p | Find files in your project with the fd cli file finder |
| IvyAg      | \<leader\>/ | Find content in files using the silver searcher        |
| IvyBuffers | \<leader\>b | Search though open buffers                             |
| IvyLines   |             | Search the lines in the current buffer                 |

### Actions

Action can be run on selected candidates provide functionality

| Action   | Description                                                                    |
| -------- | ------------------------------------------------------------------------------ |
| Complete | Run the completion function, usually this will be opening a file               |
| Peek     | Run the completion function on a selection, but don't close the results window |

## API

```lua
  vim.ivy.run(
    -- The name given to the results window and displayed to the user
    "Title",
    -- Call back function to get all the candidates that will be displayed in
    -- the results window, The `input` will be passed in, so you can filter
    -- your results with the value from the prompt
    function(input) return { "One", "Two", Three } end,
    -- Action callback that will be called on the completion or peek actions.
    -- The currently selected item is passed in as the result.
    function(result) vim.cmd("edit " .. result) end
  )
```

## Benchmarks

Benchmarks are of various tasks that ivy will do. The purpose of the benchmarks
are to give us a baseline on where to start when trying to optimize performance
in the matching and sorting, not to put ivy against other tools. When starting
to optimize, you will probably need to get a baseline on your hardware.

There are fixtures provided that will create the directory structure of the
[kubernetes](https://github.com/kubernetes/kubernetes) source code, from
somewhere arround commit sha 985c9202ccd250a5fe22c01faf0d8f83d804b9f3. This will
create a directory tree of 23511 files a relative large source tree to get a
good idea of performance. To create the source tree under
`/tmp/ivy-trees/kubernetes` run the following command. This will need to be run
for the benchmarks to run.

```bash
# Create the source trees
bash ./scripts/fixtures.bash

# Run the benchmark script
luajit ./scripts/benchmark.lua
```

Current benchmark status with 8 CPU(s) Intel(R) Core(TM) i5-8250U CPU @ 1.60GHz

| Name                         | Total         | Adverage      | Min           | Max           |
| ---------------------------- | ------------- | ------------- | ------------- | ------------- |
| ivy_match(file.lua) 1000000x | 02.351614 (s) | 00.000002 (s) | 00.000002 (s) | 00.000042 (s) |
| ivy_files(kubneties) 100x    | 32.704256 (s) | 00.327043 (s) | 00.289397 (s) | 00.344413 (s) |

## Other stuff you might like

- [ivy-mode](https://github.com/abo-abo/swiper#ivy) - An emacs package that was the inspiration for this nvim plugin
- [Command-T](https://github.com/wincent/command-t) - Vim plugin I used before I started this one
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Another competition plugin, lots of people are using
