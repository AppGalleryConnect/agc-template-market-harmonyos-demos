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
#include "image_ar_application.h"
#include "app_util.h"
#include "napi_manager.h"

namespace ARImage {

ARImageApp::ARImageApp(std::string &id) : AppNapi(id) { LOGD("ARImageApp::Constructor"); }

ARImageApp::~ARImageApp()
{
    LOGD("ARImageApp::Destructor");
    mTaskQueue.Stop();
}


void ARImageApp::OnStart(const ConfigParams &params)
{
    mConfigParam = params;
    CHECK(HMS_AREngine_ARSession_Create(nullptr, nullptr, &mArSession));
    AREngine_ARConfig *arConfig = nullptr;
    CHECK(HMS_AREngine_ARConfig_Create(mArSession, &arConfig));
    // Set AR type to ARENGINE_TYPE_IMAGE
    CHECK(HMS_AREngine_ARConfig_SetARType(mArSession, arConfig, ARENGINE_TYPE_IMAGE));
    CHECK(HMS_AREngine_ARConfig_SetUpdateMode(mArSession, arConfig, ARENGINE_UPDATE_MODE_BLOCKING));
    CHECK(HMS_AREngine_ARConfig_SetPowerMode(mArSession, arConfig, ARENGINE_POWER_MODE_NORMAL));
    CHECK(HMS_AREngine_ARConfig_SetCameraPreviewMode(mArSession, arConfig, ARENGINE_PREVIEW_MODE_ENABLED));
    CHECK(HMS_AREngine_ARSession_Configure(mArSession, arConfig));
    HMS_AREngine_ARConfig_Destroy(arConfig);

    CHECK(HMS_AREngine_ARFrame_Create(mArSession, &mArFrame));
    NativeDisplayManager_Rotation displayRotation;
    if (OH_NativeDisplayManager_GetDefaultDisplayRotation(&displayRotation) == DISPLAY_MANAGER_OK) {
        mDisplayRotation = ArEngineRotateType(displayRotation);
    }
    CHECK(HMS_AREngine_ARSession_SetDisplayGeometry(mArSession, mDisplayRotation, mWidth, mHeight));
    CHECK(HMS_AREngine_ARAugmentedImageDatabase_Create(&mDataBase));
}

void ARImageApp::OnUpdate()
{
    LOGD("ARWorldApp::OnUpdate is going.");
    CHECK(HMS_AREngine_ARSession_SetDisplayGeometry(mArSession, mDisplayRotation, mWidth, mHeight));
    CHECK(HMS_AREngine_ARSession_SetCameraGLTexture(mArSession, mImageRenderManager.GetBackgroundRender().GetTextureId()));
    
    if (mIsSurfaceChange) { // Folding screen folding, unfolding and switching
        glViewport(0, 0, mWidth, mHeight);
        mImageRenderManager.DrawBlack();
        HMS_AREngine_ARSession_Update(mArSession, mArFrame);
        mIsSurfaceChange = false;
        return;
    }
    std::lock_guard<std::mutex> lock(mImageMutex);
    mImageRenderManager.OnDrawFrame(mArSession, mArFrame);
}

void ARImageApp::OnStop()
{
    isPaused = true;
    LOGI("ARWorldApp::OnStop");
    std::lock_guard<std::mutex> lock(mImageMutex);
    if (mArFrame != nullptr) {
        HMS_AREngine_ARFrame_Destroy(mArFrame);
        mArFrame = nullptr;
    }
    if (mArSession != nullptr) {
        HMS_AREngine_ARSession_Stop(mArSession);
        HMS_AREngine_ARSession_Destroy(mArSession);
        mArSession = nullptr;
        LOGI("HMS_AREngine_ARSession_Stop");
    }
    if (mDataBase != nullptr) {
        HMS_AREngine_ARAugmentedImageDatabase_Destroy(mDataBase);
        mDataBase = nullptr;
        LOGD("HMS_AREngine_ARAugmentedImageDatabase_Destroy");
    }
}

void ARImageApp::OnResume()
{
    auto start = std::chrono::high_resolution_clock::now();
    HMS_AREngine_ARSession_Resume(mArSession);
    auto end = std::chrono::high_resolution_clock::now();
    LOGI("ARImageApp::OnResume cost time is : %{public}lld us.",
         std::chrono::duration_cast<std::chrono::microseconds>(end - start).count());
}

void ARImageApp::OnSurfaceCreated(OH_NativeXComponent *component, void *window)
{
    LOGD("ARImageApp::OnSurfaceCreated");

    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &mWidth, &mHeight);
    LOGI("ARImageApp::OnSurfaceCreated size (%{public}lu, %{public}lu).", mWidth, mHeight);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        ret = OH_NativeXComponent_GetXComponentOffset(component, window, &mX, &mY);
        if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
            LOGE("ARImageApp::OnSurfaceCreated Offset : x = %{public}lf, y = %{public}lf.", mX, mY);
        }
    }
    LOGI("The mImageRenderManager init.");
    mImageRenderManager.Initialize(window);
}

void ARImageApp::OnSurfaceChanged(OH_NativeXComponent *component, void *window)
{
    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &mWidth, &mHeight);
    LOGD("ARImageApp::OnSurfaceChanged(%{public}lu, %{public}lu).", mWidth, mHeight);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGD("After width = %lu, height = %lu.", mWidth, mHeight);
        ret = OH_NativeXComponent_GetXComponentOffset(component, window, &mX, &mY);
        if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
            LOGD("Offset : x = %{public}lf, y = %{public}lf.", mX, mY);
        } else {
            LOGE("Failed to get offset.");
        }
    }
    NativeDisplayManager_Rotation displayRotation;
    if (OH_NativeDisplayManager_GetDefaultDisplayRotation(&displayRotation) == DISPLAY_MANAGER_OK) {
        mDisplayRotation = ArEngineRotateType(displayRotation);
    }

    mIsSurfaceChange = true;
}

void ARImageApp::DispatchTouchEvent(OH_NativeXComponent *component, void *window) { LOGD("ARImageApp::OnTouched"); }

void ARImageApp::OnSurfaceDestroyed(OH_NativeXComponent *component, void *window)
{
    LOGD("ARImageApp::OnSurfaceDestroyed");
    mTaskQueue.Push([this] {
        LOGD("ImageRenderManager release.");
        mImageRenderManager.Release();
    });
}

void ARImageApp::OnPause()
{
    LOGI("ARImageApp::OnPause");
    auto start = std::chrono::high_resolution_clock::now();
    CHECK(HMS_AREngine_ARSession_Pause(mArSession));
    auto end = std::chrono::high_resolution_clock::now();
    LOGI("ARImageApp::OnPause cost time is : %{public}lld us.",
         std::chrono::duration_cast<std::chrono::microseconds>(end - start).count());
}

} // namespace ARImage
