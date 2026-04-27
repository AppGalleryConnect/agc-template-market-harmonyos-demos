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

#include "RenderAttribute.h"
#include <EGL/egl.h>

std::vector<int32_t> RenderAttribute::ToEglAttribList() const
{
    int32_t configAttribs[] = {EGL_COLOR_BUFFER_TYPE, EGL_RGB_BUFFER,     EGL_RED_SIZE,   m_redBits,
                               EGL_GREEN_SIZE,        m_greenBits,        EGL_BLUE_SIZE,  m_blueBits,
                               EGL_ALPHA_SIZE,        m_alphaBits,        EGL_DEPTH_SIZE, m_depthBits,
                               EGL_RENDERABLE_TYPE,   EGL_OPENGL_ES3_BIT, EGL_NONE};
    std::vector<int32_t> attribs(configAttribs, configAttribs + sizeof(configAttribs) / sizeof(EGLint));
    return attribs;
}
