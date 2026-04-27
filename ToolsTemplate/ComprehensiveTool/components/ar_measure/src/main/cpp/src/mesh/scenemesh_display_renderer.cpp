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

#include "scenemesh_display_renderer.h"
#include "app_util.h"
#include "utils/log.h"
#include <glm.hpp>
#include <gtc/type_ptr.hpp>

#include <cstdint>

namespace ARMesh {
namespace {
constexpr char SCENE_MESH_VERTEX[] = R"(#version 320 es
    precision mediump float;
    uniform mat4 u_ModelViewProjection;
    layout (location = 0) in vec4 a_Position;
    layout (location = 0) out vec3 v_ZCoord;
    layout (location = 1) out vec4 v_Coord;
    const vec3 zCoord[] = vec3[](
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, 1.0, 0.0),
        vec3(0.0, 0.0, 1.0)
    );

    void main() {
        vec4 ppp = u_ModelViewProjection * vec4(a_Position.xyz, 1.0);
        v_Coord = ppp;
        gl_Position = ppp;
        v_ZCoord = zCoord[gl_VertexID % 3];
    }
)";

constexpr char SCENE_MESH_FRAGMENT[] = R"(#version 320 es
    precision mediump float;
    uniform sampler2D u_bgTex;
    uniform vec4 v_color;
    uniform vec4 l_color;
    layout (location = 0) in vec3 v_ZCoord;
    layout (location = 1) in vec4 v_Coord;
    layout (location = 0) out vec4 fragColor;

    float edge() {
        vec3 w = fwidth(v_ZCoord);
        vec3 s = smoothstep(vec3(0.0), w * 2.0, v_ZCoord);
        return min(min(s.x, s.y), s.z);
    }

    void main() {
        vec3 coord = v_Coord.xyz / v_Coord.w * 0.5 + 0.5;
        vec4 bgColor = texture(u_bgTex, coord.xy);
        fragColor = mix(v_color, bgColor, edge());
    }
)";
} // namespace

void SceneMeshDisplayRenderer::InitializeSceneMeshGlContent()
{
    GLuint buffers[BUFFER_OBJECT_NUMBER];
    glGenBuffers(BUFFER_OBJECT_NUMBER, buffers);
    mVerticeVBO = buffers[0];
    mTriangleVBO = buffers[1];

    glBindBuffer(GL_ARRAY_BUFFER, mVerticeVBO);
    glBufferData(GL_ARRAY_BUFFER, mVerticeVBOSize * BYTES_PER_POINT, NULL, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mTriangleVBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, mTriangleVBOSize * BYTES_PER_FLOAT, NULL, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    GLUtils::CheckError(__FILE_NAME__, __LINE__);

    mProgram = GLUtils::CreateProgram(SCENE_MESH_VERTEX, SCENE_MESH_FRAGMENT);
    if (!mProgram) {
        LOGE("Could not create program.");
    }
    glUseProgram(mProgram);
    GLUtils::CheckError(__FILE_NAME__, __LINE__);

    mPositionAttribute = glGetAttribLocation(mProgram, "a_Position");
    mModelViewProjectionUniform = glGetUniformLocation(mProgram, "u_ModelViewProjection");
    mutex0 = glGetUniformLocation(mProgram, "u_Texture");
    mutex1 = glGetUniformLocation(mProgram, "u_bgTex");
    color0 = glGetUniformLocation(mProgram, "v_color");
    loadTexture();
    GLUtils::CheckError(__FILE_NAME__, __LINE__);
}

void SceneMeshDisplayRenderer::loadTexture()
{
    // Generate texture ID and load it into GPU memory
    glGenTextures(1, &mTexture);
    glBindTexture(GL_TEXTURE_2D, mTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    if (!LoadPngFromAssetManager("grid.png")) {
        LOGE("Could not load png texture for planes.");
    }

    glGenerateMipmap(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, 0);
    GLUtils::CheckError(__FILE_NAME__, __LINE__);
}

void SceneMeshDisplayRenderer::updateSceneMeshData(AREngine_ARSession *session, AREngine_ARSceneMesh *sceneMesh)
{
    int32_t meshVerticesSize = 0;
    HMS_AREngine_ARSceneMesh_AcquireVerticesSize(session, sceneMesh, &meshVerticesSize);
    LOGD("HMS_AREngine_ARSceneMesh_AcquireVerticesSize size=%{public}d.", meshVerticesSize);
    float *meshVertices = new float[meshVerticesSize];
    auto ret = HMS_AREngine_ARSceneMesh_AcquireVertexList(session, sceneMesh, meshVertices, meshVerticesSize);
    LOGD("HMS_AREngine_ARSceneMesh_AcquireVertexList result=%{public}d.", ret);

    mPointsNum = meshVerticesSize / FLOATS_PER_POINT;
    glBindBuffer(GL_ARRAY_BUFFER, mVerticeVBO);
    std::vector<float> vertexData(meshVertices, meshVertices + meshVerticesSize);
    if (mVerticeVBOSize < mPointsNum * BYTES_PER_POINT) {
        while (mVerticeVBOSize < mPointsNum * BYTES_PER_POINT) {
            mVerticeVBOSize *= 2;
        }
        glBufferData(GL_ARRAY_BUFFER, mVerticeVBOSize, nullptr, GL_DYNAMIC_DRAW);
    }
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    delete[] meshVertices;

    // test HMS_AREngine_ARSceneMesh_AcquireVertexNormalList
    float *normalList = new float[meshVerticesSize];
    ret = HMS_AREngine_ARSceneMesh_AcquireVertexNormalList(session, sceneMesh, normalList, meshVerticesSize);
    LOGD("HMS_AREngine_ARSceneMesh_AcquireVertexNormalList result=%{public}d.", ret);
    delete[] normalList;

    int32_t triangleIndicesSize = 0;
    HMS_AREngine_ARSceneMesh_AcquireIndexListSize(session, sceneMesh, &triangleIndicesSize);
    LOGD("HMS_AREngine_ARSceneMesh_AcquireIndexListSize size=%{public}d.", triangleIndicesSize);

    int32_t *meshTriangleIndices = new int32_t[triangleIndicesSize];
    ret = HMS_AREngine_ARSceneMesh_AcquireIndexList(session, sceneMesh, meshTriangleIndices, triangleIndicesSize);
    LOGD("HMS_AREngine_ARSceneMesh_AcquireIndexList result=%{public}d.", ret);

    mTrianglesNum = triangleIndicesSize / INT_PER_TRIANGLE;
    std::vector<int32_t> indexData(meshTriangleIndices, meshTriangleIndices + triangleIndicesSize);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mTriangleVBO);
    if (mTriangleVBOSize < mTrianglesNum * BYTES_PER_POINT) {
        while (mTriangleVBOSize < mTrianglesNum * BYTES_PER_POINT) {
            mTriangleVBOSize *= 2;
        }
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, mTriangleVBOSize, nullptr, GL_DYNAMIC_DRAW);
    }
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, mTrianglesNum * BYTES_PER_POINT, meshTriangleIndices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    delete[] meshTriangleIndices;

    std::vector<float> sortVertices;
    for (int32_t index : indexData) {
        int startIndex = index * 3;
        for (int i = 0; i < 3; ++i) {
            sortVertices.push_back(vertexData[startIndex + i]);
        }
    }
    glBindBuffer(GL_ARRAY_BUFFER, mVerticeVBO);
    glBufferData(GL_ARRAY_BUFFER, sortVertices.size() * BYTES_PER_FLOAT, nullptr, GL_DYNAMIC_DRAW);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sortVertices.size() * BYTES_PER_FLOAT, sortVertices.data());
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void SceneMeshDisplayRenderer::Draw(const glm::mat4 &viewMat, const glm::mat4 &projectionMat)
{
    LOGE("ARSceneMesh Draw Start.");
    // Check for OpenGL errors before drawing
    GLUtils::CheckError(__FILE_NAME__, __LINE__);

    // Enable depth testing and face culling
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glDisable(GL_BLEND);
    glDepthMask(GL_TRUE);

    // Calculate the model-view-projection matrix
    glm::mat4 modelViewProjection = projectionMat * viewMat;

    // Use the shader program
    glUseProgram(mProgram);

    // Set up the texture
    glUniform1i(mutex0, 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, mTexture);

    glUniform1i(mutex1, 1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, bgTex);

    // Enable vertex attribute array
    glEnableVertexAttribArray(mPositionAttribute);

    // Bind the vertex buffer object
    glBindBuffer(GL_ARRAY_BUFFER, mVerticeVBO);
    // Set the uniform matrix
    glUniformMatrix4fv(mModelViewProjectionUniform, 1, GL_FALSE, &modelViewProjection[0][0]);

    // Draw the triangles
    glVertexAttribPointer(mPositionAttribute, 3, GL_FLOAT, GL_FALSE, BYTES_PER_POINT, (void *)0);
    glUniform4f(color0, 0.0, 1.0, 1.0, 0.8);
    glDepthFunc(GL_LEQUAL);
    glDrawArrays(GL_TRIANGLES, 0, mTrianglesNum * 3);
    glDepthFunc(GL_LESS);

    // Unbind the array buffer
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    // Check for OpenGL errors after setting up the point
    GLUtils::CheckError(__FILE_NAME__, __LINE__);

    // Enable blending
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    // Check for OpenGL errors after drawing triangles
    GLUtils::CheckError(__FILE_NAME__, __LINE__);

    // Disable vertex attribute array
    glDisableVertexAttribArray(mPositionAttribute);

    // Unbind the texture
    glBindTexture(GL_TEXTURE_2D, 0);

    // Disable depth testing, face culling, and blending
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glDisable(GL_BLEND);

    // Check for OpenGL errors after drawing
    GLUtils::CheckError(__FILE_NAME__, __LINE__);
}

void SceneMeshDisplayRenderer::onDrawFrame(AREngine_ARSession *arSession, AREngine_ARFrame *arFrame,
                                           const glm::mat4 &viewMat, const glm::mat4 &projectionMat, uint32_t tex)
{
    bgTex = tex;
    AREngine_ARSceneMesh *outSceneMesh = nullptr;
    auto ret = HMS_AREngine_ARFrame_AcquireSceneMesh(arSession, arFrame, &outSceneMesh);
    LOGD("HMS_AREngine_ARFrame_AcquireSceneMesh result %{public}d.", ret);
    if (ret != ARENGINE_SUCCESS) {
        LOGD("The ar mesh get data, acquire failed %{public}d.", ret);
        return;
    }
    updateSceneMeshData(arSession, outSceneMesh);
    HMS_AREngine_ARSceneMesh_Release(outSceneMesh);
    LOGD("HMS_AREngine_ARSceneMesh_Release success.");
    Draw(viewMat, projectionMat);
}

void SceneMeshDisplayRenderer::Release()
{
    glDeleteTextures(1, &mTexture);
    GLUtils::ReleaseProgram(mProgram);
}

} // namespace ARMesh
