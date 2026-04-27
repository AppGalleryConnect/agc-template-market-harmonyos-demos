/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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

#include "depth_render_manager.h"
#include "app_util.h"
#include "depth_ar_application.h"
#include "utils/log.h"
#include <glm.hpp>
#include <gtc/type_ptr.hpp>
#include "renderer_ref.h"

namespace ARDepth {

void DepthRenderManager::Initialize(void *window)
{
    LOGD("DepthRenderManager-----Initialize start.");
    distance = "0 | 0";

    if (!isInited) {
        mRenderContext.Init();
        mRenderSurface.Create(window);
        mRenderContext.MakeCurrent(&mRenderSurface);
        LOGD("DepthRenderManager-----do real Initialize(). get current context %{public}d",
             eglGetCurrentContext() == EGL_NO_CONTEXT);
        if (isRenderer) {
            mBackgroundRenderer.InitializeBackGroundGlContent();
        } else {
            mBackgroundNoRenderer.InitializeBackGroundGlContent();
        }

        isInited = true;
        RenderRef::GetInstance().Increment();
    }

    LOGD("DepthRenderManager-----Initialize end.");
}

void DepthRenderManager::Release()
{
    LOGD("DepthRenderManager-----Release start.");

    if (isInited && RenderRef::GetInstance().IsOne()) {
        if (isRenderer) {
            mBackgroundRenderer.Release();
        } else {
            mBackgroundNoRenderer.Release();
        }
        mRenderContext.ReleaseCurrent();
        LOGD("DepthRenderManager-----do real Release(). get current context %{public}d",
             eglGetCurrentContext() == EGL_NO_CONTEXT);
        mRenderSurface.Release();
        mRenderContext.Release();
        isInited = false;
    }
    RenderRef::GetInstance().Decrement();

    LOGD("DepthRenderManager-----Release end.");
}

void DepthRenderManager::OnDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame)
{
    if (!isInited) {
        LOGE("DepthRenderManager not ready!");
        return;
    }

    glm::mat4 viewMat;
    glm::mat4 projectionMat;

    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    uint32_t textureId = isRenderer ? mBackgroundRenderer.GetTextureId() : mBackgroundNoRenderer.GetTextureId();
    CHECK(HMS_AREngine_ARSession_SetCameraGLTexture(arSession, textureId));
    CHECK(HMS_AREngine_ARSession_Update(arSession, arFrame));
    AREngine_ARCamera *arCamera = nullptr;
    CHECK(HMS_AREngine_ARFrame_AcquireCamera(arSession, arFrame, &arCamera));
    CHECK(HMS_AREngine_ARCamera_GetViewMatrix(arSession, arCamera, glm::value_ptr(viewMat), 16));
    CHECK(HMS_AREngine_ARCamera_GetProjectionMatrix(arSession, arCamera, {0.1f, 100.f}, glm::value_ptr(projectionMat),
                                                    16));
    AREngine_ARTrackingState cameraTrackingState = ARENGINE_TRACKING_STATE_STOPPED;
    CHECK(HMS_AREngine_ARCamera_GetTrackingState(arSession, arCamera, &cameraTrackingState));

    if (cameraTrackingState == ARENGINE_TRACKING_STATE_TRACKING) {
        AREngine_ARImage *depthImage = nullptr;
        auto start = std::chrono::high_resolution_clock::now();
        auto ret = HMS_AREngine_ARFrame_AcquireDepthImage16Bits(arSession, arFrame, &depthImage);
        if (ret != ARENGINE_SUCCESS) {
            LOGW("Ar pose get image, acquire failed %{public}d.", ret);
        }
        auto end = std::chrono::high_resolution_clock::now();
        auto diff = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();

        LOGI("HMS_AREngine_ARFrame_AcquireDepthImage16Bits cost time is : %{public}lu us.", (long)diff);

        AREngine_ARImage *depthConfidenceImage = nullptr;
        ret = HMS_AREngine_ARFrame_AcquireDepthConfidenceImage(arSession, arFrame, &depthConfidenceImage);
        std::string confidence = "error";
        if (ret != ARENGINE_SUCCESS) {
            LOGW("HMS_AREngine_ARFrame_AcquireDepthConfidenceImage failed %{public}d.", ret);
        } else {
            if (depthConfidenceImage != nullptr) {
                uint8_t *depthConfidenceData = nullptr;
                int32_t depthConfidenceLength = 0;
                int32_t depthWidth;
                int32_t depthHeight;
                AREngine_ARImageFormat format;
                CHECK(HMS_AREngine_ARImage_GetPlaneData(arSession, depthConfidenceImage, 0,
                                                        (const uint8_t **)&depthConfidenceData,
                                                        &depthConfidenceLength));
                CHECK(HMS_AREngine_ARImage_GetWidth(arSession, depthImage, &depthWidth));
                CHECK(HMS_AREngine_ARImage_GetHeight(arSession, depthImage, &depthHeight));
                CHECK(HMS_AREngine_ARImage_GetFormat(arSession, depthConfidenceImage, &format));
                auto midConfidence = (depthConfidenceData[depthHeight * depthWidth / 2 + depthWidth / 2]);
                confidence = std::to_string(midConfidence);
                HMS_AREngine_ARImage_Release(depthConfidenceImage);
                LOGI("The confidence is %{public}s, format is %{public}d.", confidence.c_str(), format);
            } else {
                LOGW("The depthConfidenceImage is nullptr.");
            }
        }

        if (depthImage != nullptr) {
            uint8_t *depthData = nullptr;
            int32_t depthLength = 0;
            int32_t depthStride = 0;
            int32_t depthWidth;
            int32_t depthHeight;
            int32_t depthPixStride = 0;
            int32_t depthPlaneCount;
            AREngine_ARImageFormat format;
            int64_t timeStamp;

            CHECK(HMS_AREngine_ARImage_GetFormat(arSession, depthImage, &format));
            CHECK(HMS_AREngine_ARImage_GetTimestamp(arSession, depthImage, &timeStamp));
            CHECK(HMS_AREngine_ARImage_GetPlaneCount(arSession, depthImage, &depthPlaneCount));
            start = std::chrono::high_resolution_clock::now();
            CHECK(HMS_AREngine_ARImage_GetPlaneData(arSession, depthImage, 0, (const uint8_t **)&depthData,
                                                    &depthLength));
            end = std::chrono::high_resolution_clock::now();
            diff = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();

            LOGI("HMS_AREngine_ARImage_GetPlaneData cost time is : %{public}lu us.", (long)diff);
            CHECK(HMS_AREngine_ARImage_GetPlaneRowStride(arSession, depthImage, 0, &depthStride));
            start = std::chrono::high_resolution_clock::now();
            CHECK(HMS_AREngine_ARImage_GetWidth(arSession, depthImage, &depthWidth));
            end = std::chrono::high_resolution_clock::now();
            diff = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
            LOGI("HMS_AREngine_ARImage_GetWidth cost time is : %{public}lu us.", (long)diff);
            start = std::chrono::high_resolution_clock::now();
            CHECK(HMS_AREngine_ARImage_GetHeight(arSession, depthImage, &depthHeight));
            end = std::chrono::high_resolution_clock::now();
            diff = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
            LOGI("HMS_AREngine_ARImage_GetHeight cost time is : %{public}lu us.", (long)diff);
            CHECK(HMS_AREngine_ARImage_GetPlanePixelStride(arSession, depthImage, 0, &depthPixStride));
            LOGD("GetDepthImage depthData: %{public}lu, depthLength %{public}d, depthStride %{public}d, depthWidth "
                 "%{public}d, depthHeight %{public}d format %{public}d timeStamp %{public}lu depthPlaneCount "
                 "%{public}d  depthPixStride %{public}d.",
                 (uintptr_t)depthData, depthLength, depthStride, depthWidth, depthHeight, format, timeStamp,
                 depthPlaneCount, depthPixStride);
            if (saveDepthImage) {
                AREngine_ARImage *image = nullptr;
                uint8_t *imageData = nullptr;
                int32_t imageLength;
                CHECK(HMS_AREngine_ARFrame_AcquireCameraImage(arSession, arFrame, &image));
                int64_t imageTime;
                CHECK(HMS_AREngine_ARImage_GetTimestamp(arSession, image, &imageTime));
                CHECK(
                    HMS_AREngine_ARImage_GetPlaneData(arSession, image, 0, (const uint8_t **)&imageData, &imageLength));
                std::string imagePath = "/data/storage/el2/base/Image_" + std::to_string(imageTime) + ".bin";
                std::string depthPath = "/data/storage/el2/base/DepthImage_" + std::to_string(timeStamp) + ".bin";
                size_t depthImageLength = size_t(depthLength * 2);
                size_t imageDataLength = size_t(imageLength * 1.5);
                if (depthData != nullptr) {
                    WriteBin(depthPath.c_str(), depthData, depthImageLength);
                }
                if (imageData != nullptr) {
                    WriteBin(imagePath.c_str(), imageData, imageDataLength);
                }

                HMS_AREngine_ARImage_Release(image);
            }
            glBindTexture(GL_TEXTURE_2D, textureId);
            if (depthData != nullptr) {
                uint16_t *data = reinterpret_cast<uint16_t *>(depthData);
                if (isRenderer) {
                    glTexImage2D(GL_TEXTURE_2D, 0, GL_RG8, depthWidth, depthHeight, 0, GL_RG, GL_UNSIGNED_BYTE, data);
                }
                auto midDistance = (data[depthHeight * depthWidth / 2 + depthWidth / 2]) / 1000.f;
                LOGI("The %lu distance is %f.", timeStamp, midDistance);
                distance = std::to_string(midDistance).append(" | ").append(confidence);
            }
            if (isRenderer) {
                glBindTexture(GL_TEXTURE_2D, 0);
            }
            HMS_AREngine_ARImage_Release(depthImage);
        } else {
            LOGD("The depth image is null.");
        }
    } else {
        LOGE("[ARDepth][CameraPose] Invalid Tracking State!");
    }

    HMS_AREngine_ARCamera_Release(arCamera);
    if (isRenderer) {
        mBackgroundRenderer.Draw(arSession, arFrame);
    } else {
        mBackgroundNoRenderer.Draw(arSession, arFrame);
    }
    mRenderContext.SwapBuffers(&mRenderSurface);
}

void DepthRenderManager::DrawBlack()
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    mRenderContext.SwapBuffers(&mRenderSurface);
}

std::string DepthRenderManager::GetDistance() { return distance; }

} // namespace ARDepth
