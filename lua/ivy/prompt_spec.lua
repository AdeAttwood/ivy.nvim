local prompt = require "ivy.prompt"

-- Input a list of strings into the prompt
local input = function(input_table)
  for index = 1, #input_table do
    prompt.input(input_table[index])
  end
end

describe("prompt", function()
  before_each(function()
    prompt.destroy()
  end)

  it("starts with empty text", function()
    assert.is_same(prompt.text(), "")
  end)

  it("can input some text", function()
    input { "A", "d", "e" }
    assert.is_same(prompt.text(), "Ade")
  end)

  it("can delete a char", function()
    input { "A", "d", "e", "BACKSPACE" }
    assert.is_same(prompt.text(), "Ad")
  end)

  it("will reset the text", function()
    input { "A", "d", "e" }
    prompt.set "New"
    assert.is_same(prompt.text(), "New")
  end)

  it("can move around the a word", function()
    input { "P", "r", "o", "p", "t", "LEFT", "LEFT", "LEFT", "RIGHT", "m" }
    assert.is_same(prompt.text(), "Prompt")
  end)

  it("can delete a word", function()
    prompt.set "Ade Attwood"
    input { "DELETE_WORD" }

    assert.is_same(prompt.text(), "Ade ")
  end)

  it("can delete a word in the middle and leave the cursor at that word", function()
    prompt.set "Ade middle A"
    input { "LEFT", "LEFT", "DELETE_WORD", "a" }

    assert.is_same(prompt.text(), "Ade a A")
  end)

  it("will delete the space and the word if the last word is single space", function()
    prompt.set "some.thing "
    input { "DELETE_WORD" }

    assert.is_same(prompt.text(), "some.")
  end)

  it("will only delete one word from path", function()
    prompt.set "some/nested/path"
    input { "DELETE_WORD" }

    assert.is_same(prompt.text(), "some/nested/")
  end)

  it("will delete tailing space", function()
    prompt.set "word                 "
    input { "DELETE_WORD" }

    assert.is_same(prompt.text(), "")
  end)

  it("will leave a random space", function()
    prompt.set "some word       "
    input { "DELETE_WORD" }

    assert.is_same(prompt.text(), "some ")
  end)

  local special_characters = { ".", "/", "^" }
  for _, char in ipairs(special_characters) do
    it(string.format("will stop at a %s", char), function()
      prompt.set(string.format("key%sValue", char))
      input { "DELETE_WORD" }

      assert.is_same(prompt.text(), string.format("key%s", char))
    end)
  end
end)
