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

#ifndef DEPTH_RENDER_MANAGER_H
#define DEPTH_RENDER_MANAGER_H

#include "ar/ar_engine_core.h"
#include "depth_background_no_renderer.h"
#include "depth_background_renderer.h"
#include "graphic/RenderContext.h"
#include "graphic/RenderSurface.h"
#include <mutex>

namespace ARDepth {

class DepthRenderManager {
public:
    DepthRenderManager() = default;
    ~DepthRenderManager() = default;

    /**
     * Initialize the OpenGL status, including the background,
     * virtual object, point cloud, and plane drawing.
     *
     * @param assetManager Wrapper of the bottom native implementation.
     */
    void Initialize(void *window);
    void Release();

    /**
     * The manager, including the background, virtual object, point cloud, and plane drawing.
     *
     * @param arSession Implement the session function.
     * @param arFrame Information about each frame during drawing.
     * @param coloredAnchors Color parameters required for drawing virtual objects.
     */
    void OnDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame);
    void DrawBlack();
    std::string GetDistance();
    void SetSaveDepthImage(bool save) { saveDepthImage = save; }

    void SetRenderer(bool openRendererMode) { isRenderer = openRendererMode; }

private:
    RenderContext mRenderContext;
    RenderSurface mRenderSurface;

    DepthBackgroundRenderer mBackgroundRenderer;
    DepthBackgroundNoRenderer mBackgroundNoRenderer;
    bool isInited = false;

    std::mutex mPoseMutex;
    float cameraPoseRaw[7] = {0.0f};
    std::string distance = "0|0";
    bool saveDepthImage = false;
    bool isRenderer = false;
};

} // namespace ARDepth

#endif // DEPTH_RENDER_MANAGER_H
