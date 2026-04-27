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

#include "Asset.h"
#include "models/utils.h"
#include <fcntl.h>

Asset::Asset() 
{
    m_id = GenerateUniqueId("asset");
}

Asset::~Asset() = default;

Asset::Asset(const std::string& path, AssetType type) :
    m_path(path),
    m_type(type)
{
    m_id = GenerateUniqueId("asset");
}

void Asset::SetOriginalDuration(uint64_t originalDuration)
{
    m_originalDuration = originalDuration;
}

const std::string Asset::GetId()
{
    return m_id;
}

const std::string Asset::GetPath()
{
    return m_path;
}

const uint64_t Asset::GetOriginalDuration()
{
    return m_originalDuration;
}

const int32_t Asset::GetSourceFd()
{   
    LOGD("Asset::GetSourceFd.");
    if (m_path == "") {
        LOGE("Asset::GetSourceFd path is empty.");
        return -1;
    }
    
    int32_t fd = open(m_path.c_str(), O_RDONLY);
    return fd;
}



