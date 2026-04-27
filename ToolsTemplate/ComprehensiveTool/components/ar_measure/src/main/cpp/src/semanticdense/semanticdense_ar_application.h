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

#ifndef SEMANTICDENSE_AR_APPLICATION_H
#define SEMANTICDENSE_AR_APPLICATION_H

#include <string>
#include <vector>
#include "ar/ar_engine_core.h"
#include "app_util.h"
#include "app_napi.h"
#include "semanticdense_render_manager.h"
#include "task_queue.h" 
extern std::vector<float> validPoint;
extern std::vector<float> pointLine;
namespace ARSemanticDense {

class ArSemanticDenseApp : public AppNapi {
public:
    struct Point {
        double x;
        double y;
    };
    explicit ArSemanticDenseApp(std::string& id);
    ~ArSemanticDenseApp() override;
    void NativeDestructor();
    // Lifecycle
    void OnStart(const ConfigParams& params) override;
    void OnUpdate() override;
    void OnPause() override;
    void OnResume() override;
    void OnStop() override;

    // XComponent Callback 
    void OnSurfaceCreated(OH_NativeXComponent* component, void* window) override;
    void OnSurfaceChanged(OH_NativeXComponent *component, void *window) override;
    void OnSurfaceDestroyed(OH_NativeXComponent *component, void *window) override;
    void DispatchTouchEvent(OH_NativeXComponent *component, void *window) override;
    
    std::string GetVolume() override;
    
    int32_t numberPointCloud;

private:
    void SetSemanticDenseMode(int32_t semanticDenseMode, AREngine_ARSession *mArSession, AREngine_ARConfig *arConfig);
    AREngine_ARSession *mArSession = nullptr;
    AREngine_ARFrame *mArFrame = nullptr;
    std::mutex mImageMutex;
    AREngine_ARImage *mArImage = nullptr;
    AREngine_ARSemanticDenseMode planeRenderMode = ARENGINE_SEMANTIC_DENSE_MODE_DISABLED;
    double mX = 0.0;
    double mY = 0.0;
    uint64_t mDisplayWidth = 1260;
    uint64_t mDisplayHeight = 2506;
    AREngine_ARPoseType mDisplayRotation = ARENGINE_POSE_TYPE_IDENTITY;
    SemanticDenseRenderManager mSemanticDenseRenderManager;
    TaskQueue mTaskQueue;
    std::atomic<bool> isPaused = false;
    std::mutex mMutex;
    glm::mat4 mViewProjection;
};

}
#endif // SEMANTICDENSE_AR_APPLICATION_H