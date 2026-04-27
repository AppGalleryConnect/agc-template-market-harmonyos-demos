/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef ARDEMO_TASK_QUEUE_H
#define ARDEMO_TASK_QUEUE_H

#include <functional>
#include <mutex>
#include <queue>
#include <thread>

class TaskQueue {
public:
    enum Type {
        IMPL = 0, // Initialization, etc., tasks that cannot be cancelled
        NORMAL
    };

public:
    TaskQueue() : isRunning(false) {}
    ~TaskQueue() {}

    // std::forward is used to forward the parameter to the function
    template <typename F, typename... Args> void Push(F &&f, Args &&...args)
    {
        std::lock_guard<std::mutex> lock(mtx);
        queue.push(std::bind(std::forward<F>(f), std::forward<Args>(args)...));
        cv.notify_one();
    }

    void Start()
    {
        if (isRunning) {
            return;
        }
        isRunning = true;
        t = std::make_unique<std::thread>([this] {
            while (isRunning) {
                std::unique_lock<std::mutex> lock(mtx);
                cv.wait(lock, [this] { return !queue.empty(); });
                auto task = queue.front();
                queue.pop();
                lock.unlock();
                task();
            }
        });
    }

    void Stop()
    {
        if (!isRunning) {
            return;
        }
        isRunning = false;
        std::unique_lock<std::mutex> lock(mtx);
        cv.notify_one();
        lock.unlock();
        t->join();
    }

private:
    std::mutex mtx;
    std::condition_variable cv;
    std::queue<std::function<void()>> queue;
    std::atomic<bool> isRunning;
    std::unique_ptr<std::thread> t = nullptr;
    std::string name_;
};

#endif // ARDEMO_TASK_QUEUE_H
