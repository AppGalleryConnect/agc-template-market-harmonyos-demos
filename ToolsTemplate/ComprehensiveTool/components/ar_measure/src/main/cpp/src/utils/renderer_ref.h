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

#ifndef ARDEMO_RENDERER_REF_H
#define ARDEMO_RENDERER_REF_H
#include <atomic>

class RenderRef {
public:

    static RenderRef& GetInstance();
    
    void Increment();
    void Decrement();
    bool IsOne() const;
    
    RenderRef(const RenderRef&) = delete;
    void operator=(const RenderRef&) = delete;

private:
    RenderRef();
    ~RenderRef() = default;
    
    std::atomic<int> counter_;
};
#endif //ARDEMO_RENDERER_REF_H
