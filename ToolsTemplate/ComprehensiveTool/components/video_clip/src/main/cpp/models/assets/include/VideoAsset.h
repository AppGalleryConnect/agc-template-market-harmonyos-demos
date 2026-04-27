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

#ifndef VEDITOR_VIDEOASSET_H
#define VEDITOR_VIDEOASSET_H

#include "Asset.h"

class VideoAsset: public Asset {
public:
    explicit VideoAsset(const std::string& path);
    ~VideoAsset() override = default;

    void SetIsMuted(bool muted);
    void SetVolume(uint32_t volume);
    void SetTrimIn(uint64_t trimIn);
    void SetTrimOut(uint64_t trimOut);
    void SetHeight(uint32_t height);
    void SetWidth(uint32_t width);
    void SetRotation(uint32_t rotation);
    
    // 因为解码器只有一个而且不由Asset持有，只有初始化解码器时才手动调用函数设置原始时长。
    void SetOriginalDuration(const uint64_t originalDuration) override;
    
    const uint64_t GetTrimIn();
    const uint64_t GetTrimOut();
    const uint64_t GetDuration();
    
    
    const uint64_t GetStartPos();
    const uint64_t GetEndPos();
    const bool IsMuted();
    const uint32_t GetVolume();
    
    const uint32_t GetRotation();
    const uint32_t GetWidth();
    const uint32_t GetHeight();
    
    void UpdateEndPos();
    void UpdateStartPos();
    void UpdateDuration(); // 只可在SetOriginalDuration后调用
    
private:
    bool m_isMuted{false};
    uint64_t m_trimIn{0}; // 截取的开头长度
    uint64_t m_trimOut{0}; // 截取的尾部长度
    uint64_t m_duration{0}; // 每次trim操作要重新计算
    
    // 因为所有资源在时间线上都是全局的，所以这里只记录资源被截取部分相对于原始资源的开始和停止位置。
    uint64_t m_startPos{0}; // 视频资源开始的位置(相对于原始资源)
    uint64_t m_endPos{0}; // 视频资源停止的位置(相对于原始资源)
    
    uint32_t m_volume{50};
    uint32_t m_width{0};
    uint32_t m_height{0};
    uint32_t m_rotation{0}; // 视频的旋转度
    std::function<void()> m_onEndPosChange;
};

#endif //AVCODECVIDEO_VIDEOASSET_H
