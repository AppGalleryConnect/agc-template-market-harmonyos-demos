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

#ifndef OPENGL_CONSTANTS_H
#define OPENGL_CONSTANTS_H
#include <cstdint> // 包含int32_t的定义

// 声明全局常量：1秒 = 1000毫秒
constexpr int32_t MILLIS_PER_SECOND = 1000;
// 声明全局常量：1毫秒 = 1000微秒
constexpr int32_t MRC_MICROSECONDS_PER_MILLISECOND = 1000;
constexpr int MATRIX_4X4_SIZE = 16; // 4x4矩阵共16个元素（4行×4列）

// 顶点属性相关常量（语义化命名）
namespace VertexAttrib {
// 定点数量
constexpr int32_t RECT_VERTEX_NUMS = 4; 
// 每个属性的分量数量
constexpr int32_t POSITION_COMPONENTS = 3; // 位置：x, y, z → 3个分量（替代魔法值3）
constexpr int32_t CORTEX_COMPONENTS = 2;   // 纹理坐标：u, v → 2个分量（替代魔法值2）
constexpr int32_t ALL_COMPONENTS = POSITION_COMPONENTS + CORTEX_COMPONENTS; // 纹理坐标：u, v → 2个分量（替代魔法值2）

} 
#endif // OPENGL_CONSTANTS_H
