/**
 * Copyright 2022. Huawei Technologies Co., Ltd. All rights reserved.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#ifndef SEMANTIC_AR_CUBE_RENDERER_H
#define SEMANTIC_AR_CUBE_RENDERER_H

#include <vec3.hpp>
#include <vector>
#include <string>

#include <GLES2/gl2.h>

#include "ar/ar_engine_core.h"

#include <glm.hpp>
#include <gtc/matrix_transform.hpp>
#include <gtc/type_ptr.hpp>
#include <gtx/quaternion.hpp>

namespace ARSemanticDense {
    class SemanticCubeRenderer {
    public:
        SemanticCubeRenderer() = default;

        ~SemanticCubeRenderer() = default;

        /**
         * Initialize the OpenGL state used by the plane renderer.
         */
        void InitializeCubeGlContent();
        void Release();

        /**
         * Draw the provided plane.
         *
         * @param projectionMat Draw the plane projection information matrix.
         * @param viewMat Draw the plane view information matrix.
         * @param session Query the sessions in the plane drawing.
         * @param plane  Plane information of the real world in plane drawing.
         * @param color Color configuration of a plane.
         */
        void Draw(const glm::mat4 &projectionMat, const glm::mat4 &viewMat, AREngine_ARSemanticDenseCubeData *semanticDenseCubeData);
    
        std::string GetVolume();

    private:

        void UpdateForCube(const AREngine_ARSemanticDenseCubeData *cubeData);
        std::string volume = "Length|Width|Height:";
        bool isReturnVolume = false;

        std::vector<glm::vec3> vertices;
        std::vector<GLushort> triangles;
        std::vector<GLushort> lines;
        glm::mat4 modelMat = glm::mat4(1.0f);
        glm::vec3 normalVec = glm::vec3(0.0f);
        GLuint textureId;

        GLuint mShaderProgram;
        GLint mAttriVertices;
        GLint mUniformMvpMat;
        GLint mUniformTexture;
        GLint mUniformModelMat;
        GLint mUniformNormalVec;
        GLint mUniformColor;

        GLuint mWireFrameShaderProgram;
        GLint mWireFrameUniformMvpMat;
        GLint mWireFrameAttriVertices;
    };
}
#endif

