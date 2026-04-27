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

#ifndef SCENEMESH_DISPLAY_RENDERER_H
#define SCENEMESH_DISPLAY_RENDERER_H

#include "app_util.h"
#include "ar/ar_engine_core.h"
#include "fwd.hpp"
#include <GLES2/gl2.h>

namespace ARMesh {

class SceneMeshDisplayRenderer {
public:
    SceneMeshDisplayRenderer() = default;
    ~SceneMeshDisplayRenderer() = default;

    /**
     * Initialize the OpenGL status. This method must be called in the OpenGL thread,
     * and other methods must be called before the methods below.
     */
    void InitializeSceneMeshGlContent();

    void Draw(const glm::mat4 &viewMat, const glm::mat4 &projectionMat);
    void onDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame, const glm::mat4 &viewMat,
                     const glm::mat4 &projectionMat, uint32_t tex);
    void updateSceneMeshData(AREngine_ARSession *session, AREngine_ARSceneMesh *sceneMesh);
    void loadTexture();
    void Release();

private:
    static const int BYTES_PER_FLOAT = sizeof(float);
    static const int FLOATS_PER_POINT = 3;
    static const int BYTES_PER_POINT = BYTES_PER_FLOAT * FLOATS_PER_POINT;
    static const int BUFFER_OBJECT_NUMBER = 2;
    static const int INT_PER_TRIANGLE = 3;
    static const int MODEL_VIEW_PROJ_SIZE = 16;
    static const int POSITION_COMPONENTS_NUMBER = 4;
    GLuint mVerticeVBO;
    int mVerticeVBOSize = 8000; // Initialize the VBO size. The actual size is 7365.
    GLuint mTriangleVBO;
    int mTriangleVBOSize = 5000; // Initialize the size of the triangle VBO. The actual size is 4434.
    GLuint mProgram;
    GLint mPositionAttribute;
    GLint mModelViewProjectionUniform;
    GLint mutex0;
    GLint mutex1;
    GLint color0;
    GLint color1;
    int mPointsNum = 0;
    int mTrianglesNum = 0;
    float mModelViewProjection[MODEL_VIEW_PROJ_SIZE];
    GLuint mTexture = 0;
    GLuint bgTex = 0;
};

} // namespace ARMesh

#endif // MESH_BACKGROUND_RENDERER_H
