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

#include "Timeline.h"
#include "Editor.h"
#include "ImageAsset.h"
#include "VideoAsset.h"
#include "AudioAsset.h"
#include "utils.h"

Timeline::Timeline() {}

std::shared_ptr<VideoAsset> Timeline::GetMainVideo() 
{
    return m_mainVideo;
}

std::shared_ptr<AudioAsset> Timeline::GetBgAudio()
{
    return m_bgAudio;
}

std::vector<std::shared_ptr<ImageAsset>> Timeline::GetImages()
{   
    std::lock_guard<std::mutex> lock(m_mutexList);
    return m_imagesList;
}

void Timeline::SetMainVideo(const std::string& path)
{
    std::shared_ptr<VideoAsset> mainVideo = std::make_shared<VideoAsset>(path);
    if (mainVideo == nullptr) {
        LOGE("main video is nullptr");
        return;
    }
    m_mainVideo = mainVideo; // 替换掉旧的mainVideo
}

void Timeline::SetBgAudio(const std::string& path)
{
    std::shared_ptr<AudioAsset> bgAudio = std::make_shared<AudioAsset>(path);
    m_bgAudio = bgAudio;
}

std::string Timeline::AddImage(const std::string& path)
{   
    std::lock_guard<std::mutex> lock(m_mutexList);
    std::shared_ptr<ImageAsset> image = std::make_shared<ImageAsset>(path);
    if (image == nullptr) {
        LOGE("Add Image failed.");
        return "";
    }
    m_imagesList.push_back(image);
    // 这里要图片解码加入渲染引擎，也可以放在导出时再加，因为图片预览是由前端控制的。
    LOGI("Add Image id = %{public}s.", image->GetId().c_str());
    return image->GetId();
}

void Timeline::PushImageTop(const std::string& imageId)
{
    std::lock_guard<std::mutex> lock(m_mutexList);
    std::partition(m_imagesList.begin(), m_imagesList.end(), 
        [imageId] (std::shared_ptr<ImageAsset> image) {
            if (imageId == image->GetId()) {
                return true;
            } else {
                return false;
            }
        }    
    );
}

void Timeline::RemoveImage(const std::string& imageId)
{   
    std::lock_guard<std::mutex> lock(m_mutexList);
    m_imagesList.erase(
        std::remove_if(m_imagesList.begin(), m_imagesList.end(), [&imageId](const auto& image) {
            if (imageId == image->GetId()) {
                LOGI("Find imageId %{public}s to be removed", imageId.c_str());
                return true;
            }
            return false;
        }),
        m_imagesList.end()
    ); 
}

void Timeline::UnsetBgAudio()
{
    m_bgAudio = nullptr;
}

void Timeline::UnsetMainVideo()
{
    m_mainVideo = nullptr;
}

const uint64_t Timeline::GetVideoEndPos()
{   
    if (m_mainVideo == nullptr) 
        return 0;
    return m_mainVideo->GetEndPos();
}


const uint64_t Timeline::GetVideoStartPos()
{   
    if (m_mainVideo == nullptr) 
        return 0;
    return m_mainVideo->GetStartPos();
}

const uint64_t Timeline::GetDuration()
{
    if (m_mainVideo == nullptr)
        return 0;
    return m_mainVideo->GetDuration();
}

std::shared_ptr<ImageAsset> Timeline::GetImage(const std::string& imageId)
{   
    std::shared_ptr<ImageAsset> res;
    for (std::shared_ptr<ImageAsset> image: m_imagesList) {
        if (image == nullptr) {
            LOGE("image is nullptr");
            continue;
        }
        if (image->GetId() == imageId) {
            LOGI("find image %{public}s", imageId.c_str());
            res = image;
            break;
        }
    }
    if (res == nullptr) {
        LOGE("did not find image %{public}s", imageId.c_str());
    }
    return res;
}