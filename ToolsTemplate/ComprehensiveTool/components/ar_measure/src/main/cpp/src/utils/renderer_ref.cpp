/**
 * Copyright 2022. Huawei Technologies Co., Ltd. All rights reserved.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
#include "renderer_ref.h"
#include <mutex>

RenderRef& RenderRef::GetInstance() {
    static RenderRef instance;
    return instance;
}

RenderRef::RenderRef() : counter_(0) {}

void RenderRef::Increment() {
    counter_.fetch_add(1, std::memory_order_relaxed);
}

void RenderRef::Decrement() {
    counter_.fetch_sub(1, std::memory_order_relaxed);
}

bool RenderRef::IsOne() const {
    return counter_.load(std::memory_order_acquire) == 1;
}
