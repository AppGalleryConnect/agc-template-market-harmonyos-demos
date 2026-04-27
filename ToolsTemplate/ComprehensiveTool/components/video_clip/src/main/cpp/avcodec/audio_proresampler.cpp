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

#include "audio_proresampler.h"
#include "avcodec_log.h"

#undef LOG_TAG
#define LOG_TAG "AudioProResampler"

namespace {
constexpr uint32_t BUFFER_EXPAND_SIZE = 2;
constexpr uint32_t FRAME_LEN_40MS = 40;
constexpr uint32_t MS_PER_SECOND = 1000;
constexpr uint32_t ADD_SIZE = 100;
}

// for now ProResampler accept input 40ms
ProResampler::ProResampler(uint32_t inRate, uint32_t outRate, uint32_t channels, uint32_t quality)
    : inRate_(inRate), outRate_(outRate), channels_(channels), quality_(quality)
{
    int32_t errRet;
    state_ = SingleStagePolyphaseResamplerInit(channels_, inRate_, outRate_, quality_, &errRet);
    CHECK_AND_RETURN_LOG(state_, "Proresampler: Init failed! failed with error %{public}s.",
        ErrCodeToString(errRet).c_str());
    
    SingleStagePolyphaseResamplerSkipHalfTaps(state_);
    AVCODEC_SAMPLE_LOGI("Proresampler: Init success inRate: %{public}d, outRate: %{public}d, channels: %{public}d, "
        "quality: %{public}d.", inRate_, outRate_, channels_, quality_);
}

int32_t ProResampler::Process(const float *inBuffer, uint32_t inFrameSize, float *outBuffer,
    uint32_t outFrameSize)
{
    CHECK_AND_RETURN_RET_LOG(state_ != nullptr, RESAMPLER_ERR_ALLOC_FAILED,
        "ProResampler Process: resampler is %{public}s", ErrCodeToString(RESAMPLER_ERR_ALLOC_FAILED).c_str());

    uint32_t expectedOutFrameSize = outFrameSize;
    std::vector<float> tmpOutBuf(expectedOutFrameSize * channels_, 0.0f);
    int32_t ret =
        SingleStagePolyphaseResamplerProcess(state_, inBuffer, &inFrameSize, tmpOutBuf.data(), &outFrameSize);
    CHECK_AND_RETURN_RET_LOG(ret == RESAMPLER_ERR_SUCCESS, ret, "ProResampler process failed with error %{public}s",
        ErrCodeToString(ret).c_str());
    
    uint32_t fillSize = expectedOutFrameSize - outFrameSize > 0 ? expectedOutFrameSize - outFrameSize : 0;
    std::memset(outBuffer, 0, fillSize * channels_ * sizeof(float));

    std::memcpy(outBuffer + fillSize * channels_, tmpOutBuf.data(), outFrameSize * channels_ * sizeof(float));
    return ret;
}

int32_t ProResampler::UpdateRates(uint32_t inRate, uint32_t outRate)
{
    inRate_ = inRate;
    outRate_ = outRate;
    CHECK_AND_RETURN_RET_LOG(state_ != nullptr, RESAMPLER_ERR_ALLOC_FAILED, "ProResampler: resampler is null");
    
    int32_t ret = SingleStagePolyphaseResamplerSetRate(state_, inRate_, outRate_);
    CHECK_AND_RETURN_RET_LOG(ret == RESAMPLER_ERR_SUCCESS, ret,
        "ProResampler update rate failed with error code %{public}s", ErrCodeToString(ret).c_str());
    return ret;
}

int32_t ProResampler::UpdateChannels(uint32_t channels)
{
    uint32_t oldChannels = channels_;
    channels_ = channels;
    CHECK_AND_RETURN_RET_LOG(state_ != nullptr, RESAMPLER_ERR_ALLOC_FAILED, "ProResampler: resampler is null");
    SingleStagePolyphaseResamplerFree(state_);

    int32_t errRet = RESAMPLER_ERR_SUCCESS;
    state_ = SingleStagePolyphaseResamplerInit(channels_, inRate_, outRate_, quality_, &errRet);
    CHECK_AND_RETURN_RET_LOG(state_ && (errRet == RESAMPLER_ERR_SUCCESS), errRet,
        "Proresampler: update work channels failed with error %{public}s.", ErrCodeToString(errRet).c_str());

    AVCODEC_SAMPLE_LOGI("Proresampler: update work channel success old channels: %{public}d, new channels: %{public}d",
        oldChannels, channels_);

    return SingleStagePolyphaseResamplerSkipHalfTaps(state_);
}

ProResampler::ProResampler(ProResampler &&other) noexcept
    : inRate_(other.inRate_), outRate_(other.outRate_), channels_(other.channels_),
    quality_(other.quality_), state_(other.state_)
{
    other.state_ = nullptr;
}

ProResampler &ProResampler::operator=(ProResampler &&other) noexcept
{
    if (this != &other) {
        if (state_ != nullptr) {
            SingleStagePolyphaseResamplerFree(state_);
        }
        inRate_ = other.inRate_;
        outRate_ = other.outRate_;
        channels_ = other.channels_;
        quality_ = other.quality_;
        state_ = other.state_;
        other.state_ = nullptr;
    }
    return *this;
}

void ProResampler::Reset()
{
    CHECK_AND_RETURN_LOG(state_ != nullptr, "ProResampler: resampler is null");
    SingleStagePolyphaseResamplerResetMem(state_);
    SingleStagePolyphaseResamplerSkipHalfTaps(state_);
}

uint32_t ProResampler::GetInRate() const
{
    return inRate_;
}

uint32_t ProResampler::GetOutRate() const
{
    return outRate_;
}

uint32_t ProResampler::GetChannels() const
{
    return channels_;
}

uint32_t ProResampler::GetQuality() const
{
    return quality_;
}

ProResampler::~ProResampler()
{
    if (state_ != nullptr) {
        SingleStagePolyphaseResamplerFree(state_);
        state_ = nullptr;
    }
}

std::string ProResampler::ErrCodeToString(int32_t errCode)
{
    switch (errCode) {
        case RESAMPLER_ERR_SUCCESS: {
            return "RESAMPLER_ERR_SUCCESS";
            break;
        }
        case RESAMPLER_ERR_ALLOC_FAILED: {
            return "RESAMPLER_ERR_ALLOC_FAILED";
            break;
        }
        case RESAMPLER_ERR_INVALID_ARG: {
            return "RESAMPLER_ERR_INVALID_ARG";
            break;
        }
        case RESAMPLER_ERR_OVERFLOW: {
            return "RESAMPLER_ERR_OVERFLOW";
            break;
        }
        default: {
            return "Unknown Error Code";
        }
    }
}