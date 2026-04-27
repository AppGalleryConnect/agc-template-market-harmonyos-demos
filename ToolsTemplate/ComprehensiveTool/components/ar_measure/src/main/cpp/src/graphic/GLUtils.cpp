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

#include "GLUtils.h"

GLuint GLUtils::CreateProgram(std::string vert, std::string frag)
{
    const char *vertShader = vert.c_str();
    const char *fragShader = frag.c_str();
    GLuint vertex = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertex, 1, &vertShader, NULL);
    glCompileShader(vertex);
    GLint status = 0;
    glGetShaderiv(vertex, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        GLchar message[512];
        glGetShaderInfoLog(vertex, sizeof(message), 0, &message[0]);
        LOGE("GLUtils: CompileShader: %{public}s.", &message[0]);
    }
    GLuint fragment = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragment, 1, &fragShader, NULL);
    glCompileShader(fragment);
    glGetShaderiv(fragment, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        GLchar message[512];
        glGetShaderInfoLog(fragment, sizeof(message), 0, &message[0]);
        LOGE("GLUtils: CompileShader: %{public}s.", &message[0]);
    }
    GLuint program = glCreateProgram();
    glAttachShader(program, vertex);
    glAttachShader(program, fragment);
    glLinkProgram(program);
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (!status) {
        GLchar message[512];
        glGetProgramInfoLog(program, 512, NULL, message);
        LOGE("GLUtils: LinkProgram: %{public}s.", &message[0]);
    }
    glDeleteShader(vertex);
    glDeleteShader(fragment);

    return program;
}

void GLUtils::ReleaseProgram(GLuint program) { glDeleteProgram(program); }

void GLUtils::CheckError(const std::string &file, int lineNum)
{
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        LOGE("GLUtils: [%{public}s:%{public}d] GL Error: %{public}d.", file.c_str(), lineNum, error);
    }
}

GLuint GLUtils::CreateTexture(int w, int h, GLenum internalFormat, const unsigned char *data)
{
    int align;
    glGetIntegerv(GL_UNPACK_ALIGNMENT, &align);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    GLuint tex = 0;
    int format;
    int type;
    GetFormatAndTypeFromInternalFormat(internalFormat, format, type);
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexStorage2D(GL_TEXTURE_2D, 1, internalFormat, w, h);
    if (data) {
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w, h, format, type, data);
    }
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    glPixelStorei(GL_UNPACK_ALIGNMENT, align);
    return tex;
}

void GLUtils::GetFormatAndTypeFromInternalFormat(int internalFormat, int &format, int &type)
{
    switch (internalFormat) {
        case GL_R8:
            format = GL_RED;
            type = GL_UNSIGNED_BYTE;
            break;
        case GL_RGB565:
            format = GL_RGB;
            type = GL_UNSIGNED_SHORT_5_6_5;
            break;
        case GL_RGBA4:
            format = GL_RGBA;
            type = GL_UNSIGNED_SHORT_4_4_4_4;
            break;
        case GL_RGBA8:
            format = GL_RGBA;
            type = GL_UNSIGNED_BYTE;
            break;
        case GL_RGBA16F:
            format = GL_RGBA;
            type = GL_HALF_FLOAT;
            break;
        case GL_R32F:
            format = GL_RED;
            type = GL_FLOAT;
            break;
        case GL_RGB8:
            format = GL_RGB;
            type = GL_UNSIGNED_BYTE;
            break;
        default :
            break;
    }
}

GLuint GLUtils::CreateFbo(GLuint tex)
{
    GLuint fbo;
    glGenFramebuffers(1, &fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    if (tex != 0) {
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex, 0);
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    return fbo;
}
