/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

#include "shader_program.h"
#include "render/common/constants.h"

namespace HarmonyVideoEditorRender {
constexpr uint32_t LOG_PRINT_DOMAIN = 0xFF00;
ShaderProgram::ShaderProgram(const std::string &vertexShader, const std::string &fragShader)
{
    auto vShaderCode = vertexShader.c_str();
    GLuint vertex = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertex, 1, &vShaderCode, nullptr);
    glCompileShader(vertex);
    CheckCompileErrors(vertex, "VERTEX");

    auto fShaderCode = fragShader.c_str();
    GLuint fragment = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragment, 1, &fShaderCode, nullptr);
    glCompileShader(fragment);
    CheckCompileErrors(fragment, "FRAGMENT");

    id_ = glCreateProgram();
    glAttachShader(id_, vertex);
    glAttachShader(id_, fragment);
    glLinkProgram(id_);
    CheckCompileErrors(id_, "PROGRAM");
    glDeleteShader(vertex);
    glDeleteShader(fragment);
}

ShaderProgram::~ShaderProgram() noexcept
{
    if (Valid()) {
        glDeleteProgram(id_);
    }
}

void ShaderProgram::CheckCompileErrors(GLuint object, const std::string &type)
{
    GLint success = 0;
    GLint logLength = 0;

    // 统一获取成功状态和日志长度，根据类型调用不同OpenGL接口
    if (type != "PROGRAM") {
        glGetShaderiv(object, GL_COMPILE_STATUS, &success);
        glGetShaderiv(object, GL_INFO_LOG_LENGTH, &logLength);
    } else {
        glGetProgramiv(object, GL_LINK_STATUS, &success);
        glGetProgramiv(object, GL_INFO_LOG_LENGTH, &logLength);
    }

    // 仅在失败且日志有内容时处理
    if (!success && logLength > 0) {
        // 动态分配日志缓冲区（+1确保包含终止符）
        std::vector<char> infoLog(logLength + 1);

        // 获取日志内容
        if (type != "PROGRAM") {
            glGetShaderInfoLog(object, logLength, nullptr, infoLog.data());
        } else {
            glGetProgramInfoLog(object, logLength, nullptr, infoLog.data());
        }

        // 打印错误日志
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "ShaderProgram",
                     "ERROR::%{public}s_ERROR of type: %{public}s, infoLog is: %{public}s",
                     (type == "PROGRAM" ? "PROGRAM_LINKING" : "SHADER_COMPILATION"), type.c_str(), infoLog.data());
    }
}

void ShaderProgram::SetBool(const std::string &name, bool value)
{
    glUniform1i(glGetUniformLocation(id_, name.c_str()), static_cast<GLint>(value));
}

void ShaderProgram::SetInt(const std::string &name, int value)
{
    glUniform1i(glGetUniformLocation(id_, name.c_str()), static_cast<GLint>(value));
}

void ShaderProgram::SetFloat(const std::string &name, float value)
{
    glUniform1f(glGetUniformLocation(id_, name.c_str()), static_cast<GLfloat>(value));
}

void ShaderProgram::SetFloat4v(const std::string &name, float *values)
{
    glUniform4fv(glGetUniformLocation(id_, name.c_str()), 1, values);
}

void ShaderProgram::SetMatrix4v(const std::string &name, float *matrix, int cnt, bool transpose)
{
    if (cnt != MATRIX_4X4_SIZE || matrix == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "ShaderProgram",
                     "ShaderProgram::SetFloat4v: invalid arguments.");
        return;
    }
    GLboolean glTranspose = transpose ? GL_TRUE : GL_FALSE;
    glUniformMatrix4fv(glGetUniformLocation(id_, name.c_str()), 1, glTranspose, matrix);
}

GLint ShaderProgram::GetAttribLocation(const std::string &name) { return glGetAttribLocation(id_, name.c_str()); }
} // namespace HarmonyVideoEditorRender
