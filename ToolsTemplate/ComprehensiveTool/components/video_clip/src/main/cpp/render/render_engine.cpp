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

#include "include/render_engine.h"

#include "common/UniqueIDGenerator.h"
#include "common/constants.h" // 引入全局常量头文件
#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"
#include "image_render_shaders.h"
#include <cmath>
#include <cstdint>
#include <mutex>

namespace HarmonyVideoEditorRender {

const GLfloat vertices[] = {
    // positions       // texture coords
    -1.0f, 1.0f,  0.0f, 0.0f, 0.0f, // top left
    -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, // bottom left
    1.0f,  -1.0f, 0.0f, 1.0f, 1.0f, // bottom right
    1.0f,  1.0f,  0.0f, 1.0f, 0.0f  // top right
};

const GLfloat image_vertices[] = {
    // positions       // texture coords
    -1.0f, 1.0f,  0.0f, 0.0f, 0.0f, // top left
    -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, // bottom left
    1.0f,  -1.0f, 0.0f, 1.0f, 1.0f, // bottom right
    1.0f,  1.0f,  0.0f, 1.0f, 0.0f  // top right
};
constexpr uint32_t LOG_PRINT_DOMAIN = 0xFF00;
bool RenderEngine::CheckGLError(const char *operation)
{
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, LOG_TAG, "GL error in '%{public}s': 0x%{public}x", operation,
                     error);
        return true;
    }
    return false;
}
RenderEngine::RenderEngine()
{
    running_ = true;

    // 初始化 imageOrthoMatrix_ 为默认的正交矩阵（1:1 宽高比）
    glm::mat4 defaultOrthoMatrix = glm::ortho(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f);
    std::copy_n(glm::value_ptr(defaultOrthoMatrix), MATRIX_4X4_SIZE, imageOrthoMatrix_);

    thread_ = std::thread([this]() {
        ThreadMainLoop();
        Stop();
    });
}
RenderEngine::~RenderEngine()
{
    PostTask([this]() {
        running_.store(false);
        unprocessedVideoFrameCount_.store(0); // 强制清零未处理帧计数
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        renderContext_->SwapBuffers(outSurface_);
    });
    if (thread_.joinable()) {
        thread_.join();
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "Render engine released done");
};
void RenderEngine::PostTask(const RenderTask &task)
{
    if (!running_) {
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, LOG_TAG, "PostTask failed: RenderThread is not running");
        return;
    }
    {
        std::lock_guard<std::mutex> lock(taskMutex_);
        tasks_.push_back(task);
    }
    if (std::this_thread::get_id() != threadId_) {
        std::lock_guard<std::mutex> lock(wakeUpMutex_);
        wakeUp_ = true;
        wakeUpCond_.notify_one();
    }
}

