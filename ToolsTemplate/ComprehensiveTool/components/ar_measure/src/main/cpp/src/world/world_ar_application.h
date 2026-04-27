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

#ifndef C_ARENGINE_HELLOE_AR_HELLO_AR_APPLICATION_H
#define C_ARENGINE_HELLOE_AR_HELLO_AR_APPLICATION_H

#include "app_napi.h"
#include "ar/ar_engine_core.h"
#include "task_queue.h"
#include "world_background_renderer.h"
#include "world_render_manager.h"
#include <string>

namespace ARWorld {
class ARWorldApp : public AppNapi {
public:
    explicit ARWorldApp(std::string &id);
    ~ARWorldApp() override;

    // Lifecycle
    void OnStart(const ConfigParams &params) override;
    void OnUpdate() override;
    void OnPause() override;
    void OnResume() override;
    void OnStop() override;

    // XComponent Callback
    void OnSurfaceCreated(OH_NativeXComponent *component, void *window) override;
    void OnSurfaceChanged(OH_NativeXComponent *component, void *window) override;
    void OnSurfaceDestroyed(OH_NativeXComponent *component, void *window) override;
    void DispatchTouchEvent(OH_NativeXComponent *component, void *window) override;

private:
    void DispatchTouchEvent(float pixeLX, float pixeLY);

    static void SetColor(float colorR, float colorG, float colorB, float colorA, ColoredAnchor &coloredAnchor);
    bool GetHitResult(AREngine_ARHitResult *&arHitResult, bool &hasHitFlag, int32_t hitResultListSize,
                      AREngine_ARTrackableType &trackableType, AREngine_ARHitResultList *hitResultList) const;
    void SetAnchorColour(AREngine_ARAnchor *anchor, AREngine_ARTrackableType trackableType);

    AREngine_ARSession *mArSession = nullptr;
    AREngine_ARFrame *mArFrame = nullptr;
    std::vector<ColoredAnchor> mColoredAnchors = {};
    uint64_t mWidth = 1080;
    uint64_t mHeight = 1920;
    AREngine_ARPoseType mDisplayRotation = ARENGINE_POSE_TYPE_IDENTITY;
    double mX = 0.0;
    double mY = 0.0;
    OH_NativeXComponent_TouchEvent mTouchEvent;
    WorldRenderManager mWorldRenderManager;
    TaskQueue mTaskQueue;
    bool mIsSurfaceChange = false;
    std::atomic<bool> isPaused = false;
    ConfigParams mConfigParam{};
};
} // namespace ARWorld
#endif // C_ARENGINE_HELLOE_AR_HELLO_AR_APPLICATION_H
