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

#include "image_line_render.h"
#include "gtc/type_ptr.hpp"

namespace {
constexpr char LINE_VERTEX[] = R"(
    uniform vec4 inColor;
    attribute vec4 inPosition;
    varying vec4 varColor;
    uniform mat4 inMVPMatrix;
    void main() {
        gl_Position = inMVPMatrix * vec4(inPosition.xyz, 1.0);
        varColor = inColor;
    }
)";

constexpr char FRAGMENT_SHADER[] = R"(
    precision mediump float;
    varying vec4 varColor;
    void main() {
        gl_FragColor = varColor;
    }
)";
} // namespace

void ImageLineRender::Init()
{
    glGenBuffers(1, &vbo);
    mVbo = vbo;
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, mVboSize, nullptr, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    shaderProgram = GLUtils::CreateProgram(LINE_VERTEX, FRAGMENT_SHADER);
    if (!shaderProgram) {
        LOGE("Could not create program.");
    }

    positionAttribute = glGetAttribLocation(shaderProgram, "inPosition");
    colorUniform = glGetUniformLocation(shaderProgram, "inColor");
    modelViewProjectionUniform = glGetUniformLocation(shaderProgram, "inMVPMatrix");
    GLUtils::CheckError(__FILE_NAME__, __LINE__);
}

void ImageLineRender::OnDrawFrame(AREngine_ARSession *arSession, const AREngine_ARAugmentedImage *trackable,
                                  const glm::mat4 &viewMatrix, const glm::mat4 &projectionMatrix)
{
    CreateImageCorner(arSession, trackable, mCornerPointCoordinates);

    // updateImageKeyLineData-------------
    glm::mat4 vpMatrix = projectionMatrix * viewMatrix;
    mNumPoints = mCornerPointCoordinates.size() / 4;
    glBindBuffer(GL_ARRAY_BUFFER, mVbo);
    int vboSize = mVboSize;
    if (vboSize < mNumPoints * BYTES_PER_POINT) {
        while (vboSize < mNumPoints * BYTES_PER_POINT) {
            // If the size of VBO is insufficient to accommodate the new vertex, resize the VBO.
            vboSize = vboSize * 2;
        }
        glBufferData(GL_ARRAY_BUFFER, vboSize, nullptr, GL_DYNAMIC_DRAW);
    }

    glBufferSubData(GL_ARRAY_BUFFER, 0, mNumPoints * BYTES_PER_POINT, mCornerPointCoordinates.data());
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    //---------------------------------
    // drawImageLine
    glUseProgram(shaderProgram);
    glBindBuffer(GL_ARRAY_BUFFER, mVbo);
    glEnableVertexAttribArray(positionAttribute);
    glVertexAttribPointer(positionAttribute, COORDINATE_DIMENSION, GL_FLOAT, false, BYTES_PER_POINT, 0);
    glUniform4f(colorUniform, 1.0f, 0.0f, 0.0f, 1.0f);
    glUniformMatrix4fv(modelViewProjectionUniform, 1, false, glm::value_ptr(vpMatrix));

    // Set the width of a rendering stroke.
    glLineWidth(5.0f);
    glDrawArrays(GL_LINE_LOOP, 0, mNumPoints);
    glDisableVertexAttribArray(positionAttribute);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    GLUtils::CheckError(__FILE_NAME__, __LINE__);
    mIndex = 0;
}
