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

#include "semanticdense_cube_renderer.h"

#include "app_util.h"

namespace ARSemanticDense {
    namespace {
        constexpr char VERTEX_SHADER_WIREFRAME[] = R"(
        precision highp float;
        precision highp int;
        attribute vec3 vertex;
        uniform mat4 mvp;

        void main() {
            gl_Position = mvp * vec4(vertex.x, vertex.y, vertex.z, 1.0);
        })";

        constexpr char FRAGMENT_SHADER_WIREFRAME[] = R"(
        precision highp float;
        precision highp int;
        void main() {
            gl_FragColor = vec4(1.0, 0.2, 0.0, 0.75);
        })";
    }

    void SemanticCubeRenderer::InitializeCubeGlContent()
    {
        mWireFrameShaderProgram = GLUtils::CreateProgram(VERTEX_SHADER_WIREFRAME, FRAGMENT_SHADER_WIREFRAME);
        mWireFrameUniformMvpMat = glGetUniformLocation(mWireFrameShaderProgram, "mvp");
        mWireFrameAttriVertices = glGetAttribLocation(mWireFrameShaderProgram, "vertex");
    
        GLUtils::CheckError(__FILE_NAME__, __LINE__);
    }

    void SemanticCubeRenderer::Release()
    {
        isReturnVolume = false;
        GLUtils::ReleaseProgram(mShaderProgram);
    }

    void SemanticCubeRenderer::Draw(const glm::mat4 &projectionMat, const glm::mat4 &viewMat, AREngine_ARSemanticDenseCubeData *semanticDenseCubeData)
    {
        if (!mWireFrameShaderProgram) {
            LOGE("mWireFrameShaderProgram is null.");
            return;
        }
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glDepthMask(GL_FALSE);
    
        UpdateForCube(semanticDenseCubeData);

        glUseProgram(mWireFrameShaderProgram);
        glUniformMatrix4fv(mWireFrameUniformMvpMat, 1, GL_FALSE, glm::value_ptr(projectionMat * viewMat));
        glEnableVertexAttribArray(mWireFrameAttriVertices);
        glVertexAttribPointer(mWireFrameAttriVertices, 3, GL_FLOAT, GL_FALSE, 0, vertices.data());
        glLineWidth(12.0f);
        glDrawElements(GL_LINES, lines.size(), GL_UNSIGNED_SHORT, lines.data());

        glUseProgram(0);
        glDepthMask(GL_TRUE);
        GLUtils::CheckError(__FILE_NAME__, __LINE__);
    }

    void SemanticCubeRenderer::UpdateForCube(const AREngine_ARSemanticDenseCubeData *cubeData)
    {
        vertices.clear();
        triangles.clear();
        lines.clear(); 
        volume.clear();
    
        // Starting from index 0 at the bottom left corner of the back side of the cube, moving counterclockwise.
        if (cubeData != nullptr) {
        if (cubeData->vertexData != nullptr) {
            float *verticesData = cubeData->vertexData;
            LOGI("the confidence of cube is %{public}f", cubeData->confidence);
            for (int i = 0; i < 8; ++i) {
                vertices.emplace_back(glm::vec3(verticesData[i*3], verticesData[i*3 + 1], verticesData[i*3 + 2]));
            }
            // Point 1 and Point 2
            auto length = std::abs(std::sqrt((verticesData[6]-verticesData[3]) * (verticesData[6]-verticesData[3])
                                    + (verticesData[7]-verticesData[4]) * (verticesData[7]-verticesData[4])
                                    + (verticesData[8]-verticesData[5]) * (verticesData[8]-verticesData[5])));
            // Point 0 and Point 1
            auto width = std::abs(std::sqrt((verticesData[3]-verticesData[0]) * (verticesData[3]-verticesData[0]) 
                                    + (verticesData[4]-verticesData[1]) * (verticesData[4]-verticesData[1])
                                    + (verticesData[5]-verticesData[2]) * (verticesData[5]-verticesData[2])));
            // Point 0 and Point 4
            auto height = std::abs(std::sqrt((verticesData[12]-verticesData[0]) * (verticesData[12]-verticesData[0]) 
                                    + (verticesData[13]-verticesData[1]) * (verticesData[13]-verticesData[1])
                                    + (verticesData[14]-verticesData[2]) * (verticesData[14]-verticesData[2])));
            if(width >= length){
                std::swap(width, length);
            }
            LOGI("the length width height is: %{public}f, %{public}f, %{public}f.", length, width, height);
            if (length+width+height != 0.0) {
                volume.append("Length|Width|Height:").append(std::to_string(length)).append("m|").append(std::to_string(width)).append("m|").append(std::to_string(height)).append("m");
                isReturnVolume = true;
            }
            LOGI("the volume is:%{public}s", volume.c_str());
        
            for (int i = 0; i < 3; ++i) {
                lines.push_back(i);
                lines.push_back(i + 1);
            }
            for (int i = 4; i < 7; ++i) {
                lines.push_back(i);
                lines.push_back(i + 1);
            }
            lines.push_back(0);
            lines.push_back(3);
            lines.push_back(4);
            lines.push_back(7);
            for (int i = 0; i < 4; ++i) {
                lines.push_back(i);
                lines.push_back(i + 4);
            }
        }
    }
        
    }

    std::string SemanticCubeRenderer::GetVolume()
    {
        if (isReturnVolume) {
            return volume;
        } else {
            return "Length|Width|Height:";
        }
    }
}