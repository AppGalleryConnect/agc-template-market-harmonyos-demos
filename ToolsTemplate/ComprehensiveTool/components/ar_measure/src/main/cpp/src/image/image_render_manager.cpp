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

#include "image_render_manager.h"
#include "app_util.h"
#include "image_ar_application.h"
#include "utils/log.h"
#include <glm.hpp>
#include <gtc/type_ptr.hpp>
#include "renderer_ref.h"

namespace ARImage {

void ImageRenderManager::Initialize(void *window)
{
    LOGD("ImageRenderManager-----Initialize start.");

    if (!isInited) {
        mRenderContext.Init();
        mRenderSurface.Create(window);
        mRenderContext.MakeCurrent(&mRenderSurface);
        LOGD("ImageRenderManager-----do real Initialize(). get current context %{public}d",
             eglGetCurrentContext() == EGL_NO_CONTEXT);

        mBackgroundRenderer.InitializeBackGroundGlContent();
        ImageLineRender *mLineRender = new ImageLineRender();
        mImageRenderList.push_back(mLineRender);
        for (auto &render : mImageRenderList) {
            render->Init();
        }
        isInited = true;
        RenderRef::GetInstance().Increment();
    }

    LOGD("ImageRenderManager-----Initialize end.");
}

void ImageRenderManager::Release()
{
    LOGD("ImageRenderManager-----Release start.");

    if (isInited && RenderRef::GetInstance().IsOne()) {
        mBackgroundRenderer.Release();

        mRenderContext.ReleaseCurrent();
        LOGD("ImageRenderManager-----do real Release(). get current context %{public}d",
             eglGetCurrentContext() == EGL_NO_CONTEXT);
        mRenderSurface.Release();
        mRenderContext.Release();
        isInited = false;

        for (int i = 0; i < 7; ++i) {
            cameraPoseRaw[i] = 0.0f;
        }
    }
    RenderRef::GetInstance().Decrement();

    LOGD("ImageRenderManager-----Release end.");
}

void ImageRenderManager::OnDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame)
{
    LOGI("ImageRenderManager OnDrawFrame!");
    if (!isInited) {
        LOGE("ImageRenderManager not ready!");
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

    CHECK(HMS_AREngine_ARSession_SetCameraGLTexture(arSession, mBackgroundRenderer.GetTextureId()));
    CHECK(HMS_AREngine_ARSession_Update(arSession, arFrame));

    AREngine_ARCamera *arCamera = nullptr;
    CHECK(HMS_AREngine_ARFrame_AcquireCamera(arSession, arFrame, &arCamera));
    CHECK(HMS_AREngine_ARCamera_GetViewMatrix(arSession, arCamera, glm::value_ptr(viewMat), 16));
    CHECK(HMS_AREngine_ARCamera_GetProjectionMatrix(arSession, arCamera, {0.1f, 100.f}, glm::value_ptr(projectionMat),
                                                    16));
    AREngine_ARTrackingState cameraTrackingState = ARENGINE_TRACKING_STATE_STOPPED;
    AREngine_ARTrackingStateReason reason = ARENGINE_TRACKING_STATE_REASON_NONE;
    CHECK(HMS_AREngine_ARCamera_GetTrackingState(arSession, arCamera, &cameraTrackingState));
    HMS_AREngine_ARCamera_GetTrackingStateReason(arSession, arCamera, &reason);

    HMS_AREngine_ARCamera_Release(arCamera);

    mBackgroundRenderer.Draw(arSession, arFrame);
    ImageRender(arSession, viewMat, projectionMat);
    mRenderContext.SwapBuffers(&mRenderSurface);
}

void ImageRenderManager::DrawBlack()
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    mRenderContext.SwapBuffers(&mRenderSurface);
}

void ImageRenderManager::ImageRender(AREngine_ARSession *arSession, glm::mat4 &viewMat,
                                     const glm::mat4 &projectionMat)
{
    AREngine_ARTrackableList *augmentList = nullptr;
    CHECK(HMS_AREngine_ARTrackableList_Create(arSession, &augmentList));
    CHECK(HMS_AREngine_ARSession_GetAllTrackables(arSession, ARENGINE_TRACKABLE_AUGMENTED_IMAGE, augmentList));

    int32_t augmentSize = 0;
    CHECK(HMS_AREngine_ARTrackableList_GetSize(arSession, augmentList, &augmentSize));

    for (int i = 0; i < augmentSize; ++i) {
        AREngine_ARTrackable *augment = nullptr;
        CHECK(HMS_AREngine_ARTrackableList_AcquireItem(arSession, augmentList, i, &augment));
        uint32_t index = -1;
        char *name = new char[256];
        uint32_t len = 0;
        CHECK(HMS_AREngine_ARAugmentedImage_GetIndex(arSession, reinterpret_cast<AREngine_ARAugmentedImage *>(augment),
                                                     &index));
        CHECK(HMS_AREngine_ARAugmentedImage_AcquireName(
            arSession, reinterpret_cast<AREngine_ARAugmentedImage *>(augment), name, &len));
        LOGI("Get augmented image index and name, index=%{public}d, name:%{public}s.", index, name);

        delete[] name;
        AREngine_ARTrackingState outTrackingState;
        CHECK(HMS_AREngine_ARTrackable_GetTrackingState(arSession, augment, &outTrackingState));
        if (AREngine_ARTrackingState::ARENGINE_TRACKING_STATE_TRACKING != outTrackingState) {
            continue;
        }
        for (auto &render : mImageRenderList) {
            render->OnDrawFrame(arSession, reinterpret_cast<AREngine_ARAugmentedImage *>(augment), viewMat,
                                projectionMat);
        }
    }

    HMS_AREngine_ARTrackableList_Destroy(augmentList);
}

} // namespace ARImage
