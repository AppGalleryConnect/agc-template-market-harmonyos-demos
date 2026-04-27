//
// Created on 2025/7/23.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef OPENGL_UNIQUEIDGENERATOR_H
#define OPENGL_UNIQUEIDGENERATOR_H

#include <atomic>
#include <mutex>
#include <unordered_set>

class UniqueIDGenerator {
public:
    // 单例模式获取生成器实例
    static UniqueIDGenerator& GetInstance() {
        static UniqueIDGenerator instance;
        return instance;
    }

    // 生成下一个唯一ID（线程安全）
    uint64_t NextID() {
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

    // 回收ID（使其可以被重新生成）
    void RecycleID(uint64_t id) {
        if (id == 0) return; // 不回收ID 0
        
        std::lock_guard<std::mutex> lock(mutex_);
        recycled_ids_.insert(id);
    }

    // 重置生成器（谨慎使用）
    void Reset() {
        std::lock_guard<std::mutex> lock(mutex_);
        counter_.store(1);
        recycled_ids_.clear();
    }

private:
    UniqueIDGenerator() : counter_(1) {}
    ~UniqueIDGenerator() = default;
    UniqueIDGenerator(const UniqueIDGenerator&) = delete;
    UniqueIDGenerator& operator=(const UniqueIDGenerator&) = delete;

    // 查找可用的ID（当计数器溢出时使用）
    uint64_t FindAvailableID() {
        // 从1开始查找第一个未使用的ID
        uint64_t id = 1;
        while (true) {
            if (recycled_ids_.count(id) == 0) {
                counter_.store(id + 1); // 更新计数器
                return id;
            }
            id++;
            
            // 防止无限循环（理论上不会发生）
            if (id == 0) throw std::runtime_error("No available IDs");
        }
    }

private:
    std::atomic<uint64_t> counter_;           // 原子计数器，初始值为1
    std::mutex mutex_;                        // 保护回收ID集合
    std::unordered_set<uint64_t> recycled_ids_; // 已回收的ID集合
};

// 简单的API封装
inline uint64_t GenerateUniqueID() {
    return UniqueIDGenerator::GetInstance().NextID();
}

inline void RecycleUniqueID(uint64_t id) {
    UniqueIDGenerator::GetInstance().RecycleID(id);
}

#endif //OPENGL_UNIQUEIDGENERATOR_H
