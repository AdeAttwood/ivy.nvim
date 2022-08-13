#pragma once

#define FTS_FUZZY_MATCH_IMPLEMENTATION
#include "./fts_fuzzy_match.hpp"
#include "./match.hpp"
#include "./thread_pool.hpp"

namespace ivy {

class Sorter {
  ivy::ThreadPool m_thread_pool;

  std::string m_term;

  std::mutex m_matches_lock;
  std::vector<Match> m_matches;

  inline void add_entry(const std::string& file) {
    int score = 0;
    fts::fuzzy_match(m_term.c_str(), file.c_str(), score);

    if (score > 50) {
      std::unique_lock<std::mutex> lock(m_matches_lock);
      m_matches.emplace_back(Match{score, std::move(file)});
    }
  }

 public:
  explicit Sorter(std::string_view term) : m_term(term) {}
  ~Sorter() { m_thread_pool.shutdown(); }

  inline std::vector<Match> sort(const std::vector<std::string>& list) {
    for (const std::string& item : list) {
      m_thread_pool.push([&item, this]() { add_entry(item); });
    }

    while (!m_thread_pool.empty()) {
      // Wait for all of the jobs to be finished
    }

    std::sort(m_matches.begin(), m_matches.end(), sort_match);
    return m_matches;
  }
};

}  // namespace ivy
