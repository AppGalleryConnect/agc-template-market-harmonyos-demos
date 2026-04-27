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

#include "world_ar_application.h"
#include "app_util.h"
#include "world_render_manager.h"
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <window_manager/oh_display_info.h>
#include <window_manager/oh_display_manager.h>

namespace ARWorld {
namespace {
constexpr size_t K_MAX_NUMBER_OF_OBJECT_RENDERED = 10;
}

ARWorldApp::ARWorldApp(std::string &id) : AppNapi(id) { LOGD("ARWorldApp::Constructor"); }

ARWorldApp::~ARWorldApp()
{
    LOGD("ARWorldApp::Destructor");
    mTaskQueue.Stop();
}

void ARWorldApp::OnStart(const ConfigParams &params)
{
    mTaskQueue.Start();
    mTaskQueue.Push([this, params] {
        mConfigParam = params;
        // Create an AREngine_ARSession session.
        CHECK(HMS_AREngine_ARSession_Create(nullptr, nullptr, &mArSession));
        // Configure AREngine_ARSession.
        AREngine_ARConfig *arConfig = nullptr;
        CHECK(HMS_AREngine_ARConfig_Create(mArSession, &arConfig));
        // Set the preview image size.
        CHECK(HMS_AREngine_ARConfig_SetPreviewSize(mArSession, arConfig, 1440, 1080));
        // Set the image update mode.
        CHECK(HMS_AREngine_ARConfig_SetUpdateMode(mArSession, arConfig, ARENGINE_UPDATE_MODE_LATEST));
        CHECK(HMS_AREngine_ARSession_Configure(mArSession, arConfig));
        HMS_AREngine_ARConfig_Destroy(arConfig);
        // Create an AREngine_ARFrame object.
        CHECK(HMS_AREngine_ARFrame_Create(mArSession, &mArFrame));
        NativeDisplayManager_Rotation displayRotation;
        if (OH_NativeDisplayManager_GetDefaultDisplayRotation(&displayRotation) == DISPLAY_MANAGER_OK) {
            mDisplayRotation = ArEngineRotateType(displayRotation);
        }
        HMS_AREngine_ARSession_SetCameraGLTexture(mArSession, mWorldRenderManager.GetPreviewTextureId());
        CHECK(HMS_AREngine_ARSession_SetDisplayGeometry(mArSession, mDisplayRotation, mWidth, mHeight));
        // Set the display height and width (in pixels). Make sure that the height and width you set here are consistent
        // with those of the display view.
    });
}

void ARWorldApp::OnStop()
{
    isPaused = true;
    mTaskQueue.Push([this] {
        LOGD("ARWorldApp::OnStop");
        for (auto &anchor : mColoredAnchors) {
            CHECK(HMS_AREngine_ARAnchor_Detach(mArSession, anchor.anchor));
            HMS_AREngine_ARAnchor_Release(anchor.anchor);
        }
        mColoredAnchors.clear();

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

void ARWorldApp::OnPause()
{
    isPaused = true;
    mTaskQueue.Push([this] { CHECK(HMS_AREngine_ARSession_Pause(mArSession)); });
}

void ARWorldApp::OnResume()
{
    isPaused = false;
    mTaskQueue.Push([this] { HMS_AREngine_ARSession_Resume(mArSession); });
}

void ARWorldApp::OnUpdate()
{
    if (isPaused) {
        LOGD("ARWorldApp::OnUpdate is paused.");
        return;
    }
    mTaskQueue.Push([this] {
        CHECK(HMS_AREngine_ARSession_SetDisplayGeometry(mArSession, mDisplayRotation, mWidth, mHeight));
        HMS_AREngine_ARSession_Update(mArSession, mArFrame);
        if (mIsSurfaceChange) {
            glViewport(0, 0, mWidth, mHeight);
            mWorldRenderManager.DrawBlack();
            mIsSurfaceChange = false;
            return;
        }
        LOGD("ARWorldApp::OnDrawFrame");
        mWorldRenderManager.OnDrawFrame(mArSession, mArFrame, mColoredAnchors);
    });
}

void ARWorldApp::OnSurfaceCreated(OH_NativeXComponent *component, void *window)
{
    LOGD("ARWorldApp::OnSurfaceCreated");

    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &mWidth, &mHeight);
    LOGD("ARWorldApp::OnSurfaceCreated size (%{public}lu, %{public}lu).", mWidth, mHeight);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        ret = OH_NativeXComponent_GetXComponentOffset(component, window, &mX, &mY);
        if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
            LOGE("ARWorldApp::OnSurfaceCreated Offset : x = %{public}lf, y = %{public}lf.", mX, mY);
        }
    }

    mTaskQueue.Push([this, window] {
        LOGD("WorldRenderManager is init.");
        mWorldRenderManager.Initialize(window, mArSession);
    });
}

void ARWorldApp::OnSurfaceChanged(OH_NativeXComponent *component, void *window)
{
    uint64_t width = 1080;
    uint64_t height = 1920;
    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &width, &height);
    LOGD("ARWorldApp::OnSurfaceChanged(%{public}lu, %{public}lu).", width, height);
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

void ARWorldApp::DispatchTouchEvent(float pixeLX, float pixeLY)
{
    AREngine_ARHitResultList *hitResultList = nullptr;
    CHECK(HMS_AREngine_ARHitResultList_Create(mArSession, &hitResultList));
    CHECK(HMS_AREngine_ARFrame_HitTest(mArSession, mArFrame, pixeLX, pixeLY, hitResultList));

    int32_t hitResultListSize = 0;
    CHECK(HMS_AREngine_ARHitResultList_GetSize(mArSession, hitResultList, &hitResultListSize));
    LOGD("HMS_AREngine_ARHitResultList_GetSize is %{public}d.", hitResultListSize);
    // The hitTest method sorts the result list by the distance to the camera in ascending order.
    // When responding to user input, the first hit result is usually most relevant.
    AREngine_ARHitResult *arHitResult = nullptr;
    AREngine_ARTrackableType trackableType = ARENGINE_TRACKABLE_INVALID;
    bool hasHitFlag = false;

    if (!GetHitResult(arHitResult, hasHitFlag, hitResultListSize, 
                      trackableType, hitResultList)) {
        return;
    }
    if (hasHitFlag != true) {
        return;
    }
    if (arHitResult) {
        // Note that the app should release the anchor pointer after using it.
        // Call ArAnchor_release(anchor) to release the anchor.
        // Create an anchor at the hit point.
        AREngine_ARAnchor *anchor = nullptr;
        CHECK(HMS_AREngine_ARHitResult_AcquireNewAnchor(mArSession, arHitResult, &anchor));

        AREngine_ARTrackingState trackingState = ARENGINE_TRACKING_STATE_STOPPED;
        CHECK(HMS_AREngine_ARAnchor_GetTrackingState(mArSession, anchor, &trackingState));
        if (trackingState != ARENGINE_TRACKING_STATE_TRACKING) {
            HMS_AREngine_ARAnchor_Release(anchor);
            return;
        }
        if (mColoredAnchors.size() >= K_MAX_NUMBER_OF_OBJECT_RENDERED) {
            CHECK(HMS_AREngine_ARAnchor_Detach(mArSession, mColoredAnchors[0].anchor));
            HMS_AREngine_ARAnchor_Release(mColoredAnchors[0].anchor);
            mColoredAnchors.erase(mColoredAnchors.begin());
        }
        SetAnchorColour(anchor, trackableType);
        HMS_AREngine_ARHitResult_Destroy(arHitResult);
        arHitResult = nullptr;

        HMS_AREngine_ARHitResultList_Destroy(hitResultList);
        hitResultList = nullptr;
    } else {
        LOGE("ARWorldApp::OnTouched arHitResult empty.");
    }
}

void ARWorldApp::DispatchTouchEvent(OH_NativeXComponent *component, void *window)
{
    LOGD("ARWorldApp::DispatchTouchEvent");
    float pixeLX = 0.0f;
    float pixeLY = 0.0f;
    int32_t ret = OH_NativeXComponent_GetTouchEvent(component, window, &mTouchEvent);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        if (mTouchEvent.type == OH_NATIVEXCOMPONENT_DOWN) {
            pixeLX = mTouchEvent.touchPoints[0].x;
            pixeLY = mTouchEvent.touchPoints[0].y;
            LOGD("Pos: %{public}f %{public}f.", pixeLX, pixeLY);
        } else {
            return;
        }
    } else {
        LOGE("Touch fail");
        return;
    }

