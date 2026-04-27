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

#ifndef OPENGL_EGL_RENDER_CONTEXT_H
#define OPENGL_EGL_RENDER_CONTEXT_H

#include <GLES3/gl3.h>    // GLES3核心头文件，定义GLenum、GLuint等
#include <GLES2/gl2ext.h> // 扩展头文件，此时能识别核心类型
#include <EGL/egl.h>
#include <EGL/eglext.h>

#include <cstring>
#include <hilog/log.h>
#include <native_window/external_window.h>
#include <window_manager/oh_window_comm.h>

namespace HarmonyVideoEditorRender {
class EglRenderContext {
public:
    EglRenderContext();
    ~EglRenderContext() noexcept;

    EglRenderContext(const EglRenderContext &) = delete;
    EglRenderContext(const EglRenderContext &&) = delete;
    EglRenderContext &operator=(const EglRenderContext &other) = delete;
    EglRenderContext &operator=(EglRenderContext &&) = delete;
    void operator==(const EglRenderContext &&) = delete;
    void operator==(const EglRenderContext &) = delete;

    bool Init();
    bool IsEglContextReady() const { return eglContext_ != EGL_NO_CONTEXT; }

    EGLDisplay GetEGLDisplay() const { return eglDisplay_; }
    EGLDisplay GetEGLContext() const { return eglContext_; }

    EGLSurface CreateEglSurface(OHNativeWindow *surface, const EGLint *attribList = nullptr);
    void DestroyEglSurface(EGLSurface surface);

    void MakeCurrent(EGLSurface surface) const;
    void SwapBuffers(EGLSurface surface) const;


protected:
    EGLDisplay eglDisplay_ = EGL_NO_DISPLAY;
    EGLDisplay eglContext_ = EGL_NO_CONTEXT;
    EGLDisplay eglShareContext_ = EGL_NO_CONTEXT;
    EGLConfig config_ = nullptr;

    bool hasEglSurfacelessContext_ = false;
    bool hasEglPartialUpdate_ = false;
    PFNEGLCREATEIMAGEKHRPROC eglCreateImageFunc_ = nullptr;
    PFNGLEGLIMAGETARGETTEXTURE2DOESPROC eglImageTargetTexture2DOESFunc_ = nullptr;

private:
    void SetupEglExtensions();
    void SetupGlExtensions() const;
};
} // namespace HarmonyVideoEditorRender

#endif // OPENGL_EGL_RENDER_CONTEXT_H
