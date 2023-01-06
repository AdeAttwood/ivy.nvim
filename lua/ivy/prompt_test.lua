local prompt = require "ivy.prompt"
local vim_mock = require "ivy.vim_mock"

before_each(function()
  vim_mock.reset()
  prompt.destroy()
end)

-- Input a list of strings into the prompt
local input = function(input_table)
  for index = 1, #input_table do
    prompt.input(input_table[index])
  end
end

-- Asserts the prompt contains the correct value
local assert_prompt = function(t, expected)
  local text = prompt.text()
  if text ~= expected then
    t.error("The prompt text should be '" .. expected .. "' found '" .. text .. "'")
  end
end

it("starts with empty text", function(t)
  if prompt.text() ~= "" then
    t.error "The prompt should start with empty text"
  end
end)

it("can input some text", function(t)
  input { "A", "d", "e" }
  assert_prompt(t, "Ade")
end)

it("can delete a char", function(t)
  input { "A", "d", "e", "BACKSPACE" }
  assert_prompt(t, "Ad")
end)

it("will reset the text", function(t)
  input { "A", "d", "e" }
  prompt.set "New"
  assert_prompt(t, "New")
end)

it("can move around the a word", function(t)
  input { "P", "r", "o", "p", "t", "LEFT", "LEFT", "LEFT", "RIGHT", "m" }
  assert_prompt(t, "Prompt")
end)

it("can delete a word", function(t)
  prompt.set "Ade Attwood"
  input { "DELETE_WORD" }
  assert_prompt(t, "Ade ")
end)

it("can delete a word in the middle", function(t)
  prompt.set "Ade middle A"
  input { "LEFT", "LEFT", "DELETE_WORD" }
  assert_prompt(t, "Ade  A")
end)

it("will delete the space and the word if the last word is single space", function(t)
  prompt.set "some.thing "
  input { "DELETE_WORD" }
  assert_prompt(t, "some.")
end)

it("will only delete one word from path", function(t)
  prompt.set "some/nested/path"
  input { "DELETE_WORD" }
  assert_prompt(t, "some/nested/")
end)

it("will delete tailing space", function(t)
  prompt.set "word                 "
  input { "DELETE_WORD" }
  assert_prompt(t, "")
end)

it("will leave a random space", function(t)
  prompt.set "some word       "
  input { "DELETE_WORD" }
  assert_prompt(t, "some ")
end)

local special_characters = { ".", "/", "^" }
for _, char in ipairs(special_characters) do
  it(string.format("will stop at a %s", char), function(t)
    prompt.set(string.format("key%sValue", char))
    input { "DELETE_WORD" }
    assert_prompt(t, string.format("key%s", char))
  end)
end
