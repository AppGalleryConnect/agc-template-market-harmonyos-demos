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

#ifndef VEDITOR_IMAGEASSET_H
#define VEDITOR_IMAGEASSET_H

#include "Asset.h"
#include "i_gl_render_engine.h"

class OH_PixelmapNative;
class OH_NativeBuffer;
struct StaticImageInfo;

class ImageAsset : public Asset {
public:
    ImageAsset(const std::string& path);
    ~ImageAsset() override;
    
    void SetPositionX(float positionX);
    void SetPositionY(float positionY);
    void SetScale(float scale);
    void SetRotate(float rotate);
    
    void Release();
    void PrepareImage(float originX = 0.0f, float originY = 0.0f);
    std::shared_ptr<ImageInfoBase> GetImageInfo();
    const float GetPositionX();
    const float GetPositionY();
    const float GetScale();
    const float GetRotate();
    const uint32_t GetHeight();    
    const uint32_t GetWidth();
    
    void PrepareImageInfo();
    bool IsGif();
    
private:
    void PrePareNativeBuffer();
    void DecodeToPixelmap();
    
    float m_positionX{0};
    float m_positionY{0};
    uint32_t m_width{0};
    uint32_t m_height{0};
    bool m_isHdr{false};
    bool m_isPrepared{false};
    float m_scale{1.0f};
    float m_rotate{0.0f};
    bool m_isGif{false};
    uint32_t m_frameCount{1};
    std::vector<int32_t> m_delayTimeList{};
    std::vector<OH_PixelmapNative*> m_pixelMapList{};
    std::vector<OH_NativeBuffer*> m_nativeBufferList{};
    std::shared_ptr<ImageInfoBase> m_ImageInfo{nullptr};
};


#endif //AVCODECVIDEO_IMAGEASSET_H
