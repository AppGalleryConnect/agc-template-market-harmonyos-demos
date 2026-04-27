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

#ifndef RENDERATTRIBUTE_H
#define RENDERATTRIBUTE_H

#include <vector>

class RenderAttribute {
public:
    RenderAttribute() = default;
    ~RenderAttribute() = default;
    std::vector<int32_t> ToEglAttribList() const;

private:
    int32_t m_redBits = 8;
    int32_t m_greenBits = 8;
    int32_t m_blueBits = 8;
    int32_t m_alphaBits = 8;
    int32_t m_depthBits = 16;
};

#endif // RENDERATTRIBUTE_H
