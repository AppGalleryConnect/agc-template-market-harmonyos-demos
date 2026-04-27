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

#ifndef RENDERCONTEXT_H
#define RENDERCONTEXT_H

#include "RenderHeader.h"
#include "RenderObject.h"
#include "RenderSurface.h"

class RenderContext : public RenderObject {
public:
    RenderContext();
    ~RenderContext();

    virtual bool Create(RenderContext *sharedContext = nullptr);
    virtual bool Init() override;
    virtual bool Release() override;
    virtual bool MakeCurrent(const RenderSurface *surface);
    virtual bool ReleaseCurrent();
    virtual bool SwapBuffers(const RenderSurface *surface);

private:
    EGLDisplay m_display;
    EGLContext m_context;
    EGLConfig m_config;
    RenderAttribute m_attribute;
    bool m_isReady { false };
};

typedef std::shared_ptr<RenderContext> RenderContextPtr;

#endif // RENDERCONTEXT_H
