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

#ifndef VEDITOR_AUDIOASSET_H
#define VEDITOR_AUDIOASSET_H

#include <string>
#include "Asset.h"

class AudioAsset : public Asset {
public:
    explicit AudioAsset(const std::string& path);
    ~AudioAsset() override = default;
    
    
    void SetIsLoop(bool loop);
    void SetIsMuted(bool muted);
    void SetVolume(int32_t);
    
    bool IsLoop();
    bool IsMuted();
    int32_t GetVolume();
    
private:
    bool m_isLoop{true};
    bool m_isMuted{false};
    int32_t m_volume{50};
};


#endif //AVCODECVIDEO_AUDIOASSET_H
