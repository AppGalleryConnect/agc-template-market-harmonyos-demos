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

#ifndef GLUTILS_H
#define GLUTILS_H

#include "RenderHeader.h"

class GLUtils {
public:
    static GLuint CreateProgram(std::string vert, std::string frag);

    static void ReleaseProgram(GLuint program);

    static void CheckError(const std::string &file, int lineNum);

    static GLuint CreateTexture(int w, int h, GLenum internalFormat, const unsigned char *data = nullptr);

    static GLuint CreateFbo(GLuint tex = 0);

    static void GetFormatAndTypeFromInternalFormat(int internalFormat, int &format, int &type);
};

#endif // GLUTILS_H
