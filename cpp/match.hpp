#pragma once

#include <string>

namespace ivy {

struct Match {
  int score;
  std::string content;
};

static bool sort_match(const Match& a, const Match& b) { return a.score < b.score; }

}  // namespace ivy