    mTaskQueue.Push([this, pixeLX, pixeLY] {
        if (isPaused) {
            LOGI("ARWorldApp DispatchTouchEvent isPaused!");
            return;
        }
        DispatchTouchEvent(pixeLX, pixeLY);
    });
}

void ARWorldApp::OnSurfaceDestroyed(OH_NativeXComponent *component, void *window)
{
    LOGD("ARWorldApp::OnSurfaceDestroyed");
    mTaskQueue.Push([this] {
        LOGD("WorldRenderManager release.");
        mWorldRenderManager.Release();
    });
}

bool ARWorldApp::GetHitResult(AREngine_ARHitResult *&arHitResult, bool &hasHitFlag, int32_t hitResultListSize,
                              AREngine_ARTrackableType &trackableType, AREngine_ARHitResultList *hitResultList) const
{
    for (int32_t i = 0; i < hitResultListSize; ++i) {
        AREngine_ARHitResult *arHit = nullptr;
        CHECK(HMS_AREngine_ARHitResult_Create(mArSession, &arHit));
        CHECK(HMS_AREngine_ARHitResultList_GetItem(mArSession, hitResultList, i, arHit));

        if (arHit == nullptr) {
            return false;
        }

        AREngine_ARTrackable *arTrackable = nullptr;
        CHECK(HMS_AREngine_ARHitResult_AcquireTrackable(mArSession, arHit, &arTrackable));
        AREngine_ARTrackableType ar_trackable_type = ARENGINE_TRACKABLE_INVALID;
        CHECK(HMS_AREngine_ARTrackable_GetType(mArSession, arTrackable, &ar_trackable_type));

        // If a plane or directional point is encountered, an anchor point is created.
        if (ARENGINE_TRACKABLE_PLANE == ar_trackable_type) {
            AREngine_ARPose *arPose = nullptr;
            CHECK(HMS_AREngine_ARPose_Create(mArSession, nullptr, 0, &arPose));
            CHECK(HMS_AREngine_ARHitResult_GetHitPose(mArSession, arHit, arPose));
            int32_t inPolygon = 0;
            AREngine_ARPlane *arPlane = reinterpret_cast<AREngine_ARPlane *>(arTrackable);
            // Check whether the pose is within the plane's bounding polygon. Value 0 indicates that it is out of the
            // range, and other values indicate that it is within the range.
            CHECK(HMS_AREngine_ARPlane_IsPoseInPolygon(mArSession, arPlane, arPose, &inPolygon));
            HMS_AREngine_ARPose_Destroy(arPose);
            if (!inPolygon) {
                continue;
            }

            arHitResult = arHit;
            trackableType = ar_trackable_type;
            hasHitFlag = true;
            break;
        }
    }
    return true;
}

void ARWorldApp::SetAnchorColour(AREngine_ARAnchor *anchor, AREngine_ARTrackableType trackableType)
{
    ColoredAnchor coloredAnchor{};
    coloredAnchor.anchor = anchor;
    switch (trackableType) {
    case ARENGINE_TRACKABLE_PLANE:
        // Set the anchor color when the anchor is generated due to click on the point cloud.
        SetColor(139.0f, 195.0f, 74.0f, 255.0f, coloredAnchor);
        break;
    default:
        // The virtual object is not displayed if it is not generated by click on the point cloud or plane.
        SetColor(0.0f, 0.0f, 0.0f, 0.0f, coloredAnchor);
        break;
    }
    mColoredAnchors.push_back(coloredAnchor);
}

void ARWorldApp::SetColor(float colorR, float colorG, float colorB, float colorA, ColoredAnchor &coloredAnchor)
{
    // Set the color.
    *(coloredAnchor.color) = colorR;
    *(coloredAnchor.color + 1) = colorG;
    *(coloredAnchor.color + 2) = colorB;
    *(coloredAnchor.color + 3) = colorA;
}
} // namespace ARWorld
