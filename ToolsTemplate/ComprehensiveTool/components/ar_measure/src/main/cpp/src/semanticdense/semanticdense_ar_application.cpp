/**
 * Copyright 2022. Huawei Technologies Co., Ltd. All rights reserved.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#include <window_manager/oh_display_info.h>
#include <window_manager/oh_display_manager.h>
#include "semanticdense_ar_application.h"
#include "app_util.h"
#include <vector>
std::vector<float> validPoint;
std::vector<float> pointLine;

namespace ARSemanticDense {
namespace {
constexpr size_t K_MAX_NUMBER_OF_OBJECT_RENDERED = 10;
}

ArSemanticDenseApp::ArSemanticDenseApp(std::string &id) : AppNapi(id) { LOGD("ArSemanticDenseApp::Constructor()"); }

ArSemanticDenseApp::~ArSemanticDenseApp()
{
    NativeDestructor();
    mTaskQueue.Stop();
}

void ArSemanticDenseApp::NativeDestructor() { LOGD("ArSemanticDenseApp::Destructor()"); }

void ArSemanticDenseApp::OnStart(const ConfigParams &params) {
    mTaskQueue.Start();
    mTaskQueue.Push([this, params] {
        LOGD("ArSemanticDenseApp::OnStart()");
        CHECK(HMS_AREngine_ARSession_Create(nullptr, nullptr, &mArSession));
    
        AREngine_ARConfig *arConfig = nullptr;
        CHECK(HMS_AREngine_ARConfig_Create(mArSession, &arConfig));
        CHECK(HMS_AREngine_ARConfig_SetPreviewSize(mArSession, arConfig, 1440, 1080));
        CHECK(HMS_AREngine_ARConfig_SetUpdateMode(mArSession, arConfig, ARENGINE_UPDATE_MODE_LATEST));
        CHECK(HMS_AREngine_ARConfig_SetPowerMode(mArSession, arConfig, ARENGINE_POWER_MODE_PERFORMANCE_FIRST));
        CHECK(HMS_AREngine_ARConfig_SetFocusMode(mArSession, arConfig, ARENGINE_FOCUS_MODE_AUTO));
        SetSemanticDenseMode(params.semanticDenseMode, mArSession, arConfig);
        AREngine_ARSemanticDenseMode outSemanticDenseMode = ARENGINE_SEMANTIC_DENSE_MODE_DISABLED;
        HMS_AREngine_ARConfig_GetSemanticDenseMode(mArSession, arConfig, &outSemanticDenseMode);
        CHECK(HMS_AREngine_ARSession_Configure(mArSession, arConfig));
        HMS_AREngine_ARConfig_Destroy(arConfig);
    
        CHECK(HMS_AREngine_ARFrame_Create(mArSession, &mArFrame));
        NativeDisplayManager_Rotation displayRotation;
        if (OH_NativeDisplayManager_GetDefaultDisplayRotation(&displayRotation) == DISPLAY_MANAGER_OK) {
            mDisplayRotation = ArEngineRotateType(displayRotation);
        }
        CHECK(HMS_AREngine_ARSession_SetDisplayGeometry(mArSession, mDisplayRotation, mDisplayWidth, mDisplayHeight));
    });
}

void ArSemanticDenseApp::OnStop() {
    std::lock_guard<std::mutex> lock(mMutex);
    isPaused = true;
    mTaskQueue.Push([this] {
        LOGD("ArSemanticDenseApp::OnStop()");
        if (mArFrame != nullptr) {
            HMS_AREngine_ARFrame_Destroy(mArFrame);
            mArFrame = nullptr;
        }
    
        if (mArSession != nullptr) {
            HMS_AREngine_ARSession_Stop(mArSession);
            HMS_AREngine_ARSession_Destroy(mArSession);
            mArSession = nullptr;
        }
    });
}

void ArSemanticDenseApp::OnPause() {
    isPaused = true;
    mTaskQueue.Push([this] {
        LOGD("ArSemanticDenseApp::OnPause()");
        CHECK(HMS_AREngine_ARSession_Pause(mArSession));
    });
}

void ArSemanticDenseApp::OnResume() {
    isPaused = false;
    mTaskQueue.Push([this] {
        LOGD("ArSemanticDenseApp::OnResume()");
        HMS_AREngine_ARSession_Resume(mArSession);
    });
}

void ArSemanticDenseApp::OnUpdate() {
    if (isPaused) {
        LOGD("ArSemanticDenseApp::OnUpdate is paused.");
        return;
    }
    mTaskQueue.Push([this] {
        HMS_AREngine_ARSession_SetCameraGLTexture(mArSession, mSemanticDenseRenderManager.GetPreviewTextureId());
        CHECK(HMS_AREngine_ARSession_SetDisplayGeometry(mArSession, mDisplayRotation, mDisplayWidth, mDisplayHeight));
        HMS_AREngine_ARSession_Update(mArSession, mArFrame);
        glViewport(0, 0, mDisplayWidth, mDisplayHeight);
        LOGD("ArSemanticApp::OnDrawFrame");
        mSemanticDenseRenderManager.OnDrawFrame(mArSession, mArFrame);
    });
}

void ArSemanticDenseApp::OnSurfaceCreated(OH_NativeXComponent *component, void *window) {
    LOGD("ArSemanticDenseApp::OnSurfaceCreated()");

    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &mDisplayWidth, &mDisplayHeight);
    LOGI("ArSemanticDenseApp::OnSurfaceCreated size (%{public}lu, %{public}lu)", mDisplayWidth, mDisplayHeight);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        ret = OH_NativeXComponent_GetXComponentOffset(component, window, &mX, &mY);
        if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
            LOGE("ArSemanticDenseApp::OnSurfaceCreated Offset : x = %{public}lf, y = %{public}lf ", mX, mY);
        }
    }
    
    mTaskQueue.Push([this, window] {
        LOGD("WorldRenderManager is init.");
        mSemanticDenseRenderManager.Initialize(window, mArSession);
        CHECK(HMS_AREngine_ARSession_SetDisplayGeometry(mArSession, mDisplayRotation, mDisplayWidth, mDisplayHeight));
    });
}

void ArSemanticDenseApp::OnSurfaceChanged(OH_NativeXComponent *component, void *window) {
    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &mDisplayWidth, &mDisplayHeight);
    LOGD("ArSemanticDenseApp::OnSurfaceChanged(%{public}lu, %{public}lu)", mDisplayWidth, mDisplayHeight);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGI("after width = %lu, height = %lu", mDisplayWidth, mDisplayHeight);
        ret = OH_NativeXComponent_GetXComponentOffset(component, window, &mX, &mY);
        if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
            LOGI("Offset : x = %{public}lf, y = %{public}lf ", mX, mY);
        } else {
            LOGE("Offset get failed");
        }
    }

    std::lock_guard<std::mutex> lock(mMutex);
    if (isPaused) {
        LOGI("ArSemanticDenseApp OnSurfaceChanged isPaused!");
        return;
    }
    NativeDisplayManager_Rotation displayRotation;
    if (OH_NativeDisplayManager_GetDefaultDisplayRotation(&displayRotation) == DISPLAY_MANAGER_OK) {
        mDisplayRotation = ArEngineRotateType(displayRotation);
    }
}

void ArSemanticDenseApp::DispatchTouchEvent(OH_NativeXComponent *component, void *window) {
    LOGD("ArSemanticDenseApp::OnTouched()");
}

void ArSemanticDenseApp::OnSurfaceDestroyed(OH_NativeXComponent *component, void *window) {
    LOGD("ArSemanticDenseApp::OnSurfaceDestroyed");
    mTaskQueue.Push([this] {
        LOGD("SemanticDenseRenderManager release.");
        mSemanticDenseRenderManager.Release();
    });
}

void ArSemanticDenseApp::SetSemanticDenseMode(int32_t semanticDenseMode, AREngine_ARSession *mArSession,
    AREngine_ARConfig *arConfig) {
    switch (semanticDenseMode) {
    case 0: // Enable dense point cloud
        CHECK(HMS_AREngine_ARConfig_SetSemanticDenseMode(mArSession, arConfig, ARENGINE_SEMANTIC_DENSE_MODE_NORMAL));
        break;
    case 1: // Open volume recognition
        CHECK(HMS_AREngine_ARConfig_SetSemanticDenseMode(mArSession, arConfig, ARENGINE_SEMANTIC_DENSE_MODE_CUBE_VOLUME));
        break;
    case 2: // Open spatial recognition
        CHECK(HMS_AREngine_ARConfig_SetSemanticDenseMode(mArSession, arConfig, ARENGINE_SEMANTIC_DENSE_MODE_CUBE_SPACE));
        break;
    }
}

std::string ArSemanticDenseApp::GetVolume() { return mSemanticDenseRenderManager.GetVolume(); }

} // namespace ArSemanticdense