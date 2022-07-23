#include <cstring>
#include <map>
#include <string>
#include <vector>

#include "./file_scanner.hpp"
#include "./fuzzy_match.hpp"
#include "./match.hpp"
#include "./sorter.hpp"

namespace ivy {
static std::map<std::string, std::vector<std::string>> file_cache;
};  // namespace ivy

extern "C" void ivy_init(const char* dir) {
  auto scanner = ivy::FileScanner(dir);
  ivy::file_cache[std::string(dir)] = scanner.scan();
}

extern "C" int ivy_match(const char* pattern, const char* text) {
  auto matcher = ivy::FuzzyMatcher(pattern, 0);
  return matcher.match(text, false);
}

extern "C" char* ivy_files(const char* search, const char* base_dir) {
  if (!ivy::file_cache.count(base_dir)) {
    auto scanner = ivy::FileScanner(base_dir);
    ivy::file_cache[std::string(base_dir)] = scanner.scan();
  }

  auto sorter = ivy::Sorter(search);

  // TODO(ade): Sort out how this memory is freed. I am assuming its in lua
  // land via ffi
  auto* s = new std::string();
  for (ivy::Match const& match : sorter.sort(ivy::file_cache.at(base_dir))) {
    s->append(match.content + "\n");
  }

  return s->data();
}
