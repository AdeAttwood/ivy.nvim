// Copyright 2017-2018 ccls Authors
// SPDX-License-Identifier: Apache-2.0

#pragma once

#include <climits>
#include <string>
#include <string_view>

namespace ivy {
class FuzzyMatcher {
 public:
  constexpr static int kMaxPat = 100;
  constexpr static int kMaxText = 200;
  // Negative but far from INT_MIN so that intermediate results are hard to
  // overflow.
  constexpr static int kMinScore = INT_MIN / 4;

  // 0: case-insensitive
  // 1: case-folded, i.e. insensitive if no input character is uppercase.
  // 2: case-sensitive
  FuzzyMatcher(std::string_view pattern, int case_sensitivity);
  int match(std::string_view text, bool strict);

 private:
  int case_sensitivity;
  std::string pat;
  std::string_view text;
  int pat_set, text_set;
  char low_pat[kMaxPat], low_text[kMaxText];
  int pat_role[kMaxPat], text_role[kMaxText];
  int dp[2][kMaxText + 1][2];

  int matchScore(int i, int j, bool last);
  int missScore(int j, bool last);
};
}  // namespace ivy
