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

#include "mesh_background_renderer.h"
#include <type_traits>

namespace ARMesh {
namespace {
// Positions of the quad vertices in the clip space (X, Y, Z).
const GLfloat VERTICES[] = {
    -1.0f, -1.0f, 0.0f, +1.0f, -1.0f, 0.0f, -1.0f, +1.0f, 0.0f, +1.0f, +1.0f, 0.0f,
};

// UV coordinates of the quad vertices (S, T).
const GLfloat UVS[] = {
    0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f,
};

constexpr char VERTEX_SHADER[] = R"(
    attribute vec4 vertex;
    attribute vec2 textureCoords;
    varying vec2 v_textureCoords;
    void main() {
        v_textureCoords = textureCoords;
        gl_Position = vertex;
    }
)";

constexpr char FRAGMENT_SHADER[] = R"(
    #extension GL_OES_EGL_image_external : require
    precision mediump float;
    uniform samplerExternalOES texture;
    varying vec2 v_textureCoords;
    uniform vec4 v_color;
    void main() {
        gl_FragColor = mix(texture2D(texture, v_textureCoords), v_color, 0.5);
        if (distance(v_textureCoords, vec2(0.5, 0.5)) < 0.003) 
            gl_FragColor = vec4(vec3(1.0) - gl_FragColor.rgb, gl_FragColor.a);
    }
)";
} // namespace

void MeshBackgroundRenderer::InitializeBackGroundGlContent(uint64_t width, uint64_t height)
{
    shaderProgram = GLUtils::CreateProgram(VERTEX_SHADER, FRAGMENT_SHADER);
    if (!shaderProgram) {
        LOGE("Could not create program.");
    }

    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, textureId);
    glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    uniformTexture = glGetUniformLocation(shaderProgram, "texture");
    attributeVertices = glGetAttribLocation(shaderProgram, "vertex");
    attributeUvs = glGetAttribLocation(shaderProgram, "textureCoords");
    color = glGetUniformLocation(shaderProgram, "v_color");

    mWidth = width;
    mHeight = height;
    m_tex = GLUtils::CreateTexture(mWidth, mHeight, GL_RGBA8);
    m_fbo = GLUtils::CreateFbo(m_tex);
}

void MeshBackgroundRenderer::Release()
{
    glDeleteTextures(1, &textureId);
    GLUtils::ReleaseProgram(shaderProgram);
}

void MeshBackgroundRenderer::Draw(const AREngine_ARSession *session, const AREngine_ARFrame *frame, uint64_t width, uint64_t height)
{
    // In OpenGLES, the texture coordinate dimension is 2.
    static_assert(std::extent<decltype(UVS)>::value == VERTICES_NUM * 2, "Incorrect kUvs length.");
    // The dimension of the vertex in OpenGLES is 3.
    static_assert(std::extent<decltype(VERTICES)>::value == VERTICES_NUM * 3, "Incorrect kVertices length.");
    
    if (width != mWidth || height != mHeight) {
        mWidth = width;
        mHeight = height;
        glDeleteTextures(1, &m_tex);
        glDeleteFramebuffers(1, &m_fbo);
        m_tex = GLUtils::CreateTexture(mWidth, mHeight, GL_RGBA8);
        m_fbo = GLUtils::CreateFbo(m_tex);
    }
    
    // If the display rotation changes (including the view size change),
    // you need to re-query the UVs.
    int32_t geometryChanged = 0;
    CHECK(HMS_AREngine_ARFrame_GetDisplayGeometryChanged(session, frame, &geometryChanged));

    // In OpenGLES, the texture coordinate dimension is 2.
    if (geometryChanged != 0 || !uvsInitialized) {
        // In OpenGLES, the texture coordinate dimension is 2.
        CHECK(HMS_AREngine_ARFrame_TransformDisplayUvCoords(session, frame, VERTICES_NUM * 2, UVS, transformedUvs));
        uvsInitialized = true;
    }

    glUseProgram(shaderProgram);
    glDepthMask(GL_FALSE);

    glUniform1i(uniformTexture, 1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, textureId);

    // In OpenGLES, the dimension of the vertex is 3.
    glEnableVertexAttribArray(attributeVertices);
    glVertexAttribPointer(attributeVertices, 3, GL_FLOAT, GL_FALSE, 0, VERTICES);

    // In OpenGLES, the texture coordinate dimension is 2.
    glEnableVertexAttribArray(attributeUvs);
    glVertexAttribPointer(attributeUvs, 2, GL_FLOAT, GL_FALSE, 0, transformedUvs);
    glUniform4f(color, 0.0, 1.0, 1.0, 0.8);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4); // Number of points.

    GLUtils::CheckError(__FILE_NAME__, __LINE__);

    glBindFramebuffer(GL_FRAMEBUFFER, m_fbo);
    glViewport(0, 0, mWidth, mHeight);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    GLUtils::CheckError(__FILE_NAME__, __LINE__);

    glUseProgram(0);
    glDepthMask(GL_TRUE);

    GLUtils::CheckError(__FILE_NAME__, __LINE__);
}

GLuint MeshBackgroundRenderer::GetTextureId() const { return textureId; }

} // namespace ARMesh
