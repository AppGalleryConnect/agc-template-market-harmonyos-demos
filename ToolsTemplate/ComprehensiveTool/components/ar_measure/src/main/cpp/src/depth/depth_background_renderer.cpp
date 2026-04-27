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

#include "depth_background_renderer.h"

namespace ARDepth {
namespace {
// Positions of the quad vertices in the clip space (X, Y, Z).
const GLfloat VERTICES[] = {
    -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f, -1.0f
};

// UV coordinates of the quad vertices (S, T).
const GLfloat UVS[] = {
    0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f
};

constexpr char VERTEX_SHADER[] = R"(
    attribute vec4 vPosition;
    attribute vec2 vCoord;
    uniform mat4 vMatrix;
    uniform mat4 vCoordMatrix;
    varying vec2 textureCoordinate;
    
    void main() {
        gl_Position = vPosition;
        textureCoordinate = (vec4(vCoord, 0, 1)).xy;
    }
)";

constexpr char FRAGMENT_SHADER[] =
    "precision highp float;\n"
    "varying vec2 textureCoordinate;\n"
    "uniform sampler2D vTexture;\n"
    "uniform sampler2D u_ColorMap;\n"

    "float InverseLerp(float value, float min_bound, float max_bound) {\n"
    "    return clamp((value - min_bound) / (max_bound - min_bound), 0.0, 1.0);\n"
    "}\n"

    "void main() {\n"
    "    vec4 color = texture2D(vTexture, textureCoordinate);\n"
    "    float depth = (color.r * 255.0 + color.g * 255.0 * 256.0) / 1000.0;\n"
    "    float normalized_depth = 0.0;\n"
    "    if (depth < 8.0) \n"
    "        normalized_depth = InverseLerp(depth, 0.0, 8.0) * 0.5;\n"
    "    else\n"
    "        normalized_depth = InverseLerp(depth, 8.0, 30.0) * 0.5 + 0.5;\n"
    "    vec4 depth_color = vec4(texture2D(u_ColorMap, vec2(normalized_depth, 0.5)).rgb, 0.5);\n"
    "    depth_color.rgb *= sign(depth);\n"
    "    gl_FragColor = vec4(depth_color.rgb, 1.0);\n"
    "    if (distance(textureCoordinate, vec2(0.5, 0.5)) < 0.003) \n"
    "        gl_FragColor = vec4(vec3(1.0) - gl_FragColor.rgb, gl_FragColor.a);\n"
    "}\n";
} // namespace

void DepthBackgroundRenderer::InitializeBackGroundGlContent()
{
    shaderProgram = GLUtils::CreateProgram(VERTEX_SHADER, FRAGMENT_SHADER);
    if (!shaderProgram) {
        LOGE("Could not create program.");
    }

    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    texture = glGetUniformLocation(shaderProgram, "vTexture");
    cTexture = glGetUniformLocation(shaderProgram, "u_ColorMap");
    position = glGetAttribLocation(shaderProgram, "vPosition");
    coord = glGetAttribLocation(shaderProgram, "vCoord");
    coordMatrix = glGetUniformLocation(shaderProgram, "vCoordMatrix");
    matrix = glGetUniformLocation(shaderProgram, "vMatrix");
    loadTexture();
}

void DepthBackgroundRenderer::loadTexture()
{
    // Generate texture ID and load it into GPU memory
    glGenTextures(1, &cTexture);
    glBindTexture(GL_TEXTURE_2D, cTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    if (!LoadPngFromAssetManager("depth_color_palette.png")) {
        LOGE("Could not load png texture for colorMap.");
    }

    glGenerateMipmap(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, 0);
    GLUtils::CheckError(__FILE_NAME__, __LINE__);
}

void DepthBackgroundRenderer::Release()
{
    glDeleteTextures(1, &textureId);
    GLUtils::ReleaseProgram(shaderProgram);
}

void DepthBackgroundRenderer::Draw(const AREngine_ARSession *session, const AREngine_ARFrame *frame)
{
    // If the display rotation changes (including the view size change), you need to re-query the UVs.
    int32_t geometryChanged = 0;
    CHECK(HMS_AREngine_ARFrame_GetDisplayGeometryChanged(session, frame, &geometryChanged));

    // In OpenGLES, the texture coordinate dimension is 2.
    if (geometryChanged != 0 || !uvsInitialized) {
        // In OpenGLES, the texture coordinate dimension is 2.
        CHECK(HMS_AREngine_ARFrame_TransformDisplayUvCoords(session, frame, VERTICES_NUM * 2, UVS, transformedUvs));
        uvsInitialized = true;
    }

    glDisable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glUseProgram(shaderProgram);

    glActiveTexture(GL_TEXTURE0);
    glUniform1i(cTexture, 0);
    glBindTexture(GL_TEXTURE_2D, cTexture);

    glActiveTexture(GL_TEXTURE1);
    glUniform1i(texture, 1);
    glBindTexture(GL_TEXTURE_2D, textureId);

    glUniformMatrix4fv(matrix, 1, false, projectionMatrix);
    glUniformMatrix4fv(coordMatrix, 1, false, coordMatrixs);

    // In OpenGLES, the dimension of the vertex is 3.
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, 0, VERTICES);

    // In OpenGLES, the texture coordinate dimension is 2.
    glEnableVertexAttribArray(coord);
    glVertexAttribPointer(coord, 2, GL_FLOAT, GL_FALSE, 0, transformedUvs);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4); // Number of points.
    glDisableVertexAttribArray(position);
    glDisableVertexAttribArray(coord);
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);

    GLUtils::CheckError(__FILE_NAME__, __LINE__);
}

GLuint DepthBackgroundRenderer::GetTextureId() const { return textureId; }

} // namespace ARDepth
