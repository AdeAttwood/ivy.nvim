local libivy = require "ivy.libivy"

it("should run a simple match", function(t)
  local score = libivy.ivy_match("term", "I am a serch term")

  if score <= 0 then
    t.error("Score should not be less than 0 found " .. score)
  end
end)

it("should find a dot file", function(t)
  local current_dir = libivy.ivy_cwd()
  local matches = libivy.ivy_files(".github/workflows/ci.yml", current_dir)

  local results = {}
  for line in string.gmatch(matches, "[^\r\n]+") do
    table.insert(results, line)
  end

  if #results ~= 2 then
    t.error "Incorrect number of results"
  end

  if results[2] ~= ".github/workflows/ci.yml" then
    t.error("Invalid matches: " .. results[2])
  end
end)
