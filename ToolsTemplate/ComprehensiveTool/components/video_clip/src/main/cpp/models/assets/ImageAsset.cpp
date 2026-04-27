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

#include "ImageAsset.h"
#include <multimedia/image_framework/image/image_source_native.h>
#include <multimedia/image_framework/image/image_native.h>
#include <native_buffer/native_buffer.h>
#include "utils.h"
#include "i_gl_render_engine.h"
#include <native_color_space_manager/native_color_space_manager.h>

ImageAsset::ImageAsset(const std::string& path) : Asset(path, AssetType::ASSET_IMAGE)
{
}

ImageAsset::~ImageAsset()
{    
    Release();
}

void ImageAsset::Release()
{
    if (!m_pixelMapList.empty()) {
        for (auto pixelMap: m_pixelMapList) {
            if (pixelMap != nullptr) {
                OH_PixelmapNative_Release(pixelMap); // api 18以下用release，不能用destroy。
            }
        }
        m_pixelMapList = {};
    }
    if (!m_nativeBufferList.empty()) {
        for (auto nativeBuffer: m_nativeBufferList) {
            if(nativeBuffer != nullptr) {
                // OH_NativeBuffer_Unreference(nativeBuffer); // api的reference没有大写
                // 这里nativeBuffer交给渲染模块release
            }
        }
        m_nativeBufferList = {};
    }
}

const float ImageAsset::GetPositionX()
{
    return m_positionX;
}

const float ImageAsset::GetPositionY()
{
    return m_positionY;
}

const float ImageAsset::GetScale()
{
    return m_scale;
}

const float ImageAsset::GetRotate()
{
    return m_rotate;
}

const uint32_t ImageAsset::GetHeight()
{
    return m_height;
}

const uint32_t ImageAsset::GetWidth()
{
    return m_width;
}

void ImageAsset::SetPositionX(float positionX)
{
    m_positionX = positionX;
}

void ImageAsset::SetPositionY(float positionY)
{
    m_positionY = positionY;
}

void ImageAsset::SetScale(float scale)
{
    m_scale = scale;
}

void ImageAsset::SetRotate(float rotate)
{
    m_rotate = rotate;
}

void ImageAsset::PrepareImageInfo()
{
    LOGI("ImageAsset::PrepareImageInfo.");
    if (m_path == "") 
        return;
    Image_ErrorCode errorCode;
    OH_ImageSourceNative* imageSource;
   
    LOGI("ImageAsset::PrepareImageInfo. Image path is %{public}s", m_path.c_str());
    std::string path = std::string(m_path);
    
    // 这个api说是creatFromUri其实不是fileUri而是沙箱路径
    errorCode = OH_ImageSourceNative_CreateFromUri(const_cast<char*>(path.c_str()), path.size(), &imageSource);
    if (errorCode != IMAGE_SUCCESS || imageSource == nullptr) { 
        LOGE("ImageAsset::PrepareImageInfo. create image source from uri failed.");
        OH_ImageSourceNative_Release(imageSource);
        return;
    }
    
    // 获取图像属性
    OH_ImageSource_Info* imageInfo;
    OH_ImageSourceInfo_Create(&imageInfo);
    OH_ImageSourceNative_GetImageInfo(imageSource, 0, imageInfo);
    OH_ImageSourceInfo_GetWidth(imageInfo, &m_width);
    OH_ImageSourceInfo_GetHeight(imageInfo, &m_height);
    OH_ImageSourceInfo_GetDynamicRange(imageInfo, &m_isHdr);
    
    // 释放imageInfo和创建它需要的imageSource
    OH_ImageSourceNative_Release(imageSource);
    OH_ImageSourceInfo_Release(imageInfo);
}

void ImageAsset::DecodeToPixelmap()
{   
    LOGI("ImageAsset::DecodeToPixelmap.");
    if (m_path == "") 
        return;
    Image_ErrorCode errorCode;
    OH_ImageSourceNative* imageSource;
   
    LOGI("ImageAsset::DecodeToPixelmap. Image path is %{public}s", m_path.c_str());
    std::string path = std::string(m_path);
    
    // 这个api说是creatFromUri其实不是fileUri而是沙箱路径
    errorCode = OH_ImageSourceNative_CreateFromUri(const_cast<char*>(path.c_str()), path.size(), &imageSource);
    if (errorCode != IMAGE_SUCCESS || imageSource == nullptr) { 
        LOGE("ImageAsset::DecodeToPixelmap. create image source from uri failed.");
        OH_ImageSourceNative_Release(imageSource);
        return;
    }

    OH_ImageSourceNative_GetFrameCount(imageSource, &m_frameCount);
    if (m_frameCount == 0) {
        LOGE("ImageAsset::DecodeToPixelmap. GetFrameCount failed");
        OH_ImageSourceNative_Release(imageSource);
        return;
    }
    if (m_frameCount > 1) {
        m_isGif = true;
    }
    m_delayTimeList.resize(m_frameCount);
    OH_ImageSourceNative_GetDelayTimeList(imageSource, m_delayTimeList.data(), m_frameCount);
    
    // 创建解码参数，解码成pixelMap
    OH_DecodingOptions *ops = nullptr;
    errorCode = OH_DecodingOptions_Create(&ops);
    if (errorCode != IMAGE_SUCCESS || ops == nullptr) {
        LOGE("ImageAsset::DecodeToPixelmap. create decoder ops failed");
        OH_DecodingOptions_Release(ops);
        OH_ImageSourceNative_Release(imageSource);
        return;
    }
    
    OH_DecodingOptions_SetDesiredDynamicRange(ops, IMAGE_DYNAMIC_RANGE_SDR);
    OH_DecodingOptions_SetPixelFormat(ops, PIXEL_FORMAT_RGBA_8888);
    
    for (size_t i = 0; i < m_frameCount; i++) {
        OH_PixelmapNative* pixelMap;
        OH_DecodingOptions_SetIndex(ops, i);
        errorCode = OH_ImageSourceNative_CreatePixelmapUsingAllocator(
            imageSource, ops, IMAGE_ALLOCATOR_TYPE_DMA, &pixelMap
        ); // 这里要用IMAGE_ALLOCATOR_TYPE_DMA，不然OH_PixelmapNative_GetNativeBuffer会报错
        if (errorCode != IMAGE_SUCCESS || pixelMap == nullptr) { 
            LOGE("ImageAsset::DecodeToPixelmap. create pixel map from image source failed.");
            OH_PixelmapNative_Release(pixelMap);
            OH_ImageSourceNative_Release(imageSource);
            OH_DecodingOptions_Release(ops);
            return;
        }
        m_pixelMapList.push_back(pixelMap);
    }
    OH_ImageSourceNative_Release(imageSource);
    OH_DecodingOptions_Release(ops);
}

void ImageAsset::PrePareNativeBuffer()
{   
    LOGI("ImageAsset::PrePareNativeBuffer");
    if (m_pixelMapList.empty()) {
        LOGE("ImageAsset::PrePareNativeBuffer pixelmapList is empty");
        return;
    }
    
    Image_ErrorCode errCode;
    
    for (size_t i = 0; i < m_frameCount; i++) {
        // 获取nativeBuffer，同时手动传递colorSpace
       
        OH_NativeColorSpaceManager *manager;
        OH_PixelmapNative_GetColorSpaceNative(m_pixelMapList[i], &manager);
        auto name = OH_NativeColorSpaceManager_GetColorSpaceName(manager);
        LOGD("OH_NativeColorSpaceManager_GetColorSpaceName  code: %{public}d", name);
        
        OH_NativeBuffer* nativeBuffer;
        errCode = OH_PixelmapNative_GetNativeBuffer(m_pixelMapList[i], &nativeBuffer);
        
        if (name == 3) {
            OH_NativeBuffer_SetColorSpace(nativeBuffer, OH_NativeBuffer_ColorSpace::OH_COLORSPACE_DISPLAY_P3_SRGB);
        } else  {
            OH_NativeBuffer_SetColorSpace(nativeBuffer, OH_NativeBuffer_ColorSpace::OH_COLORSPACE_DISPLAY_SRGB);
        }
        OH_NativeColorSpaceManager_Destroy(manager);
        
        if (errCode!=IMAGE_SUCCESS || nativeBuffer == nullptr) {
            LOGE("ImageAsset::PrePareNativeBuffer get native buffer failed");
            OH_NativeBuffer_Unreference(nativeBuffer);
            return;
        }
        m_nativeBufferList.push_back(nativeBuffer);
    }
    LOGD("ImageAsset::PrePareNativeBuffer create buffer success.");

}

void ImageAsset::PrepareImage(float originX , float originY)
{
    if (m_isPrepared == true) {
        LOGI("ImageAsset::PrepareImage. Already prepared.");
        return;
    }
    if (!m_nativeBufferList.empty()) {
        LOGE("ImageAsset::PrepareImage. Already prepare native buffer.");
        return;
    }
    if (m_pixelMapList.empty()) {
        LOGD("ImageAsset::PrepareImage. Prepare pixel map.");
        DecodeToPixelmap(); // 添加图片的时候需要解码得到长宽，所以可能已经decode过了。
    } else {
        LOGD("ImageAsset::PrepareImage. Pixelmap prepared, continue.");
    } 
    
    PrePareNativeBuffer();
    
    if(m_frameCount == 1) {
        std::shared_ptr<StaticImageInfo> imageInfo = std::make_shared<StaticImageInfo>();
        imageInfo->rotate = m_rotate;
        imageInfo->frames = m_frameCount;
        imageInfo->scale = m_scale;
        imageInfo->pos_x = m_positionX - originX;
        imageInfo->pos_y = m_positionY - originY;
        imageInfo->nativeBuffer = m_nativeBufferList[0];
        m_ImageInfo = std::static_pointer_cast<ImageInfoBase>(imageInfo);
    } else if (m_frameCount > 1){
        std::shared_ptr<DynamicImageInfo> imageInfo = std::make_shared<DynamicImageInfo>();
        imageInfo->rotate = m_rotate;
        imageInfo->frames = m_frameCount;
        imageInfo->scale = m_scale;
        imageInfo->pos_x = m_positionX - originX;
        imageInfo->pos_y = m_positionY - originY;
        imageInfo->isGif = m_isGif;
        imageInfo->nativeBufferArray = m_nativeBufferList;
        std::vector<uint32_t> frameDelayArray;
        for (auto delayTime: m_delayTimeList) {
            frameDelayArray.push_back(static_cast<uint32_t>(delayTime));
        }
        imageInfo->frameDelayArray = frameDelayArray;
        m_ImageInfo = std::static_pointer_cast<ImageInfoBase>(imageInfo);
    }
    
    m_isPrepared = true;
}

std::shared_ptr<ImageInfoBase> ImageAsset::GetImageInfo()
{   
    if (m_isPrepared == false) {
        LOGE("ImageAsset::GetImageInfo. image is not prepared");
        return nullptr;
    }
    return m_ImageInfo;
}

bool ImageAsset::IsGif()
{
    return m_isGif;
}