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

### Actions

Action can be run on selected candidates provide functionality

| Action   | Description                                                                    |
| -------- | ------------------------------------------------------------------------------ |
| Complete | Run the completion function, usually this will be opening a file               |
| Peek     | Run the completion function on a selection, but don't close the results window |

## API

```lua
  vim.ivy.run(
    -- Call back function to get all the candidates that will be displayed in
    -- the results window, The `input` will be passed in, so you can filter
    -- your results with the value from the prompt
    function(input) return { "One", "Two", Three } end,
    -- Action callback that will be called on the completion or peek actions.
    The currently selected item is passed in as the result.
    function(result) vim.cmd("edit " .. result) end
  )
```

## Other stuff you might like

- [ivy-mode](https://github.com/abo-abo/swiper#ivy) - An emacs package that was the inspiration for this nvim plugin
- [Command-T](https://github.com/wincent/command-t) - Vim plugin I used before I started this one
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Another competition plugin, lots of people are using
