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

#include "semanticdense_render_manager.h"
#include "app_util.h"
#include "semanticdense_ar_application.h"
#include "utils/log.h"
#include <glm.hpp>
#include <gtc/type_ptr.hpp>
#include "renderer_ref.h"

namespace ARSemanticDense {

void SemanticDenseRenderManager::Initialize(void *window, AREngine_ARSession *arSession) {
    LOGD("SemanticDenseRenderManager-----Initialize() start.");

    if (!isInited) {
        mRenderContext.Init();
        LOGD("SemanticDenseRenderManager-----do real Initialize(). get current context %{public}d",
             eglGetCurrentContext() == EGL_NO_CONTEXT);
        mRenderSurface.Create(window);
        mRenderContext.MakeCurrent(&mRenderSurface);

        mPointCloudRenderer.InitializePointCloudGlContent();
        mBackgroundRenderer.InitializeBackGroundGlContent();
        mCubeRenderer.InitializeCubeGlContent();
        CHECK(HMS_AREngine_ARSession_SetCameraGLTexture(arSession, mBackgroundRenderer.GetTextureId()));
        isInited = true;
        RenderRef::GetInstance().Increment();
    }
    LOGD("SemanticDenseRenderManager-----Initialize() end. get current context %{public}d",
         eglGetCurrentContext() == EGL_NO_CONTEXT);
}

void SemanticDenseRenderManager::Release() {
    LOGD("SemanticDenseRenderManager-----Release() start.");

    if (isInited && RenderRef::GetInstance().IsOne()) {
        mCubeRenderer.Release();
        mPointCloudRenderer.Release();
        mBackgroundRenderer.Release();

        mRenderContext.ReleaseCurrent();
        LOGD("SemanticDenseRenderManager-----do real Release(). get current context %{public}d",
             eglGetCurrentContext() == EGL_NO_CONTEXT);
        mRenderSurface.Release();
        mRenderContext.Release();
        isInited = false;

        for (int i = 0; i < 7; ++i) {
            cameraPoseRaw[i] = 0.0f;
        }
    }
    RenderRef::GetInstance().Decrement();
    LOGD("SemanticDenseRenderManager-----Release() end. get current context %{public}d",
         eglGetCurrentContext() == EGL_NO_CONTEXT);
}

void SemanticDenseRenderManager::OnDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame) {
    if (!isInited) {
        LOGE("SemanticDenseRenderManager not ready!.");
        return;
    }
    // Render the scene.
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    CHECK(HMS_AREngine_ARSession_SetCameraGLTexture(arSession, mBackgroundRenderer.GetTextureId()));
    CHECK(HMS_AREngine_ARSession_Update(arSession, arFrame));
    
    glm::mat4 viewMat;
    glm::mat4 projectionMat;
    AREngine_ARCamera *arCamera = nullptr;
    AREngine_ARConfig *arConfig = nullptr;
    CHECK(HMS_AREngine_ARConfig_Create(arSession, &arConfig));
    CHECK(HMS_AREngine_ARFrame_AcquireCamera(arSession, arFrame, &arCamera));
    CHECK(HMS_AREngine_ARCamera_GetViewMatrix(arSession, arCamera, glm::value_ptr(viewMat), 16));
    CHECK(HMS_AREngine_ARCamera_GetProjectionMatrix(arSession, arCamera, {0.1f, 100.f}, glm::value_ptr(projectionMat),
                                                    16));
    modelViewProjection = projectionMat * viewMat;
    AREngine_ARTrackingState cameraTrackingState = ARENGINE_TRACKING_STATE_STOPPED;
    AREngine_ARTrackingStateReason reason = ARENGINE_TRACKING_STATE_REASON_NONE;
    CHECK(HMS_AREngine_ARCamera_GetTrackingState(arSession, arCamera, &cameraTrackingState));
    HMS_AREngine_ARCamera_GetTrackingStateReason(arSession, arCamera, &reason);
    LOGI("[ArSemanticdense][CameraPose] state:%{public}d,  reason:%{public}d", static_cast<int32_t>(cameraTrackingState),
         static_cast<int32_t>(reason));
    
    AREngine_ARSemanticDenseMode outSemanticDenseMode = ARENGINE_SEMANTIC_DENSE_MODE_DISABLED;
    HMS_AREngine_ARConfig_GetSemanticDenseMode(arSession, arConfig, &outSemanticDenseMode);
    LOGD("outSemanticDenseMode in OnDrawFrame is %{public}d", outSemanticDenseMode);
    
    if (cameraTrackingState == ARENGINE_TRACKING_STATE_TRACKING) {
        AREngine_ARPose *cameraPose = nullptr;
        CHECK(HMS_AREngine_ARPose_Create(arSession, nullptr, 0, &cameraPose));
        CHECK(HMS_AREngine_ARCamera_GetPose(arSession, arCamera, cameraPose));
        CHECK(HMS_AREngine_ARPose_GetMatrix(arSession, cameraPose, glm::value_ptr(modelMat), 16));
        HMS_AREngine_ARPose_Destroy(cameraPose);
    } else {
        LOGE("Invalid Tracking State!, cameraTrackingState:%{public}d", cameraTrackingState);
    }
    HMS_AREngine_ARCamera_Release(arCamera);

    // get semanticDense
    AREngine_ARSemanticDenseData *arSemanticDense = nullptr;

    // get semantic dense data
    auto ret = HMS_AREngine_ARFrame_AcquireSemanticDenseData(arSession, arFrame, &arSemanticDense);
    LOGD("HMS_AREngine_ARFrame_AcquireSemanticDenseData result %{public}d", ret);
    AREngine_ARSemanticDensePointData *semanticDensePointData = nullptr;
    int64_t pointDataSize = 0;

    AREngine_ARSemanticDenseCubeData *semanticDenseCubeData = nullptr;
    int64_t cubeDataSize = 0;

    HMS_AREngine_ARSemanticDense_AcquirePointData(arSession, arSemanticDense, &semanticDensePointData);
    HMS_AREngine_ARSemanticDense_AcquirePointDataSize(arSession, arSemanticDense, &pointDataSize);

    LOGI("semanticDensePointData size is %{public}ld", pointDataSize);

    HMS_AREngine_ARSemanticDense_AcquireCubeData(arSession, arSemanticDense, &semanticDenseCubeData);
    HMS_AREngine_ARSemanticDense_AcquireCubeDataSize(arSession, arSemanticDense, &cubeDataSize);
    
    LOGI("semanticDenseCubeData size is %{public}ld", cubeDataSize);
    
    mBackgroundRenderer.Draw(arSession, arFrame);
    if (semanticDensePointData != nullptr && pointDataSize > 0) {
        mPointCloudRenderer.Draw(modelViewProjection, semanticDensePointData, pointDataSize);
    }
    
    if (semanticDenseCubeData != nullptr && cubeDataSize > 0) {
        mCubeRenderer.Draw(projectionMat, viewMat, semanticDenseCubeData);
    }
    
    HMS_AREngine_ARSemanticDense_Release(arSemanticDense);

    mRenderContext.SwapBuffers(&mRenderSurface);
}
std::string SemanticDenseRenderManager::GetVolume() {return mCubeRenderer.GetVolume();}

} // namespace ArSemanticdense
