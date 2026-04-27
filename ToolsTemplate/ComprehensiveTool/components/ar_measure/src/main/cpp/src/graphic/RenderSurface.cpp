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

#include "RenderSurface.h"

RenderSurface::RenderSurface() : m_display(EGL_NO_DISPLAY),
                                 m_config(EGL_NO_CONFIG_KHR),
                                 m_surface(EGL_NO_SURFACE),
                                 m_surfaceType(SurfaceType::SURFACE_TYPE_NULL) {}

RenderSurface::~RenderSurface() {}

bool RenderSurface::Create(void *window)
{
    EGLint retNum = 0;
    m_display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    std::vector<int32_t> attributeList = m_attribute.ToEglAttribList();
    EGLBoolean ret = eglChooseConfig(m_display, attributeList.data(), &m_config, 1, &retNum);
    if (ret != EGL_TRUE) {
        EGLint error = eglGetError();
        LOGE("[Render] RenderSurface Init ON Fail 0! Code: %d.", error);
        return false;
    }
    EGLint surfaceAttribs[] = { EGL_NONE };
    EGLNativeWindowType mEglWindow = reinterpret_cast<EGLNativeWindowType>(window);

    m_surface = eglCreateWindowSurface(m_display, m_config, mEglWindow, surfaceAttribs);
    if (m_surface == EGL_NO_SURFACE) {
        EGLint error = eglGetError();
        LOGE("[Render] RenderSurface Init ON Fail 1! Code: %d.", error);
        return false;
    }
    m_surfaceType = SurfaceType::SURFACE_TYPE_ON_SCREEN;
    SetReady(true);
    return true;
}

bool RenderSurface::Init()
{
    EGLint retNum = 0;
    m_display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    std::vector<int32_t> attributeList = m_attribute.ToEglAttribList();
    EGLBoolean ret = eglChooseConfig(m_display, attributeList.data(), &m_config, 1, &retNum);
    if (ret != EGL_TRUE) {
        EGLint error = eglGetError();
        LOGE("[Render] RenderSurface Init OFF Fail 0! Code: %d.", error);
        return false;
    }
    EGLint surfaceAttribs[] = { EGL_NONE };
    m_surface = eglCreatePbufferSurface(m_display, m_config, surfaceAttribs);
    if (m_surface == EGL_NO_SURFACE) {
        EGLint error = eglGetError();
        LOGE("[Render] RenderSurface Init OFF Fail 1! Code: %d.", error);
        return false;
    }
    m_surfaceType = SurfaceType::SURFACE_TYPE_OFF_SCREEN;
    SetReady(true);
    return true;
}

bool RenderSurface::Release()
{
    if (IsReady()) {
        EGLBoolean ret = eglDestroySurface(m_display, m_surface);
        if (ret != EGL_TRUE) {
            EGLint error = eglGetError();
            LOGE("[Render] RenderSurface Release Fail 0! Code: %d.", error);
            return false;
        }
        m_surfaceType = SurfaceType::SURFACE_TYPE_NULL;
        SetReady(false);
    }
    return true;
}

void *RenderSurface::GetRawSurface() const { return (void *)m_surface; }
