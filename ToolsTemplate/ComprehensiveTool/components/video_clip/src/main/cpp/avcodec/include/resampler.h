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
#ifndef RESAMPLER_H
#define RESAMPLER_H
#include <cstdint>

class Resampler {
public:
    virtual ~Resampler() = default;
    virtual void Reset() = 0;
    virtual int Process(const float *in_buffer, uint32_t inFrameSize, float *out_buffer,
        uint32_t outFrameSize) = 0;
    virtual int32_t UpdateRates(uint32_t inRate, uint32_t outRate) = 0;
    virtual uint32_t GetInRate() const = 0;
    virtual uint32_t GetOutRate() const = 0;
    virtual uint32_t GetChannels() const = 0;
    virtual int32_t UpdateChannels(uint32_t channels) = 0;
};

#endif