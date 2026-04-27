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

#ifndef ARDEMO_IMAGE_DISPLAY_H
#define ARDEMO_IMAGE_DISPLAY_H

#include "app_util.h"
#include "ar/ar_engine_core.h"
#include <GLES2/gl2.h>
#include <cstddef>
#include <glm.hpp>
#include <vector>

enum CornerType {
    /**
     * Upper left corner
     */
    UPPER_LEFT = 0,

    /**
     * Upper right corner
     */
    UPPER_RIGHT = 1,

    /**
     * Lower right corner
     */
    LOWER_RIGHT = 2,

    /**
     * Lower left corner
     */
    LOWER_LEFT = 3,
};

constexpr size_t ARY_SIZE = 2;

class ImageRenderBase {
public:
    virtual void Init() = 0;
    virtual void OnDrawFrame(AREngine_ARSession *arSession, const AREngine_ARAugmentedImage *image,
                             const glm::mat4 &viewMatrix, const glm::mat4 &projectionMatrix) = 0;

protected:
    void CreateImageCorner(AREngine_ARSession *arSession, const AREngine_ARAugmentedImage *trackable,
                           std::vector<float> &cornerPointCoordinates);

    void generateCoefficent(std::vector<float> &coefficient, int coefficentX, int coefficentZ,
                            std::vector<float> coefficients);

protected:
    /**
     * VBO storage location.
     */
    GLuint vbo;

    /**
     * VBO size.
     */
    int vboSize;

    /**
     * Vertices information.
     */
    std::vector<float> pointVertices{};

    int BYTES_PER_CORNER = 4;

    GLuint mVbo;

    GLuint shaderProgram = 0;

    GLuint positionAttribute;

    GLuint modelViewProjectionUniform;

    GLuint colorUniform;
};

#endif // ARDEMO_IMAGE_DISPLAY_H