void RenderEngine::PrepareVideoMatrix()
{
    if (videoTransformMatrix_ == nullptr) {
        int32_t transForm;
        OH_NativeWindow_NativeWindowHandleOpt(inNativeWindow_, GET_TRANSFORM, &transForm);
        videoTransformMatrix_ = std::make_unique<float_t[]>(MATRIX_4X4_SIZE);
        glm::mat4 myTransformMatrix = glm::mat4(1.0f);
        myTransformMatrix =
            glm::rotate(myTransformMatrix, glm::radians(transForm * 90.0f), glm::vec3(0.0f, 0.0f, 1.0f));
        std::copy_n(glm::value_ptr(myTransformMatrix), glm::mat4::length() * glm::mat4::length(),
                    videoTransformMatrix_.get());
    }
}
void RenderEngine::ThreadMainLoop()
{
    threadId_ = std::this_thread::get_id();
    if (Init() != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, LOG_TAG, "Render engine init failed");
        return;
    }
    while (running_) {
        {
            std::unique_lock<std::mutex> lock(wakeUpMutex_);
            wakeUpCond_.wait(
                lock, [this]() { return wakeUp_ || unprocessedVideoFrameCount_.load(std::memory_order_relaxed) > 0; });

            wakeUp_ = false;
        }
        std::vector<RenderTask> tasks;
        {
            std::lock_guard<std::mutex> lock(taskMutex_);
            tasks.swap(tasks_);
        }
        for (const auto &task : tasks) {
            task();
        }
        int64_t currentCount = unprocessedVideoFrameCount_.load(std::memory_order_relaxed); // 原子读取计数
        if (currentCount <= 0) {
            continue;
        }
        auto startTime = std::chrono::high_resolution_clock::now();
        OH_NativeImage_AttachContext(nativeImage_, nativeImageTextureId_);
        int32_t ret = OH_NativeImage_UpdateSurfaceImage(nativeImage_);
        if (ret != 0) {
            OH_LOG_Print(
                LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, LOG_TAG,
                "OH_NativeImage_UpdateSurfaceImage error,code=%{public}d,unprocessedVideoFrameCount:%{public}ld", ret,
                currentCount);
            continue;
        }
        PrepareVideoMatrix();
        uint64_t processedFrameCount = processedVideoFrameCount_.load();
        videoCurrentTime = (processedFrameCount * MILLIS_PER_SECOND / static_cast<int32_t>(mediaInfo_.frameRate)) %
                           (mediaInfo_.duration / MRC_MICROSECONDS_PER_MILLISECOND);
        OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, LOG_TAG,
                     "BeforeDrawOneFrame  unprocessedFrameCount:%{public}d,processedFrameCount=%{public}lu",
                     unprocessedVideoFrameCount_.load(std::memory_order_relaxed), processedFrameCount);
        DrawOneFrame();

        unprocessedVideoFrameCount_.fetch_add(-1, std::memory_order_relaxed);
        processedVideoFrameCount_.fetch_add(1, std::memory_order_relaxed);
        // 计算FPS,打印与fps计算同步
        CalculateFPS();
        auto endTime = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::nanoseconds>(endTime - startTime);
        OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, LOG_TAG,
                     "AfterDrawOneFrame execution time: %{public}.1f ms, current fps: %{public}f, left frame "
                     "count:%{public}d,processedFrameCount=%{public}lu",
                     duration.count() / 1000000.0f, currentFPS,
                     unprocessedVideoFrameCount_.load(std::memory_order_relaxed),
                     processedVideoFrameCount_.load(std::memory_order_relaxed));
    }
}
bool RenderEngine::CreateNativeImage()
{
    if (nativeImage_) {
        return true;
    }
    nativeImage_ = OH_NativeImage_Create(-1, GL_TEXTURE_EXTERNAL_OES);
    if (nativeImage_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, LOG_TAG, "OH_NativeImage_Create failed.");
        return false;
    }
    inNativeWindow_ = OH_NativeImage_AcquireNativeWindow(nativeImage_);
    return true;
}
bool RenderEngine::CalculateFPS()
{
    // 记录当前时间
    auto now = std::chrono::steady_clock::now();

    // 第一次调用初始化时间
    if (lastTime.time_since_epoch().count() == 0) {
        lastTime = now;
        return false;
    }

    // 增加临时帧数计数
    frameCountForFPS++;

    // 每过1秒（或其他间隔）计算一次FPS
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(now - lastTime).count();
    if (duration >= MILLIS_PER_SECOND) { // 1秒
        currentFPS = static_cast<float>(frameCountForFPS) / (duration / 1000.0f);
        // 重置计数器和时间
        frameCountForFPS = 0;
        lastTime = now;
        return true;
    }
    return false;
}
void RenderEngine::OnNativeImageFrameAvailable(void *data)
{
    auto renderEngine = reinterpret_cast<RenderEngine *>(data);
    if (renderEngine == nullptr) {
        return;
    }

    // 原子增加总帧数
    renderEngine->unprocessedVideoFrameCount_.fetch_add(1, std::memory_order_relaxed);
    renderEngine->receivedVideoFrameCount_.fetch_add(1, std::memory_order_relaxed);
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, LOG_TAG,
                 "OnNativeImageFrameAvailable.ReceivedFrameCount=%{public}lu",
                 renderEngine->receivedVideoFrameCount_.load());
    renderEngine->wakeUpCond_.notify_one();
}
bool RenderEngine::CreateGLResources()
{
    CheckGLError("CreateGLResources before shader");
    shaderProgram_ = std::make_unique<HarmonyVideoEditorRender::ShaderProgram>(Detail::videoVertexShader,
                                                                               Detail::videoFragmentShader);
    if (!shaderProgram_->Valid()) {
        return false;
    }
    imageShaderProgram_ = std::make_unique<HarmonyVideoEditorRender::ShaderProgram>(Detail::imageVertexShader,
                                                                                    Detail::imageFragmentShader);
    if (!imageShaderProgram_->Valid()) {
        return false;
    }
    CheckGLError("CreateGLResources before bind video vao");
    // bind video
    glGenVertexArrays(1, &vertexArrayObject_);
    glGenBuffers(1, &vertexBufferObject_);

    glBindVertexArray(vertexArrayObject_);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObject_);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glVertexAttribPointer(0, VertexAttrib::POSITION_COMPONENTS, GL_FLOAT, GL_FALSE,
                          VertexAttrib::ALL_COMPONENTS * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, VertexAttrib::CORTEX_COMPONENTS, GL_FLOAT, GL_FALSE,
                          VertexAttrib::ALL_COMPONENTS * sizeof(float),
                          (void *)(VertexAttrib::POSITION_COMPONENTS * sizeof(float)));
    glEnableVertexAttribArray(1);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    CheckGLError("CreateGLResources before bind image vao");
    // bind image
    glGenVertexArrays(1, &imageVertexArrayObject_);
    glGenBuffers(1, &imageVertexBufferObject_);
    glBindVertexArray(imageVertexArrayObject_);
    glBindBuffer(GL_ARRAY_BUFFER, imageVertexBufferObject_);
    glBufferData(GL_ARRAY_BUFFER, sizeof(image_vertices), image_vertices, GL_STATIC_DRAW);
    glVertexAttribPointer(0, VertexAttrib::POSITION_COMPONENTS, GL_FLOAT, GL_FALSE,
                          VertexAttrib::ALL_COMPONENTS * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, VertexAttrib::CORTEX_COMPONENTS, GL_FLOAT, GL_FALSE,
                          VertexAttrib::ALL_COMPONENTS * sizeof(float),
                          (void *)(VertexAttrib::POSITION_COMPONENTS * sizeof(float)));
    glEnableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    CheckGLError("CreateGLResources before bind video textures");
    // 绑定视频纹理
    glGenTextures(1, &nativeImageTextureId_);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, nativeImageTextureId_);
    // set the texture wrapping parameters
    glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_WRAP_T, GL_REPEAT);
    // set texture filtering parameters
    glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    // other
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    CheckGLError("CreateGLResources done");
    return true;
}
void RenderEngine::CleanGLResources()
{
    glDeleteVertexArrays(1, &vertexArrayObject_);
    glDeleteBuffers(1, &vertexBufferObject_);
    glDeleteVertexArrays(1, &imageVertexArrayObject_);
    glDeleteBuffers(1, &imageVertexBufferObject_);
    shaderProgram_.reset();
    imageShaderProgram_.reset();
}
void RenderEngine::DestroyNativeImage()
{
    if (nativeImageTextureId_ != 0U) {
        glDeleteTextures(1, &nativeImageTextureId_);
        nativeImageTextureId_ = 0U;
    }

    if (nativeImage_ != nullptr) {
        (void)OH_NativeImage_UnsetOnFrameAvailableListener(nativeImage_);
        OH_NativeImage_Destroy(&nativeImage_);
        nativeImage_ = nullptr;
    }
}
int32_t RenderEngine::Init()
{
    renderContext_ = std::make_unique<EglRenderContext>();
    if (!renderContext_->Init()) {
        return -1;
    }
    return 0;
}
bool ConvertStaticToImageInfo(const StaticImageInfo &src, ImageDetail &dst)
{
    // 1. 检查源数据有效性
    if (!src.nativeBuffer) {
        return false;
    }

    // 2. 复制基础属性
    dst.raw_scale = dst.scale = src.scale;
    dst.raw_pos_x = dst.pos_x = src.pos_x;
    dst.raw_pos_y = dst.pos_y = src.pos_y;
    dst.rotate = src.rotate;
    dst.frames = 1; // 固定为1帧

    dst.AddFrame(src.nativeBuffer, 0);

    return true;
}
bool ConvertDynamicToImageInfo(const DynamicImageInfo &src, ImageDetail &dst)
{
    // 1. 检查源数据有效性
    if (src.nativeBufferArray.empty() || src.nativeBufferArray.size() != src.frameDelayArray.size()) {
        return false;
    }

    // 2. 复制基础属性
    dst.raw_scale = dst.scale = src.scale;
    dst.raw_pos_x = dst.pos_x = src.pos_x;
    dst.raw_pos_y = dst.pos_y = src.pos_y;
    dst.rotate = src.rotate;
    dst.isGif = src.isGif;
    dst.frames = src.nativeBufferArray.size(); // 帧数量

    // 3. 清空目标帧数组（确保干净状态）
    dst.imageFrameArray.clear();
    dst.imageFrameArray.reserve(dst.frames);

    // 4. 遍历所有帧，复制数据
    for (size_t i = 0; i < dst.frames; ++i) {
        auto buffer = src.nativeBufferArray[i];
        uint32_t delay = src.frameDelayArray[i];
        dst.AddFrame(buffer, delay);
    }

    return true;
}
void RenderEngine::ClearImages()
{
    PostTask([this]() { imageManager_->ClearAll(); });
}
bool RenderEngine::RemoveImage(int32_t imageId)
{
    PostTask([this, imageId]() { imageManager_->DeleteById(imageId); });
    return true;
}

