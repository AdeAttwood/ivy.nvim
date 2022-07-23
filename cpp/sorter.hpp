#pragma once

#include "./fuzzy_match.hpp"
#include "./match.hpp"
#include "./thread_pool.hpp"

namespace ivy {

class Sorter {
  ivy::ThreadPool m_thread_pool;

  std::string_view m_term;

  std::mutex m_matches_lock;
  std::vector<Match> m_matches;

  inline void add_entry(const std::string& file) {
    ivy::FuzzyMatcher matcher(m_term, 0);
    int score = matcher.match(file, false);

    if (score > -200) {
      std::unique_lock<std::mutex> lock(m_matches_lock);
      m_matches.emplace_back(Match{score, file});
    }
  }

 public:
  explicit Sorter(std::string_view term) : m_term(term) {}
  ~Sorter() { m_thread_pool.shutdown(); }

  inline std::vector<Match> sort(std::vector<std::string> list) {
    for (auto item : list) {
      m_thread_pool.push([item, this]() { add_entry(item); });
    }

    while (!m_thread_pool.empty()) {
      // Wait for all of the jobs to be finished
    }

    std::sort(m_matches.begin(), m_matches.end(), sort_match);
    return m_matches;
  }
};

}  // namespace ivy
