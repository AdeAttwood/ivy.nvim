#pragma once

#include <filesystem>
#include <string>
#include <vector>

namespace fs = std::filesystem;

namespace ivy {
class FileScanner {
  std::string m_base_dir;

 public:
  explicit FileScanner(const std::string base_dir) : m_base_dir(base_dir) {}

  std::vector<std::string> scan() {
    std::vector<std::string> results;
    for (const fs::directory_entry& dir_entry : fs::recursive_directory_iterator(m_base_dir)) {
      fs::path path = dir_entry.path();

      // TODO(ade): sort out some kind of ignore thing. This will be needed
      // when we start adding wildcard ignore functionality
      if (path.string().find(".git") != std::string::npos) {
        continue;
      }

      if (dir_entry.is_regular_file()) {
        results.emplace_back(fs::relative(path, m_base_dir));
      }
    }

    return results;
  }
};
}  // namespace ivy
