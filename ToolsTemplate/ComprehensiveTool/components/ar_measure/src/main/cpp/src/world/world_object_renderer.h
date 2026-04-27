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

#ifndef C_ARENGINE_WORLD_AR_OBJECT_RENDERER_H
#define C_ARENGINE_WORLD_AR_OBJECT_RENDERER_H

#include "app_util.h"
#include <GLES2/gl2.h>
#include <glm.hpp>

namespace ARWorld {
class WorldObjectRenderer {
public:
    WorldObjectRenderer() = default;

    ~WorldObjectRenderer() = default;

    /**
     * Initialize the OpenGL state, load files and textures,
     * and set the OpenGL resources for drawing the model.
     *
     * @param assetManager Wrapper of the bottom native implementation.
     * @param objFileName Name of the virtual object file to be rendered.
     * @param pngFileName Name of the image file to be drawn.
     */
    void InitializeObjectGlContent(const std::string &objFileName, const std::string &pngFileName);

    /**
     * Draw a virtual object model.
     *
     * @param projectionMat Virtual object projection information matrix.
     * @param viewMat Virtual object view information matrix.
     * @param modelMat Virtual object model information matrix.
     * @param lightIntensity Virtual object light intensity.
     * @param objectColor4 Virtual object color parameter configuration.
     */
    void Draw(const glm::mat4 &projectionMat, const glm::mat4 &viewMat, const glm::mat4 &modelMat, float lightIntensity,
              const float *objectColor4) const;

private:
    float ambient = 0.0f;
    float diffuse = 3.5f;
    float specular = 1.0f;
    float specularOower = 6.0f;

    // Define the model attribute array.
    std::vector<GLfloat> vertices = {};
    std::vector<GLfloat> uvs = {};
    std::vector<GLfloat> normals = {};

    // Define the triangle index of a model.
    std::vector<GLushort> indices = {};

    // Name of the 2D texture object.
    GLuint textureId = 0;

    // Define and initialize the details of the shader program.
    GLuint shaderProgram = 0;
    GLuint attriVertices = 0;
    GLuint attriUvs = 0;
    GLuint attriNormals = 0;
    GLuint uniformMvpMat = 0;
    GLuint uniformMvMat = 0;
    GLuint uniformTexture = 0;
    GLuint uniformLightingParam = 0;
    GLuint uniformMaterialParam = 0;
    GLint uniformColor = 0;
};

} // namespace ARWorld

#endif // C_ARENGINE_WORLD_AR_OBJECT_RENDERER_H
