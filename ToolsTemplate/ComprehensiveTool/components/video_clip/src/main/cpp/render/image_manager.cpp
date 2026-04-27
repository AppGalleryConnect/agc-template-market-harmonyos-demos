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

#include "image_manager.h"
#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"
#include <cmath>
#include <cstdint>
#include <cstring>
#include <native_buffer/buffer_common.h>
#include <native_buffer/native_buffer.h>
constexpr uint32_t LOG_PRINT_DOMAIN = 0xFF00;

// 将 OH_NativeBuffer_Format 映射为 OpenGL ES 兼容格式
GLESFormat getGLESFormat(uint32_t format)
{
    switch (static_cast<OH_NativeBuffer_Format>(format)) {
        // RGB 类：优先使用 16位 内部格式，减少 25-50% 内存
        case NATIVEBUFFER_PIXEL_FMT_RGB_565:
            return {GL_RGB, GL_UNSIGNED_SHORT_5_6_5, GL_RGB565, true};
        case NATIVEBUFFER_PIXEL_FMT_RGB_888:
            return {GL_RGB, GL_UNSIGNED_BYTE, GL_SRGB8, false};
        case NATIVEBUFFER_PIXEL_FMT_RGBX_8888:
            return {GL_RGB, GL_UNSIGNED_BYTE, GL_SRGB8, false};
        // RGBA 类：用 16位 替代 32位 内部格式，节省50%内存
        case NATIVEBUFFER_PIXEL_FMT_RGBA_5658:
            return {GL_RGBA, GL_UNSIGNED_BYTE, GL_RGBA4, true};
        case NATIVEBUFFER_PIXEL_FMT_RGBA_4444:
            return {GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, GL_RGBA4, true};
        case NATIVEBUFFER_PIXEL_FMT_RGBA_5551:
            return {GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, GL_RGB5_A1, true};
        case NATIVEBUFFER_PIXEL_FMT_RGBA_8888:
            return {GL_RGBA, GL_UNSIGNED_BYTE, GL_RGBA8, false};
        // 索引色（CLUT）类：用16位替代24位，适合低色彩场景
        case NATIVEBUFFER_PIXEL_FMT_CLUT1:
        case NATIVEBUFFER_PIXEL_FMT_CLUT4:
        case NATIVEBUFFER_PIXEL_FMT_CLUT8:
            return {
                GL_RGB, GL_UNSIGNED_BYTE,
                GL_RGB565, // 16位（5+6+5），索引色最多256色，565足够覆盖，比24位GL_RGB省33%
                true       // 需手动gamma转换
            };
        // 其他格式
        default:
            return {GL_RGBA, GL_UNSIGNED_BYTE, GL_RGBA8, false};
    }
}

// 计算单个像素的字节数（根据OH_NativeBuffer_Format）
int32_t getPixelByteSize(uint32_t format)
{
    switch (static_cast<OH_NativeBuffer_Format>(format)) {
        case NATIVEBUFFER_PIXEL_FMT_CLUT1:
        case NATIVEBUFFER_PIXEL_FMT_CLUT4:
        case NATIVEBUFFER_PIXEL_FMT_CLUT8:
            // 1 字节/像素
            return 1;

        case NATIVEBUFFER_PIXEL_FMT_RGB_565:
        case NATIVEBUFFER_PIXEL_FMT_RGBX_4444:
        case NATIVEBUFFER_PIXEL_FMT_RGBA_4444:
        case NATIVEBUFFER_PIXEL_FMT_RGBX_5551:
        case NATIVEBUFFER_PIXEL_FMT_RGBA_5551:
        case NATIVEBUFFER_PIXEL_FMT_RGB_555:
        case NATIVEBUFFER_PIXEL_FMT_BGR_565:
        case NATIVEBUFFER_PIXEL_FMT_BGRX_4444:
        case NATIVEBUFFER_PIXEL_FMT_BGRA_4444:
        case NATIVEBUFFER_PIXEL_FMT_BGRX_5551:
        case NATIVEBUFFER_PIXEL_FMT_BGRA_5551:
        case NATIVEBUFFER_PIXEL_FMT_YUV_422_I:
        case NATIVEBUFFER_PIXEL_FMT_YUYV_422_PKG:
        case NATIVEBUFFER_PIXEL_FMT_UYVY_422_PKG:
        case NATIVEBUFFER_PIXEL_FMT_RAW10:
            // 2 字节/像素
            return 2;

        case NATIVEBUFFER_PIXEL_FMT_RGBA_5658:
        case NATIVEBUFFER_PIXEL_FMT_RGB_888:
            // 3 字节/像素
            return 3;

        case NATIVEBUFFER_PIXEL_FMT_RGBX_8888:
        case NATIVEBUFFER_PIXEL_FMT_RGBA_8888:
        case NATIVEBUFFER_PIXEL_FMT_RGBA_1010102:
        case NATIVEBUFFER_PIXEL_FMT_BGRX_8888:
        case NATIVEBUFFER_PIXEL_FMT_BGRA_8888:
        case NATIVEBUFFER_PIXEL_FMT_YCBCR_P010:
        case NATIVEBUFFER_PIXEL_FMT_YCRCB_P010:
            // 4 字节/像素
            return 4;

        case NATIVEBUFFER_PIXEL_FMT_RGBA16_FLOAT:
            // 8 字节/像素（ES 3.0+ 支持）
            return 8;

        // 其他格式
        default:
            return 4;
    }
}
void ImageFrame::Init(bool isGif)
{
    int32_t pixelByteSize = getPixelByteSize(this->format);
    esFmt_ = getGLESFormat(this->format);
    if (isGif) {
        esFmt_.internal = GL_RGB5_A1;
    }

    rowPixelCount_ = (pixelByteSize > 0 && stride > 0) ? (stride / pixelByteSize) : width;

    switch (colorSpace) {
        case OH_COLORSPACE_SRGB_LIMIT:
        case OH_COLORSPACE_P3_LIMIT:
            rangeFlag_ = 0;
            break;
        default:
            break;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG,
                 "ImageFrame init "
                 "done,ES=(needGammaToLinear:%{public}d,format:%{public}d,internal:%{public}d,type:%{public}d);Base("
                 "colorSpace:%{public}d,format:%{public}d,rangeFlag:%{public}d)",
                 esFmt_.needGammaToLinear, esFmt_.format, esFmt_.internal, esFmt_.type, colorSpace, format, rangeFlag_);
}
bool ImageFrame::IsP3ColorSpace()
{
    switch (colorSpace) {
        case OH_COLORSPACE_DISPLAY_P3_SRGB:
        case OH_COLORSPACE_DISPLAY_P3_HLG:
        case OH_COLORSPACE_DISPLAY_P3_PQ:
        case OH_COLORSPACE_P3_FULL:
        case OH_COLORSPACE_P3_LIMIT:
        case OH_COLORSPACE_P3_HLG_FULL:
        case OH_COLORSPACE_P3_HLG_LIMIT:
        case OH_COLORSPACE_P3_PQ_FULL:
        case OH_COLORSPACE_P3_PQ_LIMIT:
            return true;
        default:
            return false;
    }
}
ImageFrame::ImageFrame(ImageFrame &&other) noexcept
{
    std::swap(width, other.width);
    std::swap(height, other.height);
    std::swap(stride, other.stride);
    std::swap(format, other.format);
    std::swap(nativeBuffer, other.nativeBuffer);
    std::swap(frameDelay, other.frameDelay);
    std::swap(showTimePairs, other.showTimePairs);
    std::swap(esFmt_, other.esFmt_);
    std::swap(rowPixelCount_, other.rowPixelCount_);
    std::swap(rangeFlag_, other.rangeFlag_);
    std::swap(lastVideoFrame_, other.lastVideoFrame_);
}

