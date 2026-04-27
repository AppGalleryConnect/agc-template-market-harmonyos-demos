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

#ifndef DEPTH_AR_APPLICATION_H
#define DEPTH_AR_APPLICATION_H

#include "app_napi.h"
#include "ar/ar_engine_core.h"
#include "depth_render_manager.h"
#include "task_queue.h"

namespace ARDepth {

class ARDepthApp : public AppNapi {
public:
    explicit ARDepthApp(std::string &id);
    ~ARDepthApp() override;

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

    std::string GetDistance() override;

private:
    AREngine_ARSession *mArSession = nullptr;
    AREngine_ARFrame *mArFrame = nullptr;
    std::mutex mImageMutex;
    AREngine_ARImage *mArImage = nullptr;
    double mX = 0.0;
    double mY = 0.0;
    uint64_t mWidth = 1080;
    uint64_t mHeight = 1920;
    AREngine_ARPoseType mDisplayRotation = ARENGINE_POSE_TYPE_IDENTITY;
    DepthRenderManager mDetphRenderManager;
    TaskQueue mTaskQueue;
    std::atomic<bool> isPaused = false;
    bool mIsSurfaceChange = false;
    ConfigParams mConfigParam{};
};

} // namespace ARDepth

#endif // DEPTH_AR_APPLICATION_H
