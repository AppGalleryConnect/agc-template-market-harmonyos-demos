/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

#ifndef OPENGL_UNIQUEIDGENERATOR_H
#define OPENGL_UNIQUEIDGENERATOR_H

#include <atomic>
#include <mutex>
#include <unordered_set>

class UniqueIDGenerator {
public:
    // 单例模式获取生成器实例
    static UniqueIDGenerator &GetInstance()
    {
        static UniqueIDGenerator instance;
        return instance;
    }

    // 生成下一个唯一ID（线程安全）
    uint64_t NextID()
    {
        // 尝试直接递增原子计数器
        uint64_t id = counter_.fetch_add(1, std::memory_order_relaxed);
        // 处理计数器溢出的情况（理论上需要2^64次调用才会发生）
        if (id == 0) {
            std::lock_guard<std::mutex> lock(mutex_);
            // 重新查找可用ID
            return FindAvailableID();
        }

        // 检查ID是否已被回收（概率极低）
        std::lock_guard<std::mutex> lock(mutex_);
        if (recycled_ids_.count(id) > 0) {
            recycled_ids_.erase(id);
            return id;
        }

        return id;
    }
private:
    UniqueIDGenerator() : counter_(1) {}
    ~UniqueIDGenerator() = default;
    UniqueIDGenerator(const UniqueIDGenerator &) = delete;
    UniqueIDGenerator &operator=(const UniqueIDGenerator &) = delete;

    // 查找可用的ID（当计数器溢出时使用）
    uint64_t FindAvailableID()
    {
        // 从1开始查找第一个未使用的ID
        uint64_t id = 1;
        while (true) {
            if (recycled_ids_.count(id) == 0) {
                counter_.store(id + 1); // 更新计数器
                return id;
            }
            id++;

            // 防止无限循环（理论上不会发生）
            if (id == 0) {
                throw std::runtime_error("No available IDs");
            }
        }
    }

private:
    std::atomic<uint64_t> counter_;             // 原子计数器，初始值为1
    std::mutex mutex_;                          // 保护回收ID集合
    std::unordered_set<uint64_t> recycled_ids_; // 已回收的ID集合
};

// 简单的API封装
inline uint64_t GenerateUniqueID() { return UniqueIDGenerator::GetInstance().NextID(); }

#endif // OPENGL_UNIQUEIDGENERATOR_H
