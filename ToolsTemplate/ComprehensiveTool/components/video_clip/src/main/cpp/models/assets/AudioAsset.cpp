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

#include "AudioAsset.h"

AudioAsset::AudioAsset(const std::string& path) : 
    Asset(path, AssetType::ASSET_AUDIO)
{
}

void AudioAsset::SetIsLoop(bool loop)
{
    m_isLoop = loop;
}

void AudioAsset::SetIsMuted(bool muted)
{
    m_isMuted = muted;
}

void AudioAsset::SetVolume(int32_t volume)
{
    m_volume = volume;
}

bool AudioAsset::IsLoop()
{
    return m_isLoop;
}

bool AudioAsset::IsMuted()
{
    return m_isMuted;
}

int32_t AudioAsset::GetVolume()
{
    return m_volume;
}