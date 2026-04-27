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

#include "world_render_manager.h"
#include "app_util.h"
#include "utils/log.h"
#include <glm.hpp>
#include <gtc/matrix_transform.hpp>
#include <gtc/type_ptr.hpp>
#include <gtx/quaternion.hpp>
#include "renderer_ref.h"

int32_t ARWorld::WorldRenderManager::mPlaneCount = 0;
namespace ARWorld {
void WorldRenderManager::Initialize(void *window, AREngine_ARSession *arSession)
{
    LOGI("WorldRenderManager-----Initialize start.");

    if (!isInited) {
        mRenderContext.Init();
        LOGD("WorldRenderManager-----do real Initialize(). get current context %{public}d", eglGetCurrentContext()==EGL_NO_CONTEXT);
        mRenderSurface.Create(window);
        mRenderContext.MakeCurrent(&mRenderSurface);

        mBackgroundRenderer.InitializeBackGroundGlContent();
        mObjectRenderer.InitializeObjectGlContent("AR_logo_obj.obj", "AR_logo.png");
        mPlaneRenderer.InitializePlaneGlContent();
        // Set the OpenGL texture for storing the camera preview stream data. After your app calls
        // HMS_AREngine_ARSession_Update, AR Engine will update the camera preview to the texture.
        CHECK(HMS_AREngine_ARSession_SetCameraGLTexture(arSession, mBackgroundRenderer.GetTextureId()));
        isInited = true;
        RenderRef::GetInstance().Increment();
    }

    LOGI("WorldRenderManager-----Initialize end.");
}

void WorldRenderManager::Release()
{
    LOGD("WorldRenderManager-----Release start.");

    if (isInited && RenderRef::GetInstance().IsOne()) {
        mPlaneRenderer.Release();
        mRenderContext.ReleaseCurrent();
        LOGD("WorldRenderManager-----do real Release(). get current context %{public}d", eglGetCurrentContext()==EGL_NO_CONTEXT);
        mRenderSurface.Release();
        mRenderContext.Release();
        isInited = false;
    }
    RenderRef::GetInstance().Decrement();
    LOGD("WorldRenderManager-----Release end.");
}

void WorldRenderManager::OnDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame,
                                     const std::vector<ColoredAnchor> &mColoredAnchors)
{
    if (!isInited) {
        LOGE("WorldRenderManager not ready!");
        return;
    }

    glm::mat4 viewMat;
    glm::mat4 projectionMat;

    // If the initialization fails, AR scene rendering is not performed.
    if (!InitializeDraw(arSession, arFrame, &viewMat, &projectionMat)) {
        mRenderContext.SwapBuffers(&mRenderSurface);
        return;
    }
    RenderObject(arSession, viewMat, projectionMat, mColoredAnchors);
    RenderPlanes(arSession, viewMat, projectionMat);

    mRenderContext.SwapBuffers(&mRenderSurface);
}

void WorldRenderManager::DrawBlack()
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    mRenderContext.SwapBuffers(&mRenderSurface);
}

bool WorldRenderManager::InitializeDraw(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame, glm::mat4 *viewMat,
                                        glm::mat4 *projectionMat)
{
    // Render the scene.
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if (arSession == nullptr) {
        return false;
    }
    // Obtain the camera parameters of the current frame.
    AREngine_ARCamera *arCamera = nullptr;
    CHECK(HMS_AREngine_ARFrame_AcquireCamera(arSession, arFrame, &arCamera));
    // Obtain the view matrix of the camera in the latest frame.
    CHECK(HMS_AREngine_ARCamera_GetViewMatrix(arSession, arCamera, glm::value_ptr(*viewMat), 16));
    // Obtain the projection matrix used for rendering virtual content on top of the camera image. This matrix can be
    // used for converting from the camera coordinate system to the clip coordinate system. Near (0.1) Far (100).
    CHECK(HMS_AREngine_ARCamera_GetProjectionMatrix(arSession, arCamera, {0.1f, 100.f}, glm::value_ptr(*projectionMat),
                                                    16));
    // Obtain the current tracking status of the camera.
    AREngine_ARTrackingState cameraTrackingState = ARENGINE_TRACKING_STATE_STOPPED;
    CHECK(HMS_AREngine_ARCamera_GetTrackingState(arSession, arCamera, &cameraTrackingState));

    HMS_AREngine_ARCamera_Release(arCamera);
    mBackgroundRenderer.Draw(arSession, arFrame);
    // If the camera is not in tracking state, the current frame is not drawn.
    return !(cameraTrackingState != ARENGINE_TRACKING_STATE_TRACKING);
}

void WorldRenderManager::RenderObject(AREngine_ARSession *arSession, const glm::mat4 &viewMat,
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
            LOGI("WorldRenderManager::RenderObject RenderObject is ARENGINE_TRACKING_STATE_TRACKING!");
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

void WorldRenderManager::RenderPlanes(AREngine_ARSession *arSession, const glm::mat4 &viewMat,
                                      const glm::mat4 &projectionMat)
{
    // Update and render the plane.
    AREngine_ARTrackableList *planeList = nullptr;
    // Create a list of trackable objects.
    CHECK(HMS_AREngine_ARTrackableList_Create(arSession, &planeList));
    // Obtain the list of all trackable objects of the specified type.
    AREngine_ARTrackableType planeTrackedType = ARENGINE_TRACKABLE_PLANE;
    CHECK(HMS_AREngine_ARSession_GetAllTrackables(arSession, planeTrackedType, planeList));

    int32_t planeListSize = 0;
    // Obtain the number of trackable objects in the list.
    CHECK(HMS_AREngine_ARTrackableList_GetSize(arSession, planeList, &planeListSize));
    mPlaneCount = planeListSize;

    for (int i = 0; i < planeListSize; ++i) {
        AREngine_ARTrackable *arTrackable = nullptr;
        // Obtain the object at a specified index from the trackable object list.
        CHECK(HMS_AREngine_ARTrackableList_AcquireItem(arSession, planeList, i, &arTrackable));
        AREngine_ARPlane *arPlane = reinterpret_cast<AREngine_ARPlane *>(arTrackable);

        // Obtain the tracking status of the current trackable object. Plane drawing is performed only when the tracking
        // status is ARENGINE_TRACKING_STATE_TRACKING (trackable).
        AREngine_ARTrackingState outTrackingState;
        CHECK(HMS_AREngine_ARTrackable_GetTrackingState(arSession, arTrackable, &outTrackingState));
        AREngine_ARPlane *subsumePlane = nullptr;
        // Obtain a plane's parent plane (generated when the plane is merged with another one). If there is no parent
        // plane, NULL is returned.
        CHECK(HMS_AREngine_ARPlane_AcquireSubsumedBy(arSession, arPlane, &subsumePlane));
        if (subsumePlane != nullptr) {
            HMS_AREngine_ARTrackable_Release(reinterpret_cast<AREngine_ARTrackable *>(subsumePlane));
            continue;
        }
        if (AREngine_ARTrackingState::ARENGINE_TRACKING_STATE_TRACKING != outTrackingState) {
            continue;
        }
        glm::vec3 color;
        RendererPlane(arPlane, arTrackable, color);
        mPlaneRenderer.Draw(projectionMat, viewMat, arSession, arPlane, color);
    }

    HMS_AREngine_ARTrackableList_Destroy(planeList);
    planeList = nullptr;
}

void WorldRenderManager::RendererPlane(AREngine_ARPlane *arPlane, AREngine_ARTrackable *arTrackable, glm::vec3 &color)
{
    const auto iter = mPlaneColorMap.find(arPlane);
    if (iter != mPlaneColorMap.end()) {
        color = iter->second;
        HMS_AREngine_ARTrackable_Release(arTrackable);
    } else {
        // Set the plane color. The first plane is white, and the other planes are blue.
        if (!firstPlaneHasBeenFound) {
            firstPlaneHasBeenFound = true;
            color = {255, 255, 255};
        } else {
            color = {0, 206, 209};
        }
        mPlaneColorMap.insert(std::pair<AREngine_ARPlane *, glm::vec3>(arPlane, color));
    }
}

} // namespace ARWorld
