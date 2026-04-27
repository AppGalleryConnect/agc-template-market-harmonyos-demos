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

#ifndef C_ARENGINE_WORLD_AR_RENDER_MANAGER_H
#define C_ARENGINE_WORLD_AR_RENDER_MANAGER_H

#include "graphic/RenderContext.h"
#include "graphic/RenderSurface.h"
#include "world_background_renderer.h"
#include "world_object_renderer.h"
#include "world_plane_renderer.h"
#include <glm.hpp>
#include <unordered_map>

namespace ARWorld {
struct ColoredAnchor {
    AREngine_ARAnchor *anchor;
    float color[4];
};

class WorldRenderManager {
public:
    WorldRenderManager() = default;
    ~WorldRenderManager() = default;

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
     * @param coloredAnchors Color parameters required for drawing virtual objects.
     */
    void OnDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame,
                     const std::vector<ColoredAnchor> &coloredAnchors);
    void DrawBlack();

    /**
     * Implement the Draw function of the virtual object module in the rendering manager.
     *
     * @param arSession Implement the session function.
     * @param viewMat Draw the matrix of the virtual object view.
     * @param projectionMat Draw the matrix of the virtual object projection.
     * @param mColoredAnchors Color parameters required for drawing virtual objects.
     */
    void RenderObject(AREngine_ARSession *arSession, const glm::mat4 &viewMat, const glm::mat4 &projectionMat,
                      const std::vector<ColoredAnchor> &mColoredAnchors);

    /**
     * Implement the Draw function of the background module in the rendering manager.
     *
     * @param arSession Implement the session function.
     * @param arFrame Information about each frame during drawing.
     * @param viewMat Draw the background view matrix.
     * @param projectionMat Draw the background projection matrix.
     * @return Background drawing result status.
     */
    bool InitializeDraw(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame, glm::mat4 *viewMat,
                        glm::mat4 *projectionMat);

    /**
     * Implement the Draw function of the plane module in the rendering manager.
     *
     * @param arSession Implement the session function.
     * @param viewMat nformation about each frame during plane drawing.
     * @param projectionMat Draw the plane projection matrix.
     */
    void RenderPlanes(AREngine_ARSession *arSession, const glm::mat4 &viewMat, const glm::mat4 &projectionMat);
    GLuint GetPreviewTextureId() { return mBackgroundRenderer.GetTextureId(); }

    static int32_t mPlaneCount;

private:
    // Store the randomly selected colors used by each plane.
    std::unordered_map<AREngine_ARPlane *, glm::vec3> mPlaneColorMap = {};

    // The first plane is always white, and if true, a plane has been found at a point.
    bool firstPlaneHasBeenFound = false;

    WorldBackgroundRenderer mBackgroundRenderer = ARWorld::WorldBackgroundRenderer();

    WorldPlaneRenderer mPlaneRenderer = ARWorld::WorldPlaneRenderer();

    WorldObjectRenderer mObjectRenderer = ARWorld::WorldObjectRenderer();

    void RendererPlane(AREngine_ARPlane *arPlane, AREngine_ARTrackable *arTrackable, glm::vec3 &color);

    RenderContext mRenderContext;
    RenderSurface mRenderSurface;

    bool isInited = false;
};

} // namespace ARWorld

#endif // C_ARENGINE_WORLD_AR_RENDER_MANAGER_H