int RenderEngine::AddStaticImage(std::shared_ptr<StaticImageInfo> staticImageInfo)
{
    ImageDetail info;
    ConvertStaticToImageInfo(*staticImageInfo, info);
    return DoAddImageInfo(info);
}
int RenderEngine::AddDynamicImage(std::shared_ptr<DynamicImageInfo> dynamicImageInfo)
{
    ImageDetail info;
    ConvertDynamicToImageInfo(*dynamicImageInfo, info);
    return DoAddImageInfo(info);
}
int RenderEngine::DoAddImageInfo(ImageDetail &info)
{
    uint64_t id = GenerateUniqueID();
    info.id = id;
    info.ResetTransform(viewParams_.width, viewParams_.height, outWidth_, outHeight_);
    imageManager_->AddImage(std::make_shared<ImageDetail>(std::move(info)));
    return info.id;
}

OHNativeWindow *RenderEngine::GetInSurface()
{
    std::lock_guard<std::mutex> lock(nativeImageSurfaceIdMutex_);
    CreateNativeImage();
    return inNativeWindow_;
}
int RenderEngine::SetOutSurface(OHNativeWindow *nativeWindow)
{
    if (outNativeWindow_ == nativeWindow) {
        return -1;
    }

    if (outNativeWindow_ != nullptr) {
        OH_NativeWindow_NativeObjectUnreference(outNativeWindow_);
        outNativeWindow_ = nullptr;
    }
    if (outSurface_ != EGL_NO_SURFACE) {
        renderContext_->DestroyEglSurface(outSurface_);
        outSurface_ = EGL_NO_SURFACE;
    }

    if (nativeWindow == nullptr) {
        return 0;
    }
    OH_NativeWindow_NativeWindowHandleOpt(nativeWindow, GET_BUFFER_GEOMETRY, &outHeight_, &outWidth_);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "SetOutSurface.outWidth=%{public}d,outHeight=%{public}d",
                 outWidth_, outHeight_);

    // 计算正确的宽高比
    float windowAspect = static_cast<float>(outWidth_) / static_cast<float>(outHeight_);

    // 创建正交矩阵并复制到固定数组
    glm::mat4 orthoMatrix = glm::ortho(-windowAspect, windowAspect, -1.0f, 1.0f, -1.0f, 1.0f);
    std::copy_n(glm::value_ptr(orthoMatrix), MATRIX_4X4_SIZE, imageOrthoMatrix_);

    outNativeWindow_ = nativeWindow;
    OH_NativeWindow_NativeObjectReference(outNativeWindow_);
    outSurface_ = renderContext_->CreateEglSurface(outNativeWindow_);

    return 0;
}
int RenderEngine::Stop()
{
    CleanGLResources();
    DestroyNativeImage();
    SetOutSurface(nullptr);
    renderContext_.reset();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "RenderEngine stop done .");
    return 0;
}
int RenderEngine::Start()
{
    if (outNativeWindow_ == nullptr) {
        return -1;
    }
    if (nativeImage_ == nullptr) {
        return -1;
    }
    imageManager_->Traverse([this](ImageDetail *detail) {
        detail->ResetTransform(viewParams_.width, viewParams_.height, outWidth_, outHeight_);
    });
    PostTask([this]() {
        if (outSurface_ == EGL_NO_SURFACE) {
            outSurface_ = renderContext_->CreateEglSurface(outNativeWindow_);
        }
        if (outSurface_ == EGL_NO_SURFACE) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, LOG_TAG, "xfl CreateEglSurface failed.");
        } else {
            renderContext_->MakeCurrent(outSurface_);
            CreateGLResources();
            glViewport(0, 0, outWidth_, outHeight_);
            nativeImageFrameAvailableListener_.context = this;
            nativeImageFrameAvailableListener_.onFrameAvailable = &RenderEngine::OnNativeImageFrameAvailable;
            int ret = OH_NativeImage_SetOnFrameAvailableListener(nativeImage_, nativeImageFrameAvailableListener_);
            if (ret != 0) {
                OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, LOG_TAG,
                             "OH_NativeImage_SetOnFrameAvailableListener failed, ret is %{public}d.", ret);
                return;
            }
            OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "RenderEngine init success");
        }
    });

    return 0;
}

int RenderEngine::DrawOneFrame()
{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    shaderProgram_->Use();
    shaderProgram_->SetInt("sTexture", 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, nativeImageTextureId_);
    shaderProgram_->SetMatrix4v("matTransform", videoTransformMatrix_.get(), MATRIX_4X4_SIZE, false);
    shaderProgram_->SetBool("isInputBt601", mediaInfo_.IsBt601());
    shaderProgram_->SetBool("isInputFullRange", mediaInfo_.IsFullRange());

    glBindVertexArray(vertexArrayObject_);
    glDrawArrays(GL_TRIANGLE_FAN, 0, VertexAttrib::RECT_VERTEX_NUMS);

    DrawOutImage();
    if (debugMode_ && debugCallback_ != nullptr) {
        debugCallback_(1);
    }
    renderContext_->SwapBuffers(outSurface_);
    return 0;
}
void RenderEngine::DrawOutImage()
{
    imageManager_->Traverse([this](ImageDetail *imageInfo) {
        glActiveTexture(GL_TEXTURE1);
        imageInfo->BindTexture();
        CheckGLError("draw image load texture");
        std::shared_ptr<ImageFrame> frame = imageInfo->GetCurrentFrame();
        if (frame->IsShowTimeHit(videoCurrentTime)) {
            imageShaderProgram_->Use();
            imageShaderProgram_->SetInt("uFrameIndex", imageInfo->current_frame_index);
            imageShaderProgram_->SetInt("texArray", 1);
            imageShaderProgram_->SetBool("isInputP3", frame->IsP3ColorSpace());
            // 使用预计算的正交矩阵
            imageShaderProgram_->SetMatrix4v("orthoMatrix", imageOrthoMatrix_, MATRIX_4X4_SIZE);
            float matrix[MATRIX_4X4_SIZE];
            imageInfo->GenerateTransformMatrix(outWidth_, outHeight_, matrix);
            imageShaderProgram_->SetMatrix4v("matTransform", matrix, MATRIX_4X4_SIZE);
            CheckGLError("draw image add shader param");

            glBindVertexArray(imageVertexArrayObject_);
            glDrawArrays(GL_TRIANGLE_FAN, 0, VertexAttrib::RECT_VERTEX_NUMS);
            CheckGLError("draw image done");
        } else {
            glBindTexture(GL_TEXTURE_2D, GL_NONE);
        }
        imageInfo->NextFrame(processedVideoFrameCount_.load(), mediaInfo_.frameRate);
    });
}
int32_t RenderEngine::SetInVideoFormat(OH_AVFormat *avFormat)
{
    auto str = OH_AVFormat_DumpInfo(avFormat);
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, LOG_TAG, "SetInVideoFormat,format info: %{public}s", str);
    OH_AVFormat_GetDoubleValue(avFormat, OH_MD_KEY_FRAME_RATE, &mediaInfo_.frameRate);
    OH_AVFormat_GetIntValue(avFormat, OH_MD_KEY_WIDTH, &mediaInfo_.width);
    OH_AVFormat_GetIntValue(avFormat, OH_MD_KEY_HEIGHT, &mediaInfo_.height);
    OH_AVFormat_GetIntValue(avFormat, OH_MD_KEY_ROTATION, &mediaInfo_.rotation);
    OH_AVFormat_GetIntValue(avFormat, OH_MD_KEY_COLOR_PRIMARIES, &mediaInfo_.colorPrimaries);
    OH_AVFormat_GetIntValue(avFormat, OH_MD_KEY_MATRIX_COEFFICIENTS, &mediaInfo_.matrixCoefficients);
    OH_AVFormat_GetIntValue(avFormat, OH_MD_KEY_RANGE_FLAG, &mediaInfo_.rangeFlag);
    OH_AVFormat_GetLongValue(avFormat, OH_MD_KEY_DURATION, &mediaInfo_.duration);
    return 0;
};
void RenderEngine::SetViewParams(ViewParams viewParams) { viewParams_ = viewParams; }
} // namespace HarmonyVideoEditorRender

std::shared_ptr<IGLRenderEngine> IGLRenderEngine::Create()
{
    std::shared_ptr<IGLRenderEngine> engine = std::make_shared<HarmonyVideoEditorRender::RenderEngine>();
    return engine;
}