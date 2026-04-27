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

#ifndef VEDITOR_ASSET_H
#define VEDITOR_ASSET_H

#include <cstdint>
#include <string>
#include <utility>

enum AssetType {
    ASSET_NONE = 0,
    ASSET_VIDEO,
    ASSET_AUDIO,
    ASSET_IMAGE,
};


class Asset {
public:
    explicit Asset();
    Asset(const std::string& path, AssetType type);
    virtual ~Asset();
    
    // 因为解码器只有一个而且不由Asset持有，只有初始化解码器时才手动调用函数设置原始时长。
    virtual void SetOriginalDuration(uint64_t originalDuration);
    
    const std::string GetId();
    const std::string GetPath();
    const int32_t GetSourceFd();
    const uint64_t GetOriginalDuration();

protected:
    std::string m_id; // 只可在创建时赋值
    std::string m_path{""}; // 只可在创建时赋值
    AssetType m_type{ASSET_NONE}; // 只可在创建时赋值
    uint64_t m_originalDuration{0}; // 初始化decoder时赋值
};

#endif //AVCODECVIDEO_ASSET_H
