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

#include "RenderContext.h"

RenderContext::RenderContext() : m_display(EGL_NO_DISPLAY), m_context(EGL_NO_CONTEXT), m_config(EGL_NO_CONFIG_KHR) {}

RenderContext::~RenderContext() {}

bool RenderContext::Create(RenderContext *sharedContext)
{
    m_display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (m_display == EGL_NO_DISPLAY) {
        LOGE("RenderContext: unable to get EGL display.");
        return false;
    }

    EGLBoolean boolRet = eglInitialize(m_display, nullptr, nullptr);
    if (!boolRet) {
        LOGE("RenderContext: eglInitialize fail.");
    }

    int attribList[] = {EGL_CONTEXT_CLIENT_VERSION, 3, EGL_NONE};
    m_context = eglCreateContext(m_display, EGL_NO_CONFIG_KHR, sharedContext, attribList);
    if (m_context == nullptr) {
        LOGE("RenderContext: unable to create egl context.");
        return false;
    }

    eglSwapInterval(m_display, 0);

    SetReady(true);
    return true;
}

bool RenderContext::Init() { return Create(nullptr); }

bool RenderContext::Release()
{
    if (IsReady()) {
        EGLBoolean ret = eglDestroyContext(m_display, m_context);
        if (ret != EGL_TRUE) {
            EGLint error = eglGetError();
            LOGE("[Render] RenderContext Release Fail 0! Code: %d.", error);
            return false;
        }

        SetReady(false);
    }

    return true;
}

bool RenderContext::MakeCurrent(const RenderSurface *surface)
{
    if (!IsReady()) {
        LOGE("[Render] MakeCurrent Fail 0!");
        return false;
    }

    EGLSurface rawSurface = EGL_NO_SURFACE;
    if (surface) {
        rawSurface = (EGLSurface)(surface->GetRawSurface());
    }

    EGLBoolean ret = eglMakeCurrent(m_display, rawSurface, rawSurface, m_context);
    if (ret != EGL_TRUE) {
        EGLint error = eglGetError();
        LOGE("[Render] MakeCurrent Fail 1! Code: %d.", error);
        return false;
    }

    return true;
}

bool RenderContext::ReleaseCurrent()
{
    if (!IsReady()) {
        LOGE("[Render] ReleaseCurrent Fail 0!");
        return false;
    }

    EGLBoolean ret = eglMakeCurrent(m_display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    if (ret != EGL_TRUE) {
        EGLint error = eglGetError();
        LOGE("[Render] ReleaseCurrent Fail 1! Code: %d.", error);
        return false;
    }

    return true;
}

bool RenderContext::SwapBuffers(const RenderSurface *surface)
{
    if (!IsReady()) {
        LOGE("[Render] SwapBuffer Fail 0!");
        return false;
    }
    if (surface == nullptr) {
        LOGE("[Render] surface is null!");
        return false;
    }
    EGLSurface rawSurface = (EGLSurface)(surface->GetRawSurface());
    EGLBoolean ret = eglSwapBuffers(m_display, rawSurface);
    if (ret != EGL_TRUE) {
        EGLint error = eglGetError();
        LOGE("[Render] SwapBuffer Fail 1! Code: %d.", error);
        return false;
    }
    return true;
}
