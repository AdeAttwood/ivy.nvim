local libivy = require "ivy.libivy"

it("should run a simple match", function(t)
  local score = libivy.ivy_match("term", "I am a serch term")

  if score <= 0 then
    t.error("Score should not be less than 0 found " .. score)
  end
end)

it("should find a dot file", function (t)
  local current_dir = libivy.ivy_cwd()
  local matches = libivy.ivy_files("ci.yml", current_dir);

  if matches ~= ".github/workflows/ci.yml\n" then
    t.error("Invalid matches: " .. matches)
  end
end);
