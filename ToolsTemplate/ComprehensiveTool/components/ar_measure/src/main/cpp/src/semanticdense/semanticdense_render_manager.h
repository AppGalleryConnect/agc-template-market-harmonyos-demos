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

#ifndef SEMANTICDENSE_RENDER_MANAGER_H
#define SEMANTICDENSE_RENDER_MANAGER_H

#include <glm.hpp>
#include "ar/ar_engine_core.h"
#include "semanticdense_point_cloud_renderer.h"
#include "semanticdense_cube_renderer.h"
#include "semanticdense_background_renderer.h"
#include "graphic/RenderContext.h"
#include "graphic/RenderSurface.h"
#include <mutex>

namespace ARSemanticDense {

class SemanticDenseRenderManager {
public:
    SemanticDenseRenderManager() = default;
    ~SemanticDenseRenderManager() = default;

    /**
     * Initialize the OpenGL status, including the background,
     * virtual object, point cloud, and plane drawing.
     *
     * @param assetManager Wrapper of the bottom native implementation.
     */
    void Initialize(void *window, AREngine_ARSession *arSession);
    void Release();

    /**
     * The manager, including the background, virtual object, point cloud, and plane drawing.
     *
     * @param arSession Implement the session function.
     * @param arFrame Information about each frame during drawing.
     */
    void OnDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame);
    
    std::string GetVolume();
    
    GLuint GetPreviewTextureId() { return mBackgroundRenderer.GetTextureId(); }
    
private:
    RenderContext mRenderContext;
    RenderSurface mRenderSurface;

    SemanticDenseBackgroundRenderer mBackgroundRenderer;
    SemanticDensePointCloudRenderer mPointCloudRenderer = ARSemanticDense::SemanticDensePointCloudRenderer();
    SemanticCubeRenderer mCubeRenderer;
    
    // Store the randomly selected colors used by each plane.
    std::unordered_map<AREngine_ARPlane *, glm::vec3> mPlaneColorMap = {};
    
    // The first plane is always white, and if true, a plane has been found at a point.
    bool firstPlaneHasBeenFound = false;

    bool isInited = false;
    std::string volume = "Length|Width|Height:";
    bool planTag = false;

    std::mutex mPoseMutex;
    float cameraPoseRaw[8] = {0.0f};
    glm::mat4 modelMat;
    std::vector<float> pointClouldData;
    glm::mat4 modelViewProjection;
    int64_t arPointCloudTime;
};

}
#endif // POSE_RENDER_MANAGER_H