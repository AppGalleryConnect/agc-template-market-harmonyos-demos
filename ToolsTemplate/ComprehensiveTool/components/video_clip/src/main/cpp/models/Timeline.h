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

#ifndef VEDITOR_TIMELINE_H
#define VEDITOR_TIMELINE_H

#include <mutex>
#include <string>

class VideoAsset;
class AudioAsset;
class ImageAsset;

class Timeline {
public:
    explicit Timeline();
    ~Timeline() = default;

    void SetMainVideo(const std::string& path);
    void UnsetMainVideo();
    void SetBgAudio(const std::string& path);
    std::string AddImage(const std::string& path);
    void UnsetBgAudio();
    void RemoveImage(const std::string& imageId);
    void PushImageTop(const std::string& imageId);
    std::shared_ptr<ImageAsset> GetImage(const std::string& imageId);
    
    const uint64_t GetVideoEndPos();
    const uint64_t GetVideoStartPos();
    const uint64_t GetDuration(); // 获取timeline时长，现在为主视频的截取后时长
    std::shared_ptr<VideoAsset> GetMainVideo();
    std::shared_ptr<AudioAsset> GetBgAudio();
    std::vector<std::shared_ptr<ImageAsset>> GetImages();
    
    
private:
    std::mutex m_mutexList;
    std::shared_ptr<VideoAsset> m_mainVideo{nullptr};
    std::shared_ptr<AudioAsset> m_bgAudio{nullptr};
    std::vector<std::shared_ptr<ImageAsset>> m_imagesList{};
};

#endif //AVCODECVIDEO_TIMELINE_H
