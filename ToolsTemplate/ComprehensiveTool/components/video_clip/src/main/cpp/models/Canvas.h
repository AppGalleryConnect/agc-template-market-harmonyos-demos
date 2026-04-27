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

#ifndef VEDITOR_CANVAS_H
#define VEDITOR_CANVAS_H

#include <vector>
#include <cstdint>
#include <utility>

struct Canvas {
    uint32_t height{0};
    uint32_t width{0};
    uint32_t drawableHeight{0};
    uint32_t drawableWidth{0};
    std::pair<float, float> realOrigin{0,0};
    
    void SetCanvasSize(uint32_t height, uint32_t width);
    std::vector<std::pair<uint32_t, uint32_t>> GetDrawableArea();
};

#endif //MYAPPLICATION_CANVAS_H
