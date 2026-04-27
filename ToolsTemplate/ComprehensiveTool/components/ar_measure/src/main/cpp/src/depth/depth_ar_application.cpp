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

#include <window_manager/oh_display_info.h>
#include <window_manager/oh_display_manager.h>
#include "depth_ar_application.h"
#include "app_util.h"

namespace ARDepth {
namespace {
constexpr size_t K_MAX_NUMBER_OF_OBJECT_RENDERED = 10;
}

ARDepthApp::ARDepthApp(std::string &id) : AppNapi(id) { LOGD("ARDepthApp::Constructor"); }

ARDepthApp::~ARDepthApp()
{
    LOGD("ARDepthApp::Destructor");
    mTaskQueue.Stop();
}

void ARDepthApp::OnStart(const ConfigParams &params)
{
    mTaskQueue.Start();
    mTaskQueue.Push([this, params] {
        LOGD("ARDepthApp::OnStart");
        mConfigParam = params;
        // Create an AREngine_ARSession session.
        CHECK(HMS_AREngine_ARSession_Create(nullptr, nullptr, &mArSession));
        // Configure AREngine_ARSession.
        AREngine_ARConfig *arConfig = nullptr;
        mDetphRenderManager.SetRenderer(params.depthRenderMode);
        mDetphRenderManager.SetSaveDepthImage(false);
        CHECK(HMS_AREngine_ARConfig_Create(mArSession, &arConfig));
        CHECK(HMS_AREngine_ARConfig_SetPreviewSize(mArSession, arConfig, 1440, 1080));
        CHECK(HMS_AREngine_ARConfig_SetUpdateMode(mArSession, arConfig, ARENGINE_UPDATE_MODE_LATEST));
        CHECK(HMS_AREngine_ARConfig_SetDepthMode(mArSession, arConfig, ARENGINE_DEPTH_MODE_AUTOMATIC));
        CHECK(HMS_AREngine_ARConfig_SetPlaneFindingMode(mArSession, arConfig, ARENGINE_PLANE_FINDING_MODE_DISABLED));
        CHECK(HMS_AREngine_ARSession_Configure(mArSession, arConfig));
        HMS_AREngine_ARConfig_Destroy(arConfig);
        CHECK(HMS_AREngine_ARFrame_Create(mArSession, &mArFrame));
        NativeDisplayManager_Rotation displayRotation;
        if (OH_NativeDisplayManager_GetDefaultDisplayRotation(&displayRotation) == DISPLAY_MANAGER_OK) {
            mDisplayRotation = ArEngineRotateType(displayRotation);
        }
        CHECK(HMS_AREngine_ARSession_SetDisplayGeometry(mArSession, mDisplayRotation, mWidth, mHeight));
    });
}

void ARDepthApp::OnStop()
{
    isPaused = true;
    mTaskQueue.Push([this] {
        LOGD("ARDepthApp::OnStop");
        if (mArFrame != nullptr) {
            HMS_AREngine_ARFrame_Destroy(mArFrame);
            mArFrame = nullptr;
        }
        if (mArSession != nullptr) {
            HMS_AREngine_ARSession_Destroy(mArSession);
            mArSession = nullptr;
        }
    });
}

void ARDepthApp::OnPause()
{
    isPaused = true;
    mTaskQueue.Push([this] {
        LOGD("ARDepthApp::OnPause");
        CHECK(HMS_AREngine_ARSession_Pause(mArSession));
    });
}

void ARDepthApp::OnResume()
{
    isPaused = false;
    mTaskQueue.Push([this] {
        LOGD("ARDepthApp::OnResume");
        HMS_AREngine_ARSession_Resume(mArSession);
    });
}

void ARDepthApp::OnUpdate()
{
    if (isPaused) {
        LOGI("ARDepthApp::OnUpdate is paused.");
        return;
    }
    mTaskQueue.Push([this] {
        CHECK(HMS_AREngine_ARSession_SetDisplayGeometry(mArSession, mDisplayRotation, mWidth, mHeight));
        if (mIsSurfaceChange) {
            glViewport(0, 0, mWidth, mHeight);
            mDetphRenderManager.DrawBlack();
            mIsSurfaceChange = false;
            return;
        }
        LOGD("ARDepthApp::OnDrawFrame");
        mDetphRenderManager.OnDrawFrame(mArSession, mArFrame);
    });
}

void ARDepthApp::OnSurfaceCreated(OH_NativeXComponent *component, void *window)
{
    LOGD("ARDepthApp::OnSurfaceCreated");

    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &mWidth, &mHeight);
    LOGD("ARDepthApp::OnSurfaceCreated size (%{public}lu, %{public}lu).", mWidth, mHeight);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        ret = OH_NativeXComponent_GetXComponentOffset(component, window, &mX, &mY);
        if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
            LOGE("ARDepthApp::OnSurfaceCreated Offset : x = %{public}lf, y = %{public}lf.", mX, mY);
        }
    }
    mTaskQueue.Push([this, window] {
        LOGD("PoseRenderManager init.");
        mDetphRenderManager.Initialize(window);
    });
}

void ARDepthApp::OnSurfaceChanged(OH_NativeXComponent *component, void *window)
{
    uint64_t width = 1080;
    uint64_t height = 1920;
    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &width, &height);
    LOGD("ARDepthApp::OnSurfaceChanged(%{public}lu, %{public}lu).", width, height);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGD("After width = %lu, height = %lu.", width, height);
        ret = OH_NativeXComponent_GetXComponentOffset(component, window, &mX, &mY);
        if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
            LOGD("Offset : x = %{public}lf, y = %{public}lf.", mX, mY);
        } else {
            LOGE("Failed to get offset.");
        }
    }
    mTaskQueue.Push([this, width, height] {
        mWidth = width;
        mHeight = height;
        mIsSurfaceChange = true;
        NativeDisplayManager_Rotation displayRotation;
        if (OH_NativeDisplayManager_GetDefaultDisplayRotation(&displayRotation) == DISPLAY_MANAGER_OK) {
            mDisplayRotation = ArEngineRotateType(displayRotation);
        }
    });
}

void ARDepthApp::DispatchTouchEvent(OH_NativeXComponent *component, void *window) { LOGD("ArDepthApp::OnTouched"); }

void ARDepthApp::OnSurfaceDestroyed(OH_NativeXComponent *component, void *window)
{
    LOGD("ARDepthApp::OnSurfaceDestroyed");
    mTaskQueue.Push([this] {
        LOGD("DepthRenderManager release.");
        mDetphRenderManager.Release();
    });
}

std::string ARDepthApp::GetDistance() { return mDetphRenderManager.GetDistance(); }
} // namespace ARDepth
