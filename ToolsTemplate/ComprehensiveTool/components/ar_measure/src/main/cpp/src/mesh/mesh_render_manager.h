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

#ifndef MESH_RENDER_MANAGER_H
#define MESH_RENDER_MANAGER_H

#include "ar/ar_engine_core.h"
#include "graphic/RenderContext.h"
#include "graphic/RenderSurface.h"
#include "mesh_background_renderer.h"
#include "mesh_object_renderer.h"
#include "scenemesh_display_renderer.h"
#include <cstdint>
#include <mutex>

namespace ARMesh {
struct ColoredAnchor {
    AREngine_ARAnchor *anchor;
    float color[4];
};

class MeshRenderManager {
public:
    MeshRenderManager() = default;
    ~MeshRenderManager() = default;

    /**
     * Initialize the OpenGL status, including the background,
     * virtual object, point cloud, and plane drawing.
     *
     * @param assetManager Wrapper of the bottom native implementation.
     */
    void Initialize(void *window, uint64_t width, uint64_t height);
    void Release();

    /**
     * The manager, including the background, virtual object, point cloud, and plane drawing.
     *
     * @param arSession Implement the session function.
     * @param arFrame Information about each frame during drawing.
     * @param coloredAnchors Color parameters required for drawing virtual objects.
     */
    void OnDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame,
                     const std::vector<ColoredAnchor> &coloredAnchors, uint64_t width, uint64_t height);

    /**
     * Implement the Draw function of the virtual object module in the rendering manager.
     *
     * @param arSession Implement the session function.
     * @param arFrame Information about each frame during drawing.
     * @param viewMat Draw the matrix of the virtual object view.
     * @param projectionMat Draw the matrix of the virtual object projection.
     * @param mColoredAnchors Color parameters required for drawing virtual objects.
     */
    void RenderObject(AREngine_ARSession *arSession, const glm::mat4 &viewMat, const glm::mat4 &projectionMat,
                      const std::vector<ColoredAnchor> &mColoredAnchors);
    void DrawBlack();
    GLuint GetPreviewTextureId() { return mBackgroundRenderer.GetTextureId(); }

private:
    RenderContext mRenderContext;
    RenderSurface mRenderSurface;
    MeshObjectRenderer mObjectRenderer;
    MeshBackgroundRenderer mBackgroundRenderer;
    SceneMeshDisplayRenderer mSceneMeshDisplayRenderer;
    bool isInited = false;
    std::mutex mPoseMutex;
    float cameraPoseRaw[7] = {0.0f};
};

} // namespace ARMesh

#endif // MESH_RENDER_MANAGER_H
