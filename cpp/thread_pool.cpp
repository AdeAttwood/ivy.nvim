// Copyright 2021 Practically.io All rights reserved
//
// Use of this source is governed by a BSD-style
// licence that can be found in the LICENCE file or at
// https://www.practically.io/copyright/

#include "thread_pool.hpp"

namespace ivy {
void ThreadPool::run_job() {
  std::function<void()> job;
  while (true) {
    {
      std::unique_lock<std::mutex> lock(m_queue_lock);
      m_condition.wait(lock, [&]() { return !m_queue.empty() || m_stop; });
      if (m_queue.empty()) {
        return;
      }

      job = m_queue.front();
      m_queue.pop();
    }

    job();

    {
      // Only decrement the job count when the job has finished running.
      std::unique_lock<std::mutex> lock(m_count_lock);
      m_job_count--;
    }
  }
}

void ThreadPool::create_threads(unsigned int thread_count) {
  for (int i = 0; i < thread_count; i++) {
    m_threads.emplace_back(std::thread([this] { run_job(); }));
  }
}

void ThreadPool::push(std::function<void()> job) {
  {
    {
      std::unique_lock<std::mutex> lock(m_count_lock);
      m_job_count++;
    }

    std::unique_lock<std::mutex> lock(m_queue_lock);
    m_queue.push(job);
  }

  m_condition.notify_one();
}

bool ThreadPool::empty() {
  std::unique_lock<std::mutex> lock(m_count_lock);
  return m_job_count == 0;
}

void ThreadPool::shutdown() {
  {
    std::unique_lock<std::mutex> lock(m_queue_lock);
    m_stop = true;
  }

  m_condition.notify_all();
  for (auto &thread : m_threads) {
    thread.join();
  }
}
}  // namespace ivy
