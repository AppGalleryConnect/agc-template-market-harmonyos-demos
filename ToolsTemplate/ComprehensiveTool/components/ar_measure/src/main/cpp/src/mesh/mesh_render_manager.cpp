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

#include "mesh_render_manager.h"
#include "app_util.h"
#include "mesh_ar_application.h"
#include "scenemesh_display_renderer.h"
#include "utils/log.h"
#include <glm.hpp>
#include <gtc/type_ptr.hpp>
#include "renderer_ref.h"

namespace ARMesh {

void MeshRenderManager::Initialize(void *window, uint64_t width, uint64_t height)
{
    LOGD("MeshRenderManager-----Initialize start.");

    if (!isInited) {
        mRenderContext.Init();
        mRenderSurface.Create(window);
        mRenderContext.MakeCurrent(&mRenderSurface);
        LOGD("MeshRenderManager-----do real Initialize(). get current context %{public}d",
             eglGetCurrentContext() == EGL_NO_CONTEXT);

        mBackgroundRenderer.InitializeBackGroundGlContent(width, height);
        mObjectRenderer.InitializeObjectGlContent("AR_logo_obj.obj", "AR_logo.png");
        mSceneMeshDisplayRenderer.InitializeSceneMeshGlContent();

        isInited = true;
        RenderRef::GetInstance().Increment();
    }

    LOGD("MeshRenderManager-----Initialize end.");
}

void MeshRenderManager::Release()
{
    LOGD("MeshRenderManager-----Release start.");

    if (isInited && RenderRef::GetInstance().IsOne()) {
        mBackgroundRenderer.Release();
        mObjectRenderer.Release();
        mSceneMeshDisplayRenderer.Release();
        mRenderContext.ReleaseCurrent();
        LOGD("MeshRenderManager-----do real Release(). get current context %{public}d",
             eglGetCurrentContext() == EGL_NO_CONTEXT);
        mRenderSurface.Release();
        mRenderContext.Release();
        isInited = false;
    }
    RenderRef::GetInstance().Decrement();

    LOGD("MeshRenderManager-----Release end.");
}

void MeshRenderManager::OnDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame,
                                    const std::vector<ColoredAnchor> &mColoredAnchors, uint64_t width, uint64_t height)
{
    if (!isInited) {
        LOGE("PoseRenderManager not ready!");
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
    AREngine_ARCamera *arCamera = nullptr;
    CHECK(HMS_AREngine_ARFrame_AcquireCamera(arSession, arFrame, &arCamera));
    CHECK(HMS_AREngine_ARCamera_GetViewMatrix(arSession, arCamera, glm::value_ptr(viewMat), 16));
    CHECK(HMS_AREngine_ARCamera_GetProjectionMatrix(arSession, arCamera, {0.1f, 100.f}, glm::value_ptr(projectionMat),
                                                    16));
    AREngine_ARTrackingState cameraTrackingState = ARENGINE_TRACKING_STATE_STOPPED;
    CHECK(HMS_AREngine_ARCamera_GetTrackingState(arSession, arCamera, &cameraTrackingState));

    HMS_AREngine_ARCamera_Release(arCamera);
    glBindTexture(GL_TEXTURE_2D, mBackgroundRenderer.GetTextureId());
    mBackgroundRenderer.Draw(arSession, arFrame, width, height);
    mSceneMeshDisplayRenderer.onDrawFrame(arSession, arFrame, viewMat, projectionMat, 
                                          mBackgroundRenderer.m_tex);
    RenderObject(arSession, viewMat, projectionMat, mColoredAnchors);
    mRenderContext.SwapBuffers(&mRenderSurface);
}

void MeshRenderManager::RenderObject(AREngine_ARSession *arSession, const glm::mat4 &viewMat,
                                     const glm::mat4 &projectionMat,
                                     const std::vector<ColoredAnchor> &mColoredAnchors)
{
    // Set the lighting intensity. The value range from 0.0f to 1.0f.
    float lightIntensity = 0.8f;

    // Initialize the model matrix.
    glm::mat4 modelMat(1.0f);
    for (const auto &coloredAnchor : mColoredAnchors) {
        AREngine_ARTrackingState trackingState = ARENGINE_TRACKING_STATE_STOPPED;
        CHECK(HMS_AREngine_ARAnchor_GetTrackingState(arSession, coloredAnchor.anchor, &trackingState));
        if (trackingState == ARENGINE_TRACKING_STATE_TRACKING) {
            LOGI("MeshRenderManager::RenderObject RenderObject is ARENGINE_TRACKING_STATE_TRACKING!");
            LOGI("Mesh start render object!");
            // Draw a virtual object only when the tracking status is AR_TRACKING_STATE_TRACKING.
            AREngine_ARPose *pose = nullptr;
            CHECK(HMS_AREngine_ARPose_Create(arSession, nullptr, 0, &pose));
            CHECK(HMS_AREngine_ARAnchor_GetPose(arSession, coloredAnchor.anchor, pose));
            CHECK(HMS_AREngine_ARPose_GetMatrix(arSession, pose, glm::value_ptr(modelMat), 16));
            HMS_AREngine_ARPose_Destroy(pose);

            // The size of the drawn virtual object is 0.2 times the actual size.
            modelMat = glm::scale(modelMat, glm::vec3(0.2f, 0.2f, 0.2f));
            mObjectRenderer.Draw(projectionMat, viewMat, modelMat, 
                                 lightIntensity, coloredAnchor.color);
        }
    }
}

void MeshRenderManager::DrawBlack()
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    mRenderContext.SwapBuffers(&mRenderSurface);
}

} // namespace ARMesh
