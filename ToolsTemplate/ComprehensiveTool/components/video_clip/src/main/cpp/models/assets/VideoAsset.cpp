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

#include "VideoAsset.h"
#include <cstdint>

VideoAsset::VideoAsset(const std::string& path) : 
    Asset(path, AssetType::ASSET_VIDEO)
{
}

void VideoAsset::SetIsMuted(bool muted)
{
    m_isMuted = muted;
}

void VideoAsset::SetVolume(uint32_t volume)
{
    m_volume = volume;
}

void VideoAsset::SetTrimIn(uint64_t trimIn)
{
    m_trimIn = trimIn;
    UpdateDuration();
    UpdateStartPos();
}

void VideoAsset::SetTrimOut(uint64_t trimOut)
{
    m_trimOut = trimOut;
    UpdateDuration();
    UpdateEndPos();
}

void VideoAsset::SetOriginalDuration(uint64_t originalDuration)
{
    m_originalDuration = originalDuration;
    UpdateDuration();
    UpdateEndPos();
}

void VideoAsset::SetHeight(uint32_t height)
{
    m_height = height;
}

void VideoAsset::SetWidth(uint32_t width)
{
    m_width = width;
}

void VideoAsset::SetRotation(uint32_t rotation)
{
    m_rotation = rotation;    
}

void VideoAsset::UpdateDuration()
{
    if (m_originalDuration == 0)
        return;
    m_duration = m_originalDuration - m_trimIn - m_trimOut;
}

void VideoAsset::UpdateEndPos()
{
    if (m_duration == 0)
        return;
    m_endPos = m_originalDuration - m_trimOut;
}

void VideoAsset::UpdateStartPos()
{
    m_startPos = m_trimIn;
}

const uint64_t VideoAsset::GetStartPos()
{
    return m_startPos;
}

const uint64_t VideoAsset::GetDuration()
{
    return m_duration;
}

const uint64_t VideoAsset::GetTrimIn()
{
    return m_trimIn;
}

const uint64_t VideoAsset::GetTrimOut()
{
    return m_trimOut;
}


const bool VideoAsset::IsMuted()
{
    return m_isMuted;
}

const uint32_t VideoAsset::GetVolume()
{
    return m_volume;
}

const uint64_t VideoAsset::GetEndPos()
{
    return m_endPos;
}

const uint32_t VideoAsset::GetWidth()
{
    return m_width;
}

const uint32_t VideoAsset::GetHeight()
{
    return m_height;
}

const uint32_t VideoAsset::GetRotation()
{
    return m_rotation;
}