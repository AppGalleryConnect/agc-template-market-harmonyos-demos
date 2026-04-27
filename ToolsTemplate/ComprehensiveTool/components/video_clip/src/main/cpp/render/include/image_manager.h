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

#ifndef IMAGE_MANAGER_H
#define IMAGE_MANAGER_H

#include "i_gl_render_engine.h"
#include <GLES3/gl3.h>
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <cstdint>
#include <functional>
#include <hilog/log.h>
#include <memory>
#include <multimedia/image_framework/image/pixelmap_native.h>
#include <mutex>
#include <native_buffer/buffer_common.h>
#include <native_buffer/native_buffer.h>
#include <string>
#include <vector>

// 日志相关宏定义（假设已定义）
#undef LOG_TAG
#define LOG_TAG "ImageManager"
// 存储 OpenGL ES 兼容的格式和类型
struct GLESFormat {
    GLenum format;          // 源数据格式（对应 glTexImage2D 的 format 参数）
    GLenum type;            // 源数据类型（对应 glTexImage2D 的 type 参数）
    GLenum internal;        // 内部存储格式（ES 中建议与 format 一致）
    bool needGammaToLinear; // 是否需要在 shader 中手动进行 gamma→线性转换
};
class ImageFrame {
public:
    // 图像帧宽度
    uint32_t width = 0;
    // 图像帧高度
    uint32_t height = 0;
    // 步长
    uint32_t stride = 0;

    /**
     *  像素编码格式 参考OH_NativeBuffer_Format
     */
    uint32_t format = 0;
    /**
     * color space
     */
    OH_NativeBuffer_ColorSpace colorSpace = OH_NativeBuffer_ColorSpace::OH_COLORSPACE_NONE;
    // 数据buffer
    OH_NativeBuffer *nativeBuffer = nullptr;

    // 每帧需要的等待时间
    uint32_t frameDelay = 0;
    /**
     * 需要显示的帧时间
     * pair中的变量定义了显示该帧的起止时间，单位毫秒
     *
     */
    std::vector<std::pair<uint32_t, uint32_t>> showTimePairs;

public:
    // 默认构造函数
    ImageFrame() = default;
    ImageFrame &operator=(ImageFrame &&other) = delete;
    ImageFrame &operator=(const ImageFrame &) = delete;

    // 移动构造函数
    ImageFrame(ImageFrame &&other) noexcept;
    // 拷贝构造函数
    ImageFrame(const ImageFrame &other) = delete;

    // 析构函数
    ~ImageFrame() { Release(); }
    void AddShowTimePair(uint32_t startTime, uint32_t endTime)
    {
        showTimePairs.push_back(std::pair<uint32_t, uint32_t>(startTime, endTime));
    }
    void LoadTexture(GLint level);
    bool IsShowTimeHit(uint64_t currentVideoTime);
    // 初始化，计算需要计算的属性
    void Init(bool isGif);
    bool IsP3ColorSpace();
    bool IsFullRange() { return rangeFlag_ == 1; }
    bool NeedGammaToLinear() { return esFmt_.needGammaToLinear; }
    GLESFormat GetEsFormat() { return esFmt_; }

private:
    /**
     * 亮度区间
     * 0=limited
     * 1=full
     */
    int32_t rangeFlag_ = 1;

    // 每行像素数量
    int32_t rowPixelCount_;
    // 2. 获取 ES 兼容的格式和类型
    GLESFormat esFmt_;

    uint64_t lastVideoFrame_ = 0;

    // 资源释放函数
    void Release();
};

class ImageDetail {
public:
    uint32_t id = 0;
    double_t raw_scale = 0;
    double_t scale = 0;
    double_t raw_pos_x = 0;
    double_t raw_pos_y = 0;
    double_t pos_x = 0;
    double_t pos_y = 0;
    float_t rotate = 0;
    uint32_t frames = 0;
    size_t dataLength = 0;
    uint32_t current_frame_index = 0;
    std::vector<std::shared_ptr<ImageFrame>> imageFrameArray;
    uint64_t lastVideoFrame_ = 0;
    bool isGif = false;

public:
    // 构造函数与析构函数
    explicit ImageDetail();
    ~ImageDetail();
    void Init();

    // 禁用拷贝构造与赋值
    ImageDetail(const ImageDetail &) = delete;
    ImageDetail &operator=(const ImageDetail &) = delete;

    // 移动构造（默认）
    ImageDetail(ImageDetail &&) noexcept = default;
    // 移动赋值 禁用
    ImageDetail &operator=(ImageDetail &&) = delete;
    const int GetWidth() { return GetFrame(0)->width; };
    const int GetHeight() { return GetFrame(0)->height; };
    const GLESFormat GetEsFormat() { return GetFrame(0)->GetEsFormat(); };
    void BindTexture();

    // 公共方法
    void PrintInfo(const char *tag = LOG_TAG) const;
    void AddFrame(OH_NativeBuffer *nativeBuffer, uint32_t frameDelay);
    std::shared_ptr<ImageFrame> GetFrame(int index);
    std::shared_ptr<ImageFrame> GetCurrentFrame()
    {
        return GetFrame(static_cast<int>(current_frame_index));
    }; // jiang: tocheck, 这里没必要转换类型把

    void NextFrame(uint64_t currentVideoFrame, uint32_t fps);
    bool IsHitRect(uint32_t touchX, uint32_t touchY);
    void GenerateTransformMatrix(uint32_t viewWidth, uint32_t viewHeight, float *outMatrix);
    void ResetTransform(uint32_t viewWidth, uint32_t viewHeight, uint32_t finalWidth, uint32_t finalHeight);

private:
    // gl纹理id
    GLuint textureId_ = GL_NONE;
};

class ImageManager {
public:
    ImageManager() = default;
    ~ImageManager() { ClearAll(); };

    // 禁用拷贝构造与赋值
    ImageManager(const ImageManager &) = delete;
    ImageManager &operator=(const ImageManager &) = delete;

    // 图像管理方法
    void AddImage(std::shared_ptr<ImageDetail> frame);
    void ClearAll();
    void Traverse(const std::function<void(ImageDetail *)> &callBack);
    void TraverseReverse(const std::function<bool(ImageDetail *)> &callBack);
    void MoveToFront(uint32_t id);

    // 图片变换相关操作方法
    void Move(uint32_t id, double xOffset, double yOffset);
    void Scale(uint32_t id, double scaleOffset);
    void Rotate(uint32_t id, double rotateAngleOffset);
    void Transform(uint32_t id, double x, double y, double scale, double rotateAngle);
    // 查找图片
    ImageDetail *GetById(uint32_t id);
    // 删除图片
    bool DeleteById(uint32_t id);
    std::vector<std::shared_ptr<ImageDetail>> GetAllImages() { return imageList_; };
    void AddImages(std::vector<std::shared_ptr<ImageDetail>> images) { imageList_ = images; };

private:
    std::vector<std::shared_ptr<ImageDetail>> imageList_;
    std::mutex mutex_; // 保护 imageList_ 的互斥锁
};

#endif // IMAGE_MANAGER_H