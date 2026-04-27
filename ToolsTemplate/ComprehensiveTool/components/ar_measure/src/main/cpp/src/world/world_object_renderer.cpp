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

#include "world_object_renderer.h"
#include "gtc/type_ptr.hpp"

namespace ARWorld {
namespace {
const glm::vec4 K_LIGHT_DIRECTION(0.0f, 1.0f, 0.0f, 0.0f);

constexpr char VERTEX_SHADER[] = R"(
    uniform mat4 u_ModelView;
    uniform mat4 u_ModelViewProjection;
    attribute vec4 a_Position;
    attribute vec3 a_Normal;
    attribute vec2 a_TexCoord;
    varying vec3 v_ViewPosition;
    varying vec3 v_ViewNormal;
    varying vec2 v_TexCoord;
    void main() {
        v_ViewPosition = (u_ModelView * a_Position).xyz;
        v_ViewNormal = normalize((u_ModelView * vec4(a_Normal, 0.0)).xyz);
        v_TexCoord = a_TexCoord;
        gl_Position = u_ModelViewProjection * a_Position;
    }
)";

constexpr char FRAGMENT_SHADER[] = R"(
    precision mediump float;
    uniform sampler2D u_Texture;
    uniform vec4 u_LightingParameters;
    uniform vec4 u_MaterialParameters;
    varying vec3 v_ViewPosition;
    varying vec3 v_ViewNormal;
    varying vec2 v_TexCoord;
    uniform vec4 u_ObjColor;

    void main() {
        const float kGamma = 0.4545454;
        const float kInverseGamma = 2.2;
        vec3 viewLightDirection = u_LightingParameters.xyz;
        float lightIntensity = u_LightingParameters.w;

        float materialAmbient = u_MaterialParameters.x;
        float materialDiffuse = u_MaterialParameters.y;
        float materialSpecular = u_MaterialParameters.z;
        float materialSpecularPower = u_MaterialParameters.w;
        vec3 viewFragmentDirection = normalize(v_ViewPosition);
        vec3 viewNormal = normalize(v_ViewNormal);
        vec4 objectColor = texture2D(u_Texture,
                vec2(v_TexCoord.x, 1.0 - v_TexCoord.y));
        if (u_ObjColor.a >= 255.0) {
            float intensity = objectColor.r;
            objectColor.rgb = u_ObjColor.rgb * intensity / 255.0;
        }
        objectColor.rgb = pow(objectColor.rgb, vec3(kInverseGamma));
        float ambient = materialAmbient;
        float diffuse = lightIntensity * materialDiffuse *
                0.5 * (dot(viewNormal, viewLightDirection) + 1.0);
        vec3 reflectedLightDirection = reflect(viewLightDirection, viewNormal);
        float specularStrength = max(0.0, dot(viewFragmentDirection,
                reflectedLightDirection));
        float specular = lightIntensity * materialSpecular *
                pow(specularStrength, materialSpecularPower);
        gl_FragColor.a = objectColor.a;
        gl_FragColor.rgb = pow(objectColor.rgb * (ambient + diffuse) + specular,
            vec3(kGamma));
    }
)";
} // namespace

void WorldObjectRenderer::InitializeObjectGlContent(const std::string &objFileName, const std::string &pngFileName)
{
    shaderProgram = GLUtils::CreateProgram(VERTEX_SHADER, FRAGMENT_SHADER);
    if (!shaderProgram) {
        LOGE("Could not create program.");
    }
    uniformMvpMat = glGetUniformLocation(shaderProgram, "u_ModelViewProjection");
    uniformMvMat = glGetUniformLocation(shaderProgram, "u_ModelView");
    uniformTexture = glGetUniformLocation(shaderProgram, "u_Texture");

    uniformLightingParam = glGetUniformLocation(shaderProgram, "u_LightingParameters");
    uniformMaterialParam = glGetUniformLocation(shaderProgram, "u_MaterialParameters");
    uniformColor = glGetUniformLocation(shaderProgram, "u_ObjColor");

    attriVertices = glGetAttribLocation(shaderProgram, "a_Position");
    attriUvs = glGetAttribLocation(shaderProgram, "a_TexCoord");
    attriNormals = glGetAttribLocation(shaderProgram, "a_Normal");

    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    if (!LoadPngFromAssetManager(pngFileName)) {
        LOGE("Could not load png texture for planes.");
    }
    glGenerateMipmap(GL_TEXTURE_2D);

    glBindTexture(GL_TEXTURE_2D, 0);
    FileInfor fileInformation;
    fileInformation.fileName = objFileName;
    LoadObjFile(fileInformation, vertices, normals, uvs, indices);

    GLUtils::CheckError(__FILE_NAME__, __LINE__);
}

void WorldObjectRenderer::Draw(const glm::mat4 &projectionMat, const glm::mat4 &viewMat, const glm::mat4 &modelMat,
                               float lightIntensity, const float *objectColor4) const
{
    if (!shaderProgram) {
        LOGE("The shaderProgram is null.");
        return;
    }
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    glUseProgram(shaderProgram);
    glActiveTexture(GL_TEXTURE0);
    glUniform1i(uniformTexture, 0);
    glBindTexture(GL_TEXTURE_2D, textureId);

    glm::mat4 mvpMat = projectionMat * viewMat * modelMat;
    glm::mat4 mvMat = viewMat * modelMat;
    glm::vec4 viewLightDirection = glm::normalize(mvMat * K_LIGHT_DIRECTION);

    // The dimension of the light direction vector is 3.
    glUniform4f(uniformLightingParam, viewLightDirection[0], viewLightDirection[1], viewLightDirection[2],
                lightIntensity);
    glUniform4f(uniformMaterialParam, ambient, diffuse, specular, specularOower);
    glUniform4fv(uniformColor, 1, objectColor4);

    glUniformMatrix4fv(uniformMvpMat, 1, GL_FALSE, glm::value_ptr(mvpMat));
    glUniformMatrix4fv(uniformMvMat, 1, GL_FALSE, glm::value_ptr(mvMat));
    glEnableVertexAttribArray(attriVertices);

    // The vertex dimension is 3.
    glVertexAttribPointer(attriVertices, 3, GL_FLOAT, GL_FALSE, 0, vertices.data());

    // The size of the vertex attribute array is 3.
    glEnableVertexAttribArray(attriNormals);
    glVertexAttribPointer(attriNormals, 3, GL_FLOAT, GL_FALSE, 0, normals.data());

    glEnableVertexAttribArray(attriUvs);

    // The texture attribute dimension is 2.
    glVertexAttribPointer(attriUvs, 2, GL_FLOAT, GL_FALSE, 0, uvs.data());

    glDrawElements(GL_TRIANGLES, indices.size(), GL_UNSIGNED_SHORT, indices.data());

    glDisableVertexAttribArray(attriVertices);
    glDisableVertexAttribArray(attriUvs);
    glDisableVertexAttribArray(attriNormals);
    glUseProgram(0);
    GLUtils::CheckError(__FILE_NAME__, __LINE__);
}

} // namespace ARWorld
