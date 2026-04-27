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

#ifndef C_ARENGINE_SEMANTICDENSE_AR_POINT_CLOUD_RENDERER_H
#define C_ARENGINE_SEMANTICDENSE_AR_POINT_CLOUD_RENDERER_H

#include <vector>

#include <GLES2/gl2.h>

#include "ar/ar_engine_core.h"

#include <glm.hpp>
#include <gtc/matrix_transform.hpp>
#include <gtc/type_ptr.hpp>
#include <gtx/quaternion.hpp>

namespace ARSemanticDense {
    class SemanticDensePointCloudRenderer {
    public:
        SemanticDensePointCloudRenderer() = default;

        ~SemanticDensePointCloudRenderer() = default;

        /**
         * Initial OpenGL status, which needs to be called on the GL thread.
         */
        void InitializePointCloudGlContent();
        void Release();

        /**
         * AR point cloud rendering.
         *
         * @param mvpMatrix Projection matrix of the point cloud model view.
         * @param arSession Query a point cloud session.
         * @param arPointCloud Point the cloud data to the point cloud for rendering.
         */
        void Draw(glm::mat4 mvpMatrix, const AREngine_ARSemanticDensePointData *pointData, int32_t dataSize);
        static int32_t numberPointCloud;

    private:
        GLuint mShaderProgram;
        GLuint mAttributeVertices;
        GLuint mUniformMvpMat;
        std::vector<float> pointClouldData;
    };
}
#endif