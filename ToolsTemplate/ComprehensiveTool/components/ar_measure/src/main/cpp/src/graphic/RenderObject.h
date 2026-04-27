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

#ifndef RENDEROBJECT_H
#define RENDEROBJECT_H

#include "RenderHeader.h"

class RenderObject {
public:
    explicit RenderObject() : m_isReady(false) {}
    virtual ~RenderObject()
    {
        if (m_isReady) {
            LOGE("Destructor called without Release()! %s.", m_tag.c_str());
        }
    }

    virtual bool Init() = 0;
    virtual bool Release() = 0;

    bool IsReady() { return m_isReady; }

    void SetReady(bool flag) { m_isReady = flag; }

private:
    bool m_isReady;
    std::string m_tag;
};

using RenderObjectPtr = std::shared_ptr<RenderObject>;

#define TO_RENDER_OBJECT(obj) (std::dynamic_pointer_cast<RenderObject>((obj)))

#endif // RENDEROBJECT_H
