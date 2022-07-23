#include <filesystem>
#include <iostream>
#include <optional>
#include <regex>
#include <string>

#include "./file_scanner.hpp"
#include "./sorter.hpp"

int main(int argc, char* argv[]) {
  std::vector<std::string> args;
  args.reserve(argc);
  // Skip the first argument because that will be the programme name.
  for (int i = 1; i < argc; i++) {
    args.emplace_back(argv[i]);
  }

  if (args.empty()) {
    std::cout << "Missing required search term" << std::endl;
    return 1;
  }

  auto base_dir = std::filesystem::current_path();
  std::string search = args.at(0);

  auto sorter = ivy::Sorter(search);
  auto scanner = ivy::FileScanner(base_dir);

  std::regex pattern("([" + search + "])");
  for (ivy::Match const& match : sorter.sort(scanner.scan())) {
    std::cout << match.score << " " << std::regex_replace(match.content, pattern, "\033[1m$&\033[0m") << std::endl;
  }

  return 0;
}
