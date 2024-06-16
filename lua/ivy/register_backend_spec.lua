local register_backend = require "ivy.register_backend"

local function get_command(name)
  local command_iter = vim.api.nvim_get_commands {}

  for _, cmd in pairs(command_iter) do
    if cmd.name == name then
      return cmd
    end
  end

  return nil
end

local function get_keymap(mode, rhs)
  local keymap_iter = vim.api.nvim_get_keymap(mode)
  for _, keymap in pairs(keymap_iter) do
    if keymap.rhs == rhs then
      return keymap
    end
  end

  return nil
end

describe("register_backend", function()
  after_each(function()
    vim.api.nvim_del_user_command "IvyFd"

    local keymap = get_keymap("n", "<Cmd>IvyFd<CR>")
    if keymap then
      vim.api.nvim_del_keymap("n", keymap.lhs)
    end
  end)

  it("registers a backend from a string with the default options", function()
    register_backend "ivy.backends.files"

    local command = get_command "IvyFd"
    assert.is_not_nil(command)

    local keymap = get_keymap("n", "<Cmd>IvyFd<CR>")
    assert.is_not_nil(keymap)
  end)

  it("allows you to override the keymap", function()
    register_backend("ivy.backends.files", { keymap = "<C-p>" })

    local keymap = get_keymap("n", "<Cmd>IvyFd<CR>")
    assert(keymap ~= nil)
    assert.are.equal("<C-P>", keymap.lhs)
  end)

  it("allows you to pass in a hole backend module", function()
    register_backend(require "ivy.backends.files")

    local command = get_command "IvyFd"
    assert.is_not_nil(command)

    local keymap = get_keymap("n", "<Cmd>IvyFd<CR>")
    assert.is_not_nil(keymap)
  end)

  it("allows you to pass in a hole backend module", function()
    register_backend { "ivy.backends.files", { keymap = "<C-p>" } }

    local keymap = get_keymap("n", "<Cmd>IvyFd<CR>")
    assert(keymap ~= nil)
    assert.are.equal("<C-P>", keymap.lhs)
  end)
end)
