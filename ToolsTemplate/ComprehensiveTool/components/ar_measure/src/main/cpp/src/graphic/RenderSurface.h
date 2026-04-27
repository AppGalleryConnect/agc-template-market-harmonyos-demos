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

#ifndef RENDERSURFACE_H
#define RENDERSURFACE_H

#include "RenderAttribute.h"
#include "RenderHeader.h"
#include "RenderObject.h"

class RenderSurface : public RenderObject {
public:
    enum class SurfaceType { SURFACE_TYPE_NULL, SURFACE_TYPE_ON_SCREEN, SURFACE_TYPE_OFF_SCREEN };

    RenderSurface();
    ~RenderSurface() override;

    virtual bool Create(void *window);
    virtual bool Init() override;
    virtual bool Release() override;

    void *GetRawSurface() const;

private:
    EGLDisplay m_display;
    EGLConfig m_config;
    EGLSurface m_surface;
    RenderAttribute m_attribute;
    SurfaceType m_surfaceType;
};

#endif // RENDERSURFACE_H
