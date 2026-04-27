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

#include "semanticdense_point_cloud_renderer.h"
#include "semanticdense_ar_application.h"
#include "app_util.h"

int32_t ARSemanticDense::SemanticDensePointCloudRenderer::numberPointCloud = 0;

namespace ARSemanticDense {
    namespace {
        constexpr char VERTEX_SHADER[] = R"(
        attribute vec4 vertex;
        uniform mat4 mvp;
        void main() {
            gl_PointSize = 10.0;
            gl_Position = mvp * vec4(vertex.xyz, 1.0);
        })";

        constexpr char FRAGMENT_SHADER[] = R"(
        precision lowp float;
        void main() {
            gl_FragColor = vec4(0.1215, 0.7372, 0.8235, 1.0);
        })";
    }

    void SemanticDensePointCloudRenderer::InitializePointCloudGlContent()
    {
        mShaderProgram = GLUtils::CreateProgram(VERTEX_SHADER, FRAGMENT_SHADER);
        mAttributeVertices = glGetAttribLocation(mShaderProgram, "vertex");
        mUniformMvpMat = glGetUniformLocation(mShaderProgram, "mvp");
        GLUtils::CheckError(__FILE_NAME__, __LINE__);
    }

    void SemanticDensePointCloudRenderer::Release()
    {
        GLUtils::ReleaseProgram(mShaderProgram);
    }

    void SemanticDensePointCloudRenderer::Draw(glm::mat4 mvpMatrix, const AREngine_ARSemanticDensePointData *pointData, 
        int32_t dataSize)
    {
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_BLEND);

        glUseProgram(mShaderProgram);
    
        if (pointData != nullptr) {
            pointClouldData.clear();
            for (int i = 0; i < dataSize; ++i) {
                pointClouldData.push_back(pointData[i].x);
                pointClouldData.push_back(pointData[i].y);
                pointClouldData.push_back(pointData[i].z);
                pointClouldData.push_back(1.0f);
            }
            glUniformMatrix4fv(mUniformMvpMat, 1, GL_FALSE, glm::value_ptr(mvpMatrix));
            glEnableVertexAttribArray(mAttributeVertices);

            // The point dimension is 4.
            glVertexAttribPointer(mAttributeVertices, 4, GL_FLOAT, GL_FALSE, 0, pointClouldData.data());
            glDrawArrays(GL_POINTS, 0, dataSize);
            glUseProgram(0);
            GLUtils::CheckError(__FILE_NAME__, __LINE__);
        }
    }
}