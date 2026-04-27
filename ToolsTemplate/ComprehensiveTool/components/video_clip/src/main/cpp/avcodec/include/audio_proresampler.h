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
#ifndef AUDIO_PRORESAMPLER_H
#define AUDIO_PRORESAMPLER_H

#include "resampler.h"
#include "audio_proresampler_process.h"
#include <string>

class ProResampler : public Resampler {
public:
    ProResampler(uint32_t inRate, uint32_t outRate, uint32_t channels, uint32_t quality);
    ~ProResampler() override;
    // disable deep copy, enable move semantics to manage memory allocated by C malloc
    ProResampler(const ProResampler &) = delete;
    ProResampler &operator=(const ProResampler &) = delete;
    ProResampler(ProResampler &&) noexcept;
    ProResampler &operator=(ProResampler &&) noexcept;
    void Reset() override;
    int32_t Process(const float *inBuffer, uint32_t inFrameSize, float *outBuffer, uint32_t outFrameSize)
        override;
    int32_t UpdateRates(uint32_t inRate, uint32_t outRate) override;
    int32_t UpdateChannels(uint32_t channels) override;
    uint32_t GetInRate() const override;
    uint32_t GetOutRate() const override;
    uint32_t GetChannels() const override;
    uint32_t GetQuality() const;
private:
    std::string ErrCodeToString(int32_t errCode);
    uint32_t inRate_;
    uint32_t outRate_;
    uint32_t channels_;
    uint32_t quality_;
    SingleStagePolyphaseResamplerState* state_ = nullptr;
};
#endif