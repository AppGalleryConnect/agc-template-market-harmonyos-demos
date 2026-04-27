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

#ifndef OPENGL_RENDER_ENGINE_H
#define OPENGL_RENDER_ENGINE_H
#include "egl_render_context.h"
#include "image_manager.h"
#include "render/common/constants.h"
#include "shader_program.h"
#include <cmath>
#include <cstdint>
#include <multimedia/player_framework/native_avcodec_base.h>
#include <mutex>
#include <native_image/native_image.h>
#include <native_window/external_window.h>
#include <thread>
#undef LOG_TAG                 // 取消之前的定义
#define LOG_TAG "RenderEngine" // 重新定义

#include "i_gl_render_engine.h"

namespace HarmonyVideoEditorRender {
using RenderTask = std::function<void()>;
struct MediaInfo {
    double frameRate = 0.0;
    int32_t height = 0;
    int32_t rotation = 0;
    /**
     * 参考OH_ColorPrimary
        COLOR_PRIMARY_BT709 = 1,
        COLOR_PRIMARY_UNSPECIFIED = 2,
        COLOR_PRIMARY_BT470_M = 4,
        COLOR_PRIMARY_BT601_625 = 5,
        COLOR_PRIMARY_BT601_525 = 6,
        COLOR_PRIMARY_SMPTE_ST240 = 7,
        COLOR_PRIMARY_GENERIC_FILM = 8,
        COLOR_PRIMARY_BT2020 = 9,
        COLOR_PRIMARY_SMPTE_ST428 = 10,
        COLOR_PRIMARY_P3DCI = 11,
        COLOR_PRIMARY_P3D65 = 12
     */
    int32_t colorPrimaries = 0;
    /**
     * 转换系数
     */
    int32_t matrixCoefficients = 0;
    /**
     * 亮度区间
     * 0=limited
     * 1=full
     */
    int32_t rangeFlag = 0;
    int32_t width = 0;
    /**
     * 视频时长 微妙
     */
    int64_t duration = 0;
    /**
     * 判断是否为BT.601色彩 primaries
     * BT.601包含625行（PAL制）和525行（NTSC制）两种变体
     */
    bool IsBt601() const
    {
        // 对应COLOR_PRIMARY_BT601_625 (5) 或 COLOR_PRIMARY_BT601_525 (6)
        return colorPrimaries == 5 || colorPrimaries == 6;
    }

    /**
     * 判断是否为全范围（full range）亮度区间
     * 全范围对应rangeFlag=1，有限范围对应rangeFlag=0
     */
    bool IsFullRange() const { return rangeFlag == 1; }
};
class RenderEngine : public IGLRenderEngine {
public:
    RenderEngine();
    RenderEngine(const RenderEngine &) = delete;            // 禁止拷贝构造
    RenderEngine &operator=(const RenderEngine &) = delete; // 禁止赋值
    ~RenderEngine() override;
    int32_t AddStaticImage(std::shared_ptr<StaticImageInfo> staticImageInfo) override;
    int32_t AddDynamicImage(std::shared_ptr<DynamicImageInfo> dynamicImageInfo) override;
    OHNativeWindow *GetInSurface() override;
    int32_t SetOutSurface(OHNativeWindow *outSurface) override;
    int32_t Start() override;
    int32_t Stop();
    bool RemoveImage(int32_t imageId) override;
    void ClearImages() override;
    int32_t SetInVideoFormat(OH_AVFormat *avFormat) override;
    void SetViewParams(ViewParams viewParams) override;
    void SetDebugMode(bool isDebug) { debugMode_ = isDebug; };
    ImageManager &GetImageManager() { return *imageManager_; }

    OHNativeWindow *GetOutSurface(){return outNativeWindow_;};
    using DebugCallbackType = std::function<void(int)>;
    void SetDebugCallback(DebugCallbackType callback) { debugCallback_ = callback; }

private:
    int32_t Init();
    int DoAddImageInfo(ImageDetail &info);
    int DrawOneFrame();
    bool CreateNativeImage();
    bool CreateGLResources();
    void CleanGLResources();
    void DestroyNativeImage();
    static void OnNativeImageFrameAvailable(void *data);
    static bool CheckGLError(const char *operation);
    void DrawOutImage();
    bool CalculateFPS();
    void ThreadMainLoop();
    void PostTask(const RenderTask &task);
    void PrepareVideoMatrix();

private:
    DebugCallbackType debugCallback_;
    std::atomic<bool> running_{false};
    bool debugMode_ = false;
    std::thread thread_;
    std::thread::id threadId_;
    mutable std::mutex taskMutex_;
    std::vector<RenderTask> tasks_;
    mutable std::mutex wakeUpMutex_;
    std::condition_variable wakeUpCond_;
    bool wakeUp_ = false;

    std::unique_ptr<HarmonyVideoEditorRender::ShaderProgram> shaderProgram_;
    std::unique_ptr<HarmonyVideoEditorRender::ShaderProgram> imageShaderProgram_;
    OH_NativeImage *nativeImage_ = nullptr;
    OHNativeWindow *inNativeWindow_ = nullptr;
    OHNativeWindow *outNativeWindow_ = nullptr;
    EGLSurface outSurface_ = EGL_NO_SURFACE;
    OH_OnFrameAvailableListener nativeImageFrameAvailableListener_{};
    int32_t outWidth_ = 1080;
    int32_t outHeight_ = 1920;
    ViewParams viewParams_;
    mutable std::mutex nativeImageSurfaceIdMutex_;
    std::unique_ptr<ImageManager> imageManager_ = std::make_unique<ImageManager>();
    GLuint nativeImageTextureId_ = 9999U;
    GLuint vertexArrayObject_ = 0;
    GLuint vertexBufferObject_ = 0;
    GLuint imageVertexArrayObject_ = 0;
    GLuint imageVertexBufferObject_ = 0;
    std::unique_ptr<EglRenderContext> renderContext_;

    MediaInfo mediaInfo_;
    std::unique_ptr<float_t[]> videoTransformMatrix_;
    float_t imageOrthoMatrix_[MATRIX_4X4_SIZE];

    // 收到解码的视频帧数
    std::atomic<uint64_t> receivedVideoFrameCount_{0};
    // 剩余未处理的视频帧计数
    std::atomic<int> unprocessedVideoFrameCount_{0};
    // 当前处理完的视频帧数
    std::atomic<uint64_t> processedVideoFrameCount_{0};
    uint64_t videoCurrentTime;
    std::chrono::steady_clock::time_point lastTime; // 上次记录时间
    int frameCountForFPS = 0;                       // 用于计算FPS的临时计数
    float currentFPS = 0.0f;                        // 当前FPS值
};
} // namespace HarmonyVideoEditorRender
#endif // OPENGL_RENDER_ENGINE_H
