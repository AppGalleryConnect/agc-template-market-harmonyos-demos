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
#include "mesh_ar_application.h"
#include "app_util.h"

namespace ARMesh {
namespace {
constexpr size_t K_MAX_NUMBER_OF_OBJECT_RENDERED = 10;
}

ARMeshApp::ARMeshApp(std::string &id) : AppNapi(id) { LOGD("ARMeshthApp::Constructor"); }

ARMeshApp::~ARMeshApp()
{
    LOGD("ARMeshApp::Destructor");
    mTaskQueue.Stop();
}

void ARMeshApp::OnStart(const ConfigParams &params)
{
    mTaskQueue.Start();
    mTaskQueue.Push([this, params] {
        LOGD("ARMeshApp::OnStart");
        mConfigParam = params;
        CHECK(HMS_AREngine_ARSession_Create(nullptr, nullptr, &mArSession));

        AREngine_ARConfig *arConfig = nullptr;
        CHECK(HMS_AREngine_ARConfig_Create(mArSession, &arConfig));
        CHECK(HMS_AREngine_ARConfig_SetPreviewSize(mArSession, arConfig, 1440, 1080));
        CHECK(HMS_AREngine_ARConfig_SetUpdateMode(mArSession, arConfig, ARENGINE_UPDATE_MODE_LATEST));
        CHECK(HMS_AREngine_ARConfig_SetPlaneFindingMode(mArSession, arConfig, ARENGINE_PLANE_FINDING_MODE_DISABLED));
        HMS_AREngine_ARConfig_SetMeshMode(mArSession, arConfig, ARENGINE_MESH_MODE_ENABLED);
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

void ARMeshApp::OnStop()
{
    isPaused = true;
    mTaskQueue.Push([this] {
        for (auto &anchor : mColoredAnchors) {
            CHECK(HMS_AREngine_ARAnchor_Detach(mArSession, anchor.anchor));
            HMS_AREngine_ARAnchor_Release(anchor.anchor);
        }
        mColoredAnchors.clear();
        LOGD("ARMeshApp::OnStop");
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

void ARMeshApp::OnPause()
{
    isPaused = true;
    mTaskQueue.Push([this] {
        LOGD("ARMeshApp::OnPause");
        CHECK(HMS_AREngine_ARSession_Pause(mArSession));
    });
}

void ARMeshApp::OnResume()
{
    isPaused = false;
    mTaskQueue.Push([this] {
        LOGD("ARMeshApp::OnResume");
        HMS_AREngine_ARSession_Resume(mArSession);
    });
}

void ARMeshApp::OnUpdate()
{
    if (isPaused) {
        LOGI("ARMeshApp::OnUpdate is paused.");
        return;
    }
    mTaskQueue.Push([this] {
        HMS_AREngine_ARSession_SetCameraGLTexture(mArSession, mMeshRenderManager.GetPreviewTextureId());
        CHECK(HMS_AREngine_ARSession_SetDisplayGeometry(mArSession, mDisplayRotation, mWidth, mHeight));
        HMS_AREngine_ARSession_Update(mArSession, mArFrame);
        
        if (mIsSurfaceChange) {
            glViewport(0, 0, mWidth, mHeight);
            mMeshRenderManager.DrawBlack();
            
            HMS_AREngine_ARSession_SetCameraGLTexture(mArSession, mMeshRenderManager.GetPreviewTextureId());
            HMS_AREngine_ARSession_Update(mArSession, mArFrame);
            mIsSurfaceChange = false;
            return;
        }
        std::vector<std::pair<float, float>> touchPoints{};
        std::swap(touchPoints, mTouchPoints);
        for (auto &item : touchPoints) {
            DispatchTouchEvent(item.first, item.second);
        }
        LOGD("ARWorldApp::OnDrawFrame");
        mMeshRenderManager.OnDrawFrame(mArSession, mArFrame, mColoredAnchors, mWidth, mHeight);
    });
}

void ARMeshApp::OnSurfaceCreated(OH_NativeXComponent *component, void *window)
{
    LOGD("ARMeshApp::OnSurfaceCreated");

    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &mWidth, &mHeight);
    LOGD("ARMeshApp::OnSurfaceCreated size (%{public}lu, %{public}lu.)", mWidth, mHeight);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        ret = OH_NativeXComponent_GetXComponentOffset(component, window, &mX, &mY);
        if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
            LOGE("ARMeshApp::OnSurfaceCreated Offset : x = %{public}lf, y = %{public}lf.", mX, mY);
        }
    }
    mTaskQueue.Push([this, window] {
        LOGD("MeshRenderManager init.");
        mMeshRenderManager.Initialize(window, mWidth, mHeight);
        CHECK(HMS_AREngine_ARSession_SetDisplayGeometry(mArSession, mDisplayRotation, mWidth, mHeight));
    });
}

void ARMeshApp::OnSurfaceChanged(OH_NativeXComponent *component, void *window)
{
    uint64_t width = 1080;
    uint64_t height = 1920;
    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &width, &height);
    LOGD("ARMeshApp::OnSurfaceChanged(%{public}lu, %{public}lu).", width, height);
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
        mHeight = height;
        mWidth = width;
        mIsSurfaceChange = true;
        NativeDisplayManager_Rotation displayRotation;
        if (OH_NativeDisplayManager_GetDefaultDisplayRotation(&displayRotation) == DISPLAY_MANAGER_OK) {
            mDisplayRotation = ArEngineRotateType(displayRotation);
        }
    });
}

void ARMeshApp::DispatchTouchEvent(OH_NativeXComponent *component, void *window)
{
    LOGD("ARMeshApp::OnTouched");
    float eventX = 0.0f;
    float eventY = 0.0f;
    int32_t ret = OH_NativeXComponent_GetTouchEvent(component, window, &mTouchEvent);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        if (mTouchEvent.type == OH_NATIVEXCOMPONENT_DOWN) {
            eventX = mTouchEvent.touchPoints[0].x;
            eventY = mTouchEvent.touchPoints[0].y;
            LOGD("Pos: %{public}f %{public}f.", eventX, eventY);
        } else {
            return;
        }
    } else {
        LOGE("Touch fail.");
        return;
    }
    if (isPaused) {
        LOGI("ARMeshApp DispatchTouchEvent isPaused!");
        return;
    }
    mTaskQueue.Push([this, eventX, eventY] { mTouchPoints.push_back({eventX, eventY}); });
}