void ImageFrame::Release()
{
    if (nativeBuffer != nullptr) {
        OH_NativeBuffer_Unreference(nativeBuffer);
        nativeBuffer = nullptr;
    }
}
void ImageFrame::LoadTexture(GLint index)
{
    if (nativeBuffer == nullptr) {
        return;
    }
    void *inVirAddr = nullptr;
    OH_NativeBuffer_Map(nativeBuffer, &inVirAddr);
    glPixelStorei(GL_UNPACK_ROW_LENGTH, rowPixelCount_);
    // 上传纹理
    glTexSubImage3D(GL_TEXTURE_2D_ARRAY, 0, 0, 0, index, width, height, 1, esFmt_.format, esFmt_.type, inVirAddr);
    OH_NativeBuffer_Unmap(nativeBuffer);
    OH_NativeBuffer_Unreference(nativeBuffer);
    nativeBuffer = nullptr;
}
bool ImageFrame::IsShowTimeHit(uint64_t currentVideoTime)
{
    if (showTimePairs.size() == 0) {
        return true;
    }
    for (auto pair : showTimePairs) {
        if (currentVideoTime >= pair.first && currentVideoTime <= pair.second) {
            return true;
        }
    }
    return false;
}
// ImageFrame 实现
ImageDetail::ImageDetail()
    : id(0), scale(0), pos_x(0), pos_y(0), raw_pos_x(0), raw_pos_y(0), rotate(0.0f), frames(0), dataLength(0),
      current_frame_index(0)
{
}
ImageDetail::~ImageDetail()
{
    imageFrameArray.clear();
    if (textureId_ != GL_NONE) {
        glDeleteTextures(1, &textureId_);
        textureId_ = GL_NONE;
    }
}
void ImageDetail::Init()
{
    for (auto frame : imageFrameArray) {
        frame->Init(isGif);
    }
}
void ImageDetail::BindTexture()
{
    if (textureId_ == GL_NONE) {
        glGenTextures(1, &textureId_);
        glBindTexture(GL_TEXTURE_2D_ARRAY, textureId_);
        glTexStorage3D(GL_TEXTURE_2D_ARRAY,    // 2D纹理数组目标
                       1,                      // levels=1（无mipmap）
                       GetEsFormat().internal, // 内部格式
                       GetWidth(),             // 单帧宽度
                       GetHeight(),            // 单帧高度
                       frames                  // 总层数（帧数）
        );
        glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        for (int i = 0; i < imageFrameArray.size(); i++) {
            auto frame = imageFrameArray[i];
            frame->LoadTexture(i);
        }
    } else {
        glBindTexture(GL_TEXTURE_2D_ARRAY, textureId_);
    }
}
void ImageDetail::PrintInfo(const char *tag) const
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, tag,
                 "ImageDetail [id=%{public}u]  Transform: scale=%{public}f, pos_x=%{public}f, pos_y=%{public}f, "
                 "rotate=%{public}f",
                 id, static_cast<float>(scale), static_cast<float>(pos_x), static_cast<float>(pos_y), rotate);
}

void ImageDetail::AddFrame(OH_NativeBuffer *nativeBuffer, uint32_t frameDelay)
{
    std::shared_ptr<ImageFrame> frame = std::make_shared<ImageFrame>();
    int32_t colorRet = OH_NativeBuffer_GetColorSpace(nativeBuffer, &frame->colorSpace);
    if (colorRet != 0) {
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, LOG_TAG, "AddFrame get colorSpace failed: error=%{public}d ",
                     colorRet);
    }
    OH_NativeBuffer_Config bufferConfig;
    OH_NativeBuffer_GetConfig(nativeBuffer, &bufferConfig);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG,
                 "get native buffer "
                 "config.w=%{public}d,h=%{public}d,format=%{public}d,usage=%{public}d,stride=%{public}d,colorSpace=%{"
                 "public}d,color get ret=%{public}d",
                 bufferConfig.width, bufferConfig.height, bufferConfig.format, bufferConfig.usage, bufferConfig.stride,
                 frame->colorSpace, colorRet);
    frame->nativeBuffer = nativeBuffer;
    frame->frameDelay = frameDelay;
    frame->stride = bufferConfig.stride;
    frame->width = bufferConfig.width;
    frame->height = bufferConfig.height;
    frame->format = bufferConfig.format;
    imageFrameArray.push_back(frame);
}

std::shared_ptr<ImageFrame> ImageDetail::GetFrame(int index)
{
    if (index >= 0 && static_cast<size_t>(index) < imageFrameArray.size()) {
        imageFrameArray[index];
        return imageFrameArray[static_cast<size_t>(index)];
    }
    OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, LOG_TAG, "ImageFrame get empty frame [id=%{public}u]", id);
    return nullptr;
}

void ImageDetail::NextFrame(uint64_t currentVideoFrame, uint32_t fps)
{
    // 计算自上一帧以来经过的视频帧数
    uint64_t frameDelta = currentVideoFrame - lastVideoFrame_;

    // 计算对应的时间间隔（毫秒）
    uint64_t elapsedTimeMs = (frameDelta * 1000) / fps;

    // 获取当前帧的延迟时间
    uint32_t frameDelay = GetFrame(current_frame_index)->frameDelay;
    // 如果经过的时间超过当前帧的延迟时间，则切换到下一帧
    if (elapsedTimeMs >= frameDelay) {
        // 更新帧索引
        current_frame_index++;
        if (current_frame_index >= frames) {
            current_frame_index = 0; // 循环播放
        }

        lastVideoFrame_ = currentVideoFrame;
    }
}

bool ImageDetail::IsHitRect(uint32_t touchX, uint32_t touchY)
{
    const std::shared_ptr<ImageFrame> frame = GetCurrentFrame();
    // 1. 计算图片中心点
    const float centerX = static_cast<float>(pos_x);
    const float centerY = static_cast<float>(pos_y);

    // 2. 将触摸点转换为相对于图片中心的坐标
    const float touchRelX = static_cast<float>(touchX) - centerX;
    const float touchRelY = static_cast<float>(touchY) - centerY;

    // 3. 应用逆旋转（将触摸点旋转回图片未旋转的状态）
    const float rotateRad = -glm::radians(rotate); // 逆旋转角度
    const float cosVal = std::cos(rotateRad);
    const float sinVal = std::sin(rotateRad);
    const float touchRotatedX = touchRelX * cosVal - touchRelY * sinVal;
    const float touchRotatedY = touchRelX * sinVal + touchRelY * cosVal;

    // 4. 考虑缩放后的半宽高
    const float halfWidth = static_cast<float>(frame->width) * 0.5f * scale;
    const float halfHeight = static_cast<float>(frame->height) * 0.5f * scale;

    // 5. 在旋转后的坐标系中进行矩形检测
    const bool hit = (std::abs(touchRotatedX) <= halfWidth && std::abs(touchRotatedY) <= halfHeight);

    OH_LOG_Print(
        LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, LOG_TAG,
        "isHitRect: id=%{public}d, touchX=%{public}u, touchY=%{public}u, centerX=%{public}f, centerY=%{public}f, "
        "rotatedX=%{public}f, rotatedY=%{public}f, halfWidth=%{public}f, halfHeight=%{public}f, hit=%{public}d",
        id, touchX, touchY, centerX, centerY, touchRotatedX, touchRotatedY, halfWidth, halfHeight, hit);

    return hit;
}

void ImageDetail::GenerateTransformMatrix(uint32_t viewWidth, uint32_t viewHeight, float *outMatrix)
{
    const std::shared_ptr<ImageFrame> frame = GetCurrentFrame();
    glm::mat4 transform = glm::mat4(1.0f);
    // 原图宽高
    const float imgWidth = static_cast<float>(frame->width);
    const float imgHeight = static_cast<float>(frame->height);
    float viewAspectRatio = static_cast<float>(viewWidth) / static_cast<float>(viewHeight);

    // 修正缩放系数：基于旋转后的宽高计算，确保适配视图
    float scaleX = imgWidth / static_cast<float>(viewWidth) * scale;
    float scaleY = imgHeight / static_cast<float>(viewHeight) * scale;

    const float tx = 2.0f * (pos_x / viewWidth - 0.5f);
    const float ty = 2.0f * (0.5f - pos_y / viewHeight);

    transform = glm::translate(transform, glm::vec3(tx * viewAspectRatio, ty, 0.0f));
    transform = glm::rotate(transform, glm::radians(-rotate), glm::vec3(0.0f, 0.0f, 1.0f));
    transform = glm::scale(transform, glm::vec3(scaleX * viewAspectRatio, scaleY, 1.0f));

    std::copy_n(glm::value_ptr(transform),
                glm::mat4::length() * glm::mat4::length(), // 元素数量
                outMatrix);
}
void ImageDetail::ResetTransform(uint32_t viewWidth, uint32_t viewHeight, uint32_t finalWidth, uint32_t finalHeight)
{

    if (viewWidth > viewHeight && finalWidth < finalHeight) {
        std::swap(finalWidth, finalHeight);
    }
    double_t ratio = finalWidth * 1.0 / viewWidth;
    pos_x = raw_pos_x * ratio;
    pos_y = raw_pos_y * ratio;
    scale = raw_scale * ratio;
}
void ImageManager::AddImage(std::shared_ptr<ImageDetail> imageDetail)
{
    imageDetail->Init();
    std::lock_guard<std::mutex> lock(mutex_); // 加锁保护修改操作
    imageList_.push_back(std::move(imageDetail));
    int i = 0;
}

void ImageManager::Traverse(const std::function<void(ImageDetail *)> &callBack)
{
    std::lock_guard<std::mutex> lock(mutex_); // 加锁保护修改操作
    for (const auto &frame : imageList_) {
        callBack(frame.get());
    }
}

void ImageManager::TraverseReverse(const std::function<bool(ImageDetail *)> &callBack)
{
    std::lock_guard<std::mutex> lock(mutex_); // 加锁保护修改操作
    for (auto it = imageList_.rbegin(); it != imageList_.rend(); ++it) {
        if (!callBack(it->get())) {
            break;
        }
    }
}
void ImageManager::MoveToFront(uint32_t id)
{
    for (auto it = imageList_.begin(); it != imageList_.end(); ++it) {
        if (it->get()->id == id) {
            auto temp = std::move(*it);
            imageList_.erase(it);
            imageList_.push_back(std::move(temp));
            break;
        }
    }
}

void ImageManager::Move(uint32_t id, double xOffset, double yOffset)
{
    if (ImageDetail *frame = GetById(static_cast<int>(id))) {
        frame->pos_x += xOffset;
        frame->pos_y += yOffset;
    }
}

void ImageManager::Scale(uint32_t id, double scaleOffset)
{
    if (ImageDetail *frame = GetById(static_cast<int>(id))) {
        frame->scale += scaleOffset;
    }
}

void ImageManager::Rotate(uint32_t id, double rotateAngleOffset)
{
    if (ImageDetail *frame = GetById(static_cast<int>(id))) {
        frame->rotate += static_cast<float>(rotateAngleOffset);
    }
}

void ImageManager::Transform(uint32_t id, double x, double y, double scale, double rotateAngle)
{
    if (ImageDetail *frame = GetById(static_cast<int>(id))) {
        frame->pos_x = x;
        frame->pos_y = y;
        frame->scale = scale;
        frame->rotate = static_cast<float>(rotateAngle);
    }
}

ImageDetail *ImageManager::GetById(uint32_t id)
{
    for (const auto &frame : imageList_) {
        if (frame->id == static_cast<uint32_t>(id)) {
            return frame.get();
        }
    }
    return nullptr;
}
void ImageManager::ClearAll()
{
    imageList_.clear();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "ClearAll: 所有图片资源已清空");
}
bool ImageManager::DeleteById(uint32_t id)
{
    // 遍历容器查找目标元素
    for (auto it = imageList_.begin(); it != imageList_.end(); ++it) {
        if (it->get()->id == static_cast<uint32_t>(id)) {
            // 找到后移除元素（unique_ptr会自动释放内存）
            imageList_.erase(it);

            return true; // 删除成功
        }
    }
    // 未找到对应ID的元素
    return false;
}