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

#include "world_plane_renderer.h"
#include "app_util.h"

namespace ARWorld {
namespace {
constexpr char VERTEX_SHADER[] = R"(
    precision highp float;
    precision highp int;
    attribute vec3 vertex;
    varying vec2 v_textureCoords;
    varying float v_alpha;

    uniform mat4 mvp;
    uniform mat4 model_mat;
    uniform vec3 normal;

    void main() {
        v_alpha = vertex.z;
        vec4 local_pos = vec4(vertex.x, 0.0, vertex.y, 1.0);
        gl_Position = mvp * local_pos;
        vec4 world_pos = model_mat * local_pos;
        const vec3 arbitrary = vec3(1.0, 1.0, 0.0);
        vec3 vec_u = normalize(cross(normal, arbitrary));
        vec3 vec_v = normalize(cross(normal, vec_u));
        v_textureCoords = vec2(dot(world_pos.xyz, vec_u), dot(world_pos.xyz, vec_v));
    }
)";

constexpr char FRAGMENT_SHADER[] = R"(
    precision highp float;
    precision highp int;
    uniform sampler2D texture;
    uniform vec3 color;
    varying vec2 v_textureCoords;
    varying float v_alpha;
    void main() {
        float r = texture2D(texture, v_textureCoords).r;
        gl_FragColor = vec4(color.xyz, r * v_alpha);
    }
)";

constexpr char VERTEX_SHADER_WIREFRAME[] = R"(
    precision highp float;
    precision highp int;
    attribute vec3 vertex;
    uniform mat4 mvp;
    void main() {
        gl_Position = mvp * vec4(vertex.x, 0.0, vertex.y, 1.0);
    }
)";

constexpr char FRAGMENT_SHADER_WIREFRAME[] = R"(
    precision highp float;
    precision highp int;
    void main() {
        gl_FragColor = vec4(1.0, 0.2, 0.0, 0.75);
    }
)";
} // namespace

void WorldPlaneRenderer::InitializePlaneGlContent()
{
    mShaderProgram = GLUtils::CreateProgram(VERTEX_SHADER, FRAGMENT_SHADER);
    if (!mShaderProgram) {
        LOGE("Could not create program.");
    }

    mUniformMvpMat = glGetUniformLocation(mShaderProgram, "mvp");
    mUniformTexture = glGetUniformLocation(mShaderProgram, "texture");
    mUniformModelMat = glGetUniformLocation(mShaderProgram, "model_mat");
    mUniformNormalVec = glGetUniformLocation(mShaderProgram, "normal");
    mUniformColor = glGetUniformLocation(mShaderProgram, "color");
    mAttriVertices = glGetAttribLocation(mShaderProgram, "vertex");

    mWireFrameShaderProgram = GLUtils::CreateProgram(VERTEX_SHADER_WIREFRAME, FRAGMENT_SHADER_WIREFRAME);
    mWireFrameUniformMvpMat = glGetUniformLocation(mWireFrameShaderProgram, "mvp");
    mWireFrameAttriVertices = glGetAttribLocation(mWireFrameShaderProgram, "vertex");

    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    if (!LoadPngFromAssetManager("trigrid.png")) {
        LOGE("Could not load png texture for planes.");
    }

    glGenerateMipmap(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, 0);

    GLUtils::CheckError(__FILE_NAME__, __LINE__);
}

void WorldPlaneRenderer::Release()
{
    glDeleteTextures(1, &textureId);
    GLUtils::ReleaseProgram(mShaderProgram);
}

void WorldPlaneRenderer::Draw(const glm::mat4 &projectionMat, const glm::mat4 &viewMat,
                              const AREngine_ARSession *session, const AREngine_ARPlane *plane,
                              const glm::vec3 &color)
{
    if (!mShaderProgram) {
        LOGE("The mShaderProgram is null.");
        return;
    }
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glDepthMask(GL_FALSE);

    UpdateForPlane(session, plane);

    glUseProgram(mShaderProgram);

    glActiveTexture(GL_TEXTURE0);
    glUniform1i(mUniformTexture, 0);
    glBindTexture(GL_TEXTURE_2D, textureId);

    // Write the final mvp matrix for this plane renderer.
    glUniformMatrix4fv(mUniformMvpMat, 1, GL_FALSE, glm::value_ptr(projectionMat * viewMat * modelMat));

    glUniformMatrix4fv(mUniformModelMat, 1, GL_FALSE, glm::value_ptr(modelMat));
    glUniform3f(mUniformNormalVec, normalVec.x, normalVec.y, normalVec.z);
    glUniform3f(mUniformColor, color.x, color.y, color.z);

    glEnableVertexAttribArray(mAttriVertices);

    // When the GL vertex attribute is a pointer, the number of vertices is 3.
    glVertexAttribPointer(mAttriVertices, 3, GL_FLOAT, GL_FALSE, 0, vertices.data());

    glDrawElements(GL_TRIANGLES, triangles.size(), GL_UNSIGNED_SHORT, triangles.data());

    glUseProgram(mWireFrameShaderProgram);
    glUniformMatrix4fv(mWireFrameUniformMvpMat, 1, GL_FALSE, glm::value_ptr(projectionMat * viewMat * modelMat));
    glEnableVertexAttribArray(mWireFrameAttriVertices);
    glVertexAttribPointer(mWireFrameAttriVertices, 3, GL_FLOAT, GL_FALSE, 0, vertices.data());
    glLineWidth(10.0f);
    glDrawElements(GL_LINE_LOOP, lines.size(), GL_UNSIGNED_SHORT, lines.data());

    glUseProgram(0);
    glDepthMask(GL_TRUE);
    GLUtils::CheckError(__FILE_NAME__, __LINE__);
}

void WorldPlaneRenderer::UpdateForPlane(const AREngine_ARSession *session, const AREngine_ARPlane *plane)
{
    vertices.clear();
    triangles.clear();
    lines.clear();

    int32_t polygonLength = 0;
    // Obtain the size of the 2D vertex array of the detected plane.
    CHECK(HMS_AREngine_ARPlane_GetPolygonSize(session, plane, &polygonLength));
    LOGD("API_TEST HMS_AREngine_ARPlane_GetPolygonSize SUCCESS");
    if (polygonLength == 0) {
        LOGE("WorldPlaneRenderer::UpdateForPlane, no valid plane polygon is found.");
        return;
    }

    const int32_t verticesSize = polygonLength / 2;
    std::vector<glm::vec2> raw_vertices(verticesSize);
    // Obtain the 2D vertex array of the detected plane, in the format of [x1, z1, x2, z2, ...].
    CHECK(HMS_AREngine_ARPlane_GetPolygon(session, plane, glm::value_ptr(raw_vertices.front()), polygonLength));
    LOGD("API_TEST HMS_AREngine_ARPlane_GetPolygon SUCCESS");

    // Fill in vertices 0 to 3. Use the vertex.
    // xy coordinates for the x and z coordinates of the vertex.
    // The z coordinate of the vertex is used for alpha.
    // The alpha value of the outer polygon is 0.
    for (int32_t i = 0; i < verticesSize; ++i) {
        vertices.emplace_back(raw_vertices[i].x, raw_vertices[i].y, 0.75f);
    }

    AREngine_ARPose *scopedArPose = nullptr;
    // Obtain the pose information for the conversion from the local coordinate system of a plane to the world
    // coordinate system.
    CHECK(HMS_AREngine_ARPose_Create(session, nullptr, 0, &scopedArPose));
    CHECK(HMS_AREngine_ARPlane_GetCenterPose(session, plane, scopedArPose));
    // Convert the pose data into a 4 x 4 matrix. outMatrixColMajor4x4 is the array for storing the matrix, where data
    // is stored in column-major order. Coordinates in the local coordinate system can be converted into ones in the
    // world coordinate system by multiplying this matrix with the coordinates in the local coordinate system.
    CHECK(HMS_AREngine_ARPose_GetMatrix(session, scopedArPose, glm::value_ptr(modelMat), 16));
    HMS_AREngine_ARPose_Destroy(scopedArPose);

    // Generate a triangle.
    for (int i = 1; i < verticesSize - 1; ++i) {
        triangles.push_back(0);
        triangles.push_back(i);
        triangles.push_back(i + 1);
    }
    // Generate the plane boundary.
    for (int i = 0; i < verticesSize; ++i) {
        lines.push_back(i);
    }
}

} // namespace ARWorld