void ARMeshApp::OnSurfaceDestroyed(OH_NativeXComponent *component, void *window)
{
    LOGD("ARMeshApp::OnSurfaceDestroyed");
    mTaskQueue.Push([this] {
        LOGD("MeshRenderManager release.");
        mMeshRenderManager.Release();
    });
}

void ARMeshApp::DispatchTouchEvent(float eventX, float eventY)
{
    AREngine_ARHitResultList *hitResultList = nullptr;
    HMS_AREngine_ARHitResultList_Create(mArSession, &hitResultList);
    HMS_AREngine_ARFrame_HitTest(mArSession, mArFrame, eventX, eventY, hitResultList);
    LOGI("API_TEST HMS_AREngine_ARFrame_HitTest SUCCESS");

    int32_t hitResultListSize = 0;
    CHECK(HMS_AREngine_ARHitResultList_GetSize(mArSession, hitResultList, &hitResultListSize));
    LOGI("The hitResultListSize is %{public}d.", hitResultListSize);
    // The hitTest method sorts the result list by the distance to the camera in ascending order.
    // When responding to user input, the first hit result is usually most relevant.
    AREngine_ARHitResult *arHitResult = nullptr;
    bool hasHitFlag = false;

    if (!GetHitResult(arHitResult, hasHitFlag, hitResultListSize, hitResultList)){
        LOGI("Failed to get mesh hit result.");
        return;
    }

    if (hasHitFlag != true) {
        return;
    }

    if (arHitResult) {
        // Note that the app should release the anchor pointer after using it.
        // Call ArAnchor_release(anchor) to release the anchor.
        AREngine_ARAnchor *anchor = nullptr;
        CHECK(HMS_AREngine_ARHitResult_AcquireNewAnchor(mArSession, arHitResult, &anchor));

        if (mColoredAnchors.size() >= K_MAX_NUMBER_OF_OBJECT_RENDERED) {
            CHECK(HMS_AREngine_ARAnchor_Detach(mArSession, mColoredAnchors[0].anchor));
            HMS_AREngine_ARAnchor_Release(mColoredAnchors[0].anchor);
            mColoredAnchors.erase(mColoredAnchors.begin());
        }

        SetAnchorColour(anchor);
        HMS_AREngine_ARHitResult_Destroy(arHitResult);
        arHitResult = nullptr;

        HMS_AREngine_ARHitResultList_Destroy(hitResultList);
        hitResultList = nullptr;
    } else {
        LOGE("ARMeshApp::OnTouched arHitResult empty.");
    }
}

bool ARMeshApp::GetHitResult(AREngine_ARHitResult *&arHitResult, bool &hasHitFlag, int32_t hitResultListSize,
                             AREngine_ARHitResultList *hitResultList) const
{
    AREngine_ARHitResult *arHit = nullptr;
    CHECK(HMS_AREngine_ARHitResult_Create(mArSession, &arHit));
    if (arHit == nullptr) {
        return false;
    }
    for (int32_t i = 0; i < hitResultListSize; ++i) {
        CHECK(HMS_AREngine_ARHitResultList_GetItem(mArSession, hitResultList, i, arHit));
        LOGD("API_TEST HMS_AREngine_ARHitResultList_GetItem SUCCESS");
        AREngine_ARPose *arPose = nullptr;
        CHECK(HMS_AREngine_ARPose_Create(mArSession, nullptr, 0, &arPose));
        CHECK(HMS_AREngine_ARHitResult_GetHitPose(mArSession, arHit, arPose));
        LOGD("API_TEST HMS_AREngine_ARHitResult_GetHitPose SUCCESS");
        HMS_AREngine_ARPose_Destroy(arPose);
        arHitResult = arHit;
        hasHitFlag = true;
    }
    if (arHitResult != arHit) {
        HMS_AREngine_ARHitResult_Destroy(arHit);
    }
    return true;
}

void ARMeshApp::SetAnchorColour(AREngine_ARAnchor *anchor)
{
    ColoredAnchor coloredAnchor{};
    coloredAnchor.anchor = anchor;
    SetColor(66.0f, 133.0f, 244.0f, 255.0f, coloredAnchor);
    mColoredAnchors.push_back(coloredAnchor);
}

void ARMeshApp::SetColor(float colorR, float colorG, float colorB, float colorA, ColoredAnchor &coloredAnchor)
{
    // Set the color.
    *(coloredAnchor.color) = colorR;
    *(coloredAnchor.color + 1) = colorG;
    *(coloredAnchor.color + 2) = colorB;
    *(coloredAnchor.color + 3) = colorA;
}
} // namespace ARMesh
