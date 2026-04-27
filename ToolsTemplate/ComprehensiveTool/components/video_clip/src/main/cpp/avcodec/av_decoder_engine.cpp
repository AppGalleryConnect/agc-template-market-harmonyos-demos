/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
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
#include <cstdint>
#include "avcodec_log.h"
#include "av_decoder_engine.h"
#include "codec_common.h"
#include <algorithm>

#undef LOG_TAG
#define LOG_TAG "videoEditorDecoder"

namespace {
static constexpr int32_t BIT_16 = 16;
static constexpr float FLOAT_EPS  = 1e-6f;
static constexpr int32_t MS_IN_SECOND = 1000;
static constexpr int32_t DEFAULT_CHANNEL_NUM = 2;
static constexpr int32_t CODEC_FRAME_LENGTH = 1024 * DEFAULT_CHANNEL_NUM;
static constexpr int32_t CODEC_FRAME_SIZE = CODEC_FRAME_LENGTH * sizeof(int16_t);
static constexpr int32_t DEFAULT_OUTPUT_SAMPLING_RATE = 44100;
static constexpr int32_t RESAMPLE_FRAME_LENGTH_MS = 40;
static constexpr int32_t DEFAULT_RESAMPLE_OUTPUT_FRAME_LEN = DEFAULT_OUTPUT_SAMPLING_RATE * RESAMPLE_FRAME_LENGTH_MS *
    DEFAULT_CHANNEL_NUM / MS_IN_SECOND;
static constexpr uint32_t REASAMPLE_QUAILTY = 1;
static constexpr int32_t MAX_FRAME_LEN = DEFAULT_CHANNEL_NUM * 1024;
} // namespace

static inline float CapMax(float v)
{
    float value = v;
    if (v > 1.0f) {
        value = 1.0f - FLOAT_EPS;
    } else if (v < -1.0f) {
        value = -1.0f + FLOAT_EPS;
    }
    return value;
}

static inline int16_t ConvertFromFloatTo16Bit(float a)
{
    return static_cast<int16_t>(CapMax(a) * (1 << (BIT_16 - 1)));
}

static inline float ConvertFrom16BitToFloat(int16_t a)
{
    return static_cast<float>(a * (1.0f / (1 << (BIT_16 - 1))));
}

std::shared_ptr<IAVDecoderEngine> IAVDecoderEngine::Create(int fd, std::weak_ptr<AVDecodeCallback> cb)
{
    std::shared_ptr<IAVDecoderEngine> engine = std::make_shared<AVDecoderEngine>(fd, cb);

    return engine;
}

AVDecoderEngine::AVDecoderEngine(int fd, std::weak_ptr<AVDecodeCallback> cb)
    : avDataBuffer_(MAX_FRAME_LEN), musicDataBuffer_(MAX_FRAME_LEN), tempOutBuffer_(MAX_FRAME_LEN)
{
    avDecoderEngine_ = std::make_shared<AVDecoderEngineImpl>(fd, cb, false);
}

AVDecoderEngine::~AVDecoderEngine()
{
    avDecoderEngine_ = nullptr;
    avResampler_ = nullptr;
    musicDecoderEngine_ = nullptr;
    musicResampler_ = nullptr;
}

int32_t AVDecoderEngine::Init() {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, AV_ERROR, "av decoder has not been created");
    int32_t ret = avDecoderEngine_->Init();
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "av decoder init failed");
    isAvAudioExisted_ = avDecoderEngine_->IsAudioTrackExisted();
    AVCODEC_SAMPLE_LOGI("av audio track existed: %{public}d", isAvAudioExisted_);
    isAudioDataMute_.store(!isAvAudioExisted_);
    return AV_OK;
}

int32_t AVDecoderEngine::Start() {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, AV_ERROR, "av decoder has not been created");
    int32_t ret = avDecoderEngine_->Start();
    isAvDecodingStarted_.store(true);
    if (musicDecoderEngine_ && !isMusicDecodingStarted_) {
        musicDecoderEngine_->Start();
        isMusicDecodingStarted_.store(true);
    }
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "av decoder start failed");
    return AV_OK;
}

int32_t AVDecoderEngine::Pause() {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, AV_ERROR, "av decoder has not been created");
    int32_t ret = avDecoderEngine_->Pause();
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "av decoder pause failed");
    return AV_OK;
}

int32_t AVDecoderEngine::Stop() {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, AV_ERROR, "av decoder has not been created");
    int32_t ret = avDecoderEngine_->Stop();
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "av decoder stop failed");
    avDecoderEngine_ = nullptr;
    if (musicDecoderEngine_) {
        int32_t ret = musicDecoderEngine_->Stop();
        CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "music decoder stop failed");
        musicDecoderEngine_ = nullptr;
        isMusicDecodingStarted_.store(false);
    }

    return AV_OK;
}

int32_t AVDecoderEngine::SetPlayDuration(int64_t duration) {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, AV_ERROR, "av decoder has not been created");
    avDataDuration_ = duration;
    int32_t ret = avDecoderEngine_->SetPlayDuration(duration);
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "av decoder set duration failed");
    if (musicDecoderEngine_) {
        int32_t ret = musicDecoderEngine_->SetPlayDuration(duration);
        CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "music decoder set duration failed");
    }
    return AV_OK;
}

int32_t AVDecoderEngine::Seek(int64_t millisecond, OH_AVSeekMode mode) {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, AV_ERROR, "av decoder has not been created");
    int32_t ret = avDecoderEngine_->Seek(millisecond, mode);
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "av decoder seek failed");
    return AV_OK;
}

int32_t AVDecoderEngine::SetVideoOutputWindow(OHNativeWindow* surfaceWindow) {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, AV_ERROR, "av decoder has not been created");
    int32_t ret = avDecoderEngine_->SetVideoOutputWindow(surfaceWindow);
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "av decoder set video output window failed");
    return AV_OK;
}

int32_t AVDecoderEngine::SetAudioOutputBufferQueue(std::shared_ptr<PcmBufferQueue>& queue)
{
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, AV_ERROR, "av decoder has not been created");
    CHECK_AND_RETURN_RET_LOG(queue, AV_ERROR, "pcm buffer queue is nullptr.");
    pcmBufferQueue_ = queue;

    resampleOutBuffer_.resize(DEFAULT_RESAMPLE_OUTPUT_FRAME_LEN);

    avResampler_ = std::make_unique<ProResampler>(avSamplingRate_, DEFAULT_OUTPUT_SAMPLING_RATE,
        DEFAULT_CHANNEL_NUM, REASAMPLE_QUAILTY);
    int32_t ret = avDecoderEngine_->SetAudioOutputBufferQueue(weak_from_this());
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "av decoder set audio output buffer queue failed");

    if (musicDecoderEngine_) {
        musicResampler_ = std::make_unique<ProResampler>(musicSamplingRate_, DEFAULT_OUTPUT_SAMPLING_RATE,
            DEFAULT_CHANNEL_NUM, REASAMPLE_QUAILTY);
        ret = musicDecoderEngine_->SetAudioOutputBufferQueue(weak_from_this());
        CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "music decoder set audio output buffer queue failed");
    }
    return AV_OK;
}

OH_AVFormat* AVDecoderEngine::GetVideoFormat() {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, nullptr, "av decoder has not been created");
    return avDecoderEngine_->GetVideoFormat();
}

OH_AVFormat* AVDecoderEngine::GetAudioFormat() {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, nullptr, "av decoder has not been created");
    return avDecoderEngine_->GetAudioFormat();
}

int32_t AVDecoderEngine::SetHighPerformance(bool enableFlag) {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, AV_ERROR, "av decoder has not been created");
    int32_t ret = avDecoderEngine_->SetHighPerformance(enableFlag);
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "av decoder set high performance failed");
    return AV_OK;
}

int32_t AVDecoderEngine::AudioUnselect(bool unselectFlag)
{
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, AV_ERROR, "av decoder has not been created");
    // called when transforming, remove audio data in av resource
    int32_t ret = avDecoderEngine_->AudioUnselect(unselectFlag);
    isAudioDataMute_.store(!isAvAudioExisted_ || unselectFlag);
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "av decoder audio unselect failed");
    return AV_OK;
}

int32_t AVDecoderEngine::AudioMute(bool muteFlag) {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, AV_ERROR, "av decoder has not been created");
    // called when previewing, mute audio data in av resource
    int32_t ret = avDecoderEngine_->AudioMute(muteFlag);
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "av decoder set audio mute failed");
    return AV_OK;
}

int32_t AVDecoderEngine::AddAudio(int fd) {
    musicDecoderEngine_ = std::make_shared<AVDecoderEngineImpl>(fd, std::weak_ptr<AVDecodeCallback>{}, true);
    int32_t ret;
    if (avDataDuration_ != -1) {
        ret = musicDecoderEngine_->SetPlayDuration(avDataDuration_);
        CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "music decoder set duration failed");
    }
    ret = musicDecoderEngine_->Init();
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "music decoder init failed");
    if (isAvDecodingStarted_) {
        ret = musicDecoderEngine_->Start();
        CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "music decoder start failed");
        isMusicDecodingStarted_.store(true);
    }
    return AV_OK;
}

int32_t AVDecoderEngine::DeleteAudio(int fd) {
    CHECK_AND_RETURN_RET_LOG(musicDecoderEngine_, AV_ERROR, "music decoder has not been added");
    int32_t ret = musicDecoderEngine_->Stop();
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "music decoder stop failed");
    musicDecoderEngine_ = nullptr;
    isMusicDecodingStarted_.store(false);
    return AV_OK;
}

int64_t AVDecoderEngine::GetVideoDuration() {
    CHECK_AND_RETURN_RET_LOG(avDecoderEngine_, 0, "av decoder has not been created");
    return avDecoderEngine_->GetVideoDuration();
}

void AVDecoderEngine::OnAVSamplingRateChanged(const int32_t samplingRate)
{
    AVCODEC_SAMPLE_LOGI("av audio sampling rate is %{public}d", samplingRate);
    avResampleInputFrameLen_ = samplingRate * RESAMPLE_FRAME_LENGTH_MS * DEFAULT_CHANNEL_NUM / MS_IN_SECOND;
    resampleInBuffer_.resize(std::max(avResampleInputFrameLen_, musicResampleInputFrameLen_));
    if (avResampler_) {
        avResampler_->UpdateRates(static_cast<uint32_t>(samplingRate), DEFAULT_OUTPUT_SAMPLING_RATE);
    }
}

void AVDecoderEngine::OnMusicSamplingRateChanged(const int32_t samplingRate)
{
    AVCODEC_SAMPLE_LOGI("music audio sampling rate is %{public}d", samplingRate);
    musicResampleInputFrameLen_ = samplingRate * RESAMPLE_FRAME_LENGTH_MS * DEFAULT_CHANNEL_NUM / MS_IN_SECOND;
    resampleInBuffer_.resize(std::max(avResampleInputFrameLen_, musicResampleInputFrameLen_));
    if (musicResampler_) {
        musicResampler_->UpdateRates(static_cast<uint32_t>(samplingRate), DEFAULT_OUTPUT_SAMPLING_RATE);
    }
}

void AVDecoderEngine::OnAVDataReady(std::shared_ptr<PcmData> pcmData)
{
    const int16_t *data = reinterpret_cast<const int16_t*>(pcmData->data.data());
    avDataQueue_.insert(avDataQueue_.end(), data, data + pcmData->dataSize / sizeof(int16_t));
    std::unique_lock<std::mutex> lock(mutex_);
    AVDataFormatConvert();
    MixAudioData();
}

void AVDecoderEngine::OnMusicDataReady(std::shared_ptr<PcmData> pcmData)
{
    const int16_t *data = reinterpret_cast<const int16_t*>(pcmData->data.data());
    musicDataQueue_.insert(musicDataQueue_.end(), data, data + pcmData->dataSize / sizeof(int16_t));
    std::unique_lock<std::mutex> lock(mutex_);
    MusicDataFormatConvert();
    MixAudioData();
}

void AVDecoderEngine::AVDataFormatConvert()
{
    while (avDataQueue_.size() >= avResampleInputFrameLen_) {
        // format convert process
        std::transform(
            avDataQueue_.begin(), avDataQueue_.begin() + avResampleInputFrameLen_,
            resampleInBuffer_.begin(),
            [](int16_t x) { return ConvertFrom16BitToFloat(x); }
        );
        avDataQueue_.erase(avDataQueue_.begin(), avDataQueue_.begin() + avResampleInputFrameLen_);

        avResampler_->Process(resampleInBuffer_.data(), avResampleInputFrameLen_ / DEFAULT_CHANNEL_NUM,
            resampleOutBuffer_.data(), DEFAULT_RESAMPLE_OUTPUT_FRAME_LEN / DEFAULT_CHANNEL_NUM);
        std::transform(
            resampleOutBuffer_.begin(), resampleOutBuffer_.begin() + DEFAULT_RESAMPLE_OUTPUT_FRAME_LEN,
            std::back_inserter(avDataQueueAfterResample_),
            [](float x) { return ConvertFromFloatTo16Bit(x); }
        );
    }
}

void AVDecoderEngine::MusicDataFormatConvert()
{
    while (musicDataQueue_.size() >= musicResampleInputFrameLen_) {
        // format convert process
        std::transform(
            musicDataQueue_.begin(), musicDataQueue_.begin() + musicResampleInputFrameLen_,
            resampleInBuffer_.begin(),
            [](int16_t x) { return ConvertFrom16BitToFloat(x); }
        );
        musicDataQueue_.erase(musicDataQueue_.begin(), musicDataQueue_.begin() + musicResampleInputFrameLen_);

        musicResampler_->Process(resampleInBuffer_.data(), musicResampleInputFrameLen_ / DEFAULT_CHANNEL_NUM,
            resampleOutBuffer_.data(), DEFAULT_RESAMPLE_OUTPUT_FRAME_LEN / DEFAULT_CHANNEL_NUM);
        std::transform(
            resampleOutBuffer_.begin(), resampleOutBuffer_.begin() + DEFAULT_RESAMPLE_OUTPUT_FRAME_LEN,
            std::back_inserter(musicDataQueueAfterResample_),
            [](float x) { return ConvertFromFloatTo16Bit(x); }
        );
    }
}

void AVDecoderEngine::MixAudioData()
{
    while ((isAudioDataMute_ || avDataQueueAfterResample_.size() >= CODEC_FRAME_LENGTH) &&
        (!musicDecoderEngine_ || musicDataQueueAfterResample_.size() >= CODEC_FRAME_LENGTH)) {
        // only use data from music data
        if (isAudioDataMute_) {
            mixDataQueue_.insert(mixDataQueue_.end(),
                musicDataQueueAfterResample_.begin(), musicDataQueueAfterResample_.begin() + CODEC_FRAME_LENGTH);
            musicDataQueueAfterResample_.erase(musicDataQueueAfterResample_.begin(),
                musicDataQueueAfterResample_.begin() + CODEC_FRAME_LENGTH);
            SendAudioData();
            continue;
        }
        // only use data from av data
        if (!musicDecoderEngine_) {
            mixDataQueue_.insert(mixDataQueue_.end(),
                avDataQueueAfterResample_.begin(), avDataQueueAfterResample_.begin() + CODEC_FRAME_LENGTH);
            avDataQueueAfterResample_.erase(avDataQueueAfterResample_.begin(),
                avDataQueueAfterResample_.begin() + CODEC_FRAME_LENGTH);
            SendAudioData();
            continue;
        }
        // mix data from av data and music data
        std::copy(avDataQueueAfterResample_.begin(), avDataQueueAfterResample_.begin() + CODEC_FRAME_LENGTH,
            avDataBuffer_.begin());
        avDataQueueAfterResample_.erase(avDataQueueAfterResample_.begin(),
            avDataQueueAfterResample_.begin() + CODEC_FRAME_LENGTH);
        std::copy(musicDataQueueAfterResample_.begin(), musicDataQueueAfterResample_.begin() + CODEC_FRAME_LENGTH,
            musicDataBuffer_.begin());
        musicDataQueueAfterResample_.erase(musicDataQueueAfterResample_.begin(),
            musicDataQueueAfterResample_.begin() + CODEC_FRAME_LENGTH);

        for (int32_t i = 0; i < CODEC_FRAME_LENGTH; ++i) {
            int32_t result = static_cast<int32_t>(avDataBuffer_[i]) + static_cast<int32_t>(musicDataBuffer_[i]);
            if (result > INT16_MAX) {
                tempOutBuffer_[i] = INT16_MAX;
            } else if (result < INT16_MIN) {
                tempOutBuffer_[i] = INT16_MIN;
            } else {
                tempOutBuffer_[i] = static_cast<int16_t>(result);
            }
        }
        mixDataQueue_.insert(mixDataQueue_.end(), tempOutBuffer_.begin(), tempOutBuffer_.begin() + CODEC_FRAME_LENGTH);
        SendAudioData();
    }
}

void AVDecoderEngine::SendAudioData()
{
    while (mixDataQueue_.size() >= CODEC_FRAME_LENGTH) {
        std::shared_ptr<PcmData> pcmData = std::make_shared<PcmData>();
        pcmData->data.resize(CODEC_FRAME_SIZE);
        uint8_t *dest = pcmData->data.data();
        for (int32_t i = 0; i < CODEC_FRAME_LENGTH; ++i) {
            auto data = mixDataQueue_.front();
            mixDataQueue_.pop_front();
            std::memcpy(dest + i * sizeof(int16_t), &data, sizeof(int16_t));
        }
        pcmData->dataSize = CODEC_FRAME_SIZE;
        if (pcmBufferQueue_) {
            pcmBufferQueue_->Enqueue(pcmData);
        }
    }
}

void AVDecoderEngine::OnAVDecodingFinish()
{
    std::unique_lock<std::mutex> lock(mutex_);
    isAvDecodingFinished_ = true;
    if ((!isAudioDataMute_ && !isAvDecodingFinished_) || (musicDecoderEngine_ && !isMusicDecodingFinished_)) {
        return;
    }
    DrainAudioData();
    DrainResampledData();
}

void AVDecoderEngine::OnMusicDecodingFinish()
{
    std::unique_lock<std::mutex> lock(mutex_);
    isMusicDecodingFinished_ = true;
    if ((!isAudioDataMute_ && !isAvDecodingFinished_) || (musicDecoderEngine_ && !isMusicDecodingFinished_)) {
        return;
    }
    DrainAudioData();
    DrainResampledData();
}

void AVDecoderEngine::DrainAudioData()
{
    // drain av data queue
    if (!isAudioDataMute_) {
        AVDataFormatConvert();

        if (!avDataQueue_.empty()) {
            std::memset(resampleInBuffer_.data(), 0, avDataQueue_.size() * sizeof(float));
            std::transform(
                avDataQueue_.begin(), avDataQueue_.begin() + avDataQueue_.size(),
                resampleInBuffer_.begin(),
                [](int16_t x) { return ConvertFrom16BitToFloat(x); }
            );
            avDataQueue_.erase(avDataQueue_.begin(), avDataQueue_.begin() + avDataQueue_.size());

            avResampler_->Process(resampleInBuffer_.data(), avResampleInputFrameLen_ / DEFAULT_CHANNEL_NUM,
                resampleOutBuffer_.data(), DEFAULT_RESAMPLE_OUTPUT_FRAME_LEN / DEFAULT_CHANNEL_NUM);
            std::transform(
                resampleOutBuffer_.begin(), resampleOutBuffer_.begin() + DEFAULT_RESAMPLE_OUTPUT_FRAME_LEN,
                std::back_inserter(avDataQueueAfterResample_),
                [](float x) { return ConvertFromFloatTo16Bit(x); }
            );
        }
    }

    // drain music data queue
    if (musicDecoderEngine_) {
        MusicDataFormatConvert();

        if (!musicDataQueue_.empty()) {
            std::memset(resampleInBuffer_.data(), 0, musicDataQueue_.size() * sizeof(float));
            std::transform(
                musicDataQueue_.begin(), musicDataQueue_.begin() + musicDataQueue_.size(),
                resampleInBuffer_.begin(),
                [](int16_t x) { return ConvertFrom16BitToFloat(x); }
            );
            musicDataQueue_.erase(musicDataQueue_.begin(), musicDataQueue_.begin() + musicDataQueue_.size());

            musicResampler_->Process(resampleInBuffer_.data(), musicResampleInputFrameLen_ / DEFAULT_CHANNEL_NUM,
                resampleOutBuffer_.data(), DEFAULT_RESAMPLE_OUTPUT_FRAME_LEN / DEFAULT_CHANNEL_NUM);
            std::transform(
                resampleOutBuffer_.begin(), resampleOutBuffer_.begin() + DEFAULT_RESAMPLE_OUTPUT_FRAME_LEN,
                std::back_inserter(musicDataQueueAfterResample_),
                [](float x) { return ConvertFromFloatTo16Bit(x); }
            );
        }
    }
}

void AVDecoderEngine::DrainResampledData()
{
    MixAudioData();

    if (isAudioDataMute_) {
        int32_t remainingLength = musicDataQueueAfterResample_.size();
        mixDataQueue_.insert(mixDataQueue_.end(),
            musicDataQueueAfterResample_.begin(), musicDataQueueAfterResample_.begin() + remainingLength);
        musicDataQueueAfterResample_.erase(musicDataQueueAfterResample_.begin(),
            musicDataQueueAfterResample_.begin() + remainingLength);
    } else if (!musicDecoderEngine_) {
        int32_t remainingLength = avDataQueueAfterResample_.size();
        mixDataQueue_.insert(mixDataQueue_.end(),
            avDataQueueAfterResample_.begin(), avDataQueueAfterResample_.begin() + remainingLength);
        avDataQueueAfterResample_.erase(avDataQueueAfterResample_.begin(),
            avDataQueueAfterResample_.begin() + remainingLength);
    } else {
        int32_t remainingLength = std::min(musicDataQueueAfterResample_.size(), avDataQueueAfterResample_.size());
        std::copy(avDataQueueAfterResample_.begin(), avDataQueueAfterResample_.begin() + remainingLength,
            avDataBuffer_.begin());
        avDataQueueAfterResample_.erase(avDataQueueAfterResample_.begin(),
            avDataQueueAfterResample_.begin() + remainingLength);
        std::copy(musicDataQueueAfterResample_.begin(), musicDataQueueAfterResample_.begin() + remainingLength,
            musicDataBuffer_.begin());
        musicDataQueueAfterResample_.erase(musicDataQueueAfterResample_.begin(),
            musicDataQueueAfterResample_.begin() + remainingLength);

        for (int32_t i = 0; i < remainingLength; ++i) {
            int32_t result = static_cast<int32_t>(avDataBuffer_[i]) + static_cast<int32_t>(musicDataBuffer_[i]);
            if (result > INT16_MAX) {
                tempOutBuffer_[i] = INT16_MAX;
            } else if (result < INT16_MIN) {
                tempOutBuffer_[i] = INT16_MIN;
            } else {
                tempOutBuffer_[i] = static_cast<int16_t>(result);
            }
        }
        mixDataQueue_.insert(mixDataQueue_.end(), tempOutBuffer_.begin(), tempOutBuffer_.begin() + remainingLength);
    }

    SendAudioData();

    if (!mixDataQueue_.empty()) {
        int32_t remainingLength = mixDataQueue_.size();
        std::shared_ptr<PcmData> pcmData = std::make_shared<PcmData>();
        pcmData->data.resize(remainingLength * sizeof(int16_t));
        uint8_t *dest = pcmData->data.data();
        for (int32_t i = 0; i < remainingLength; ++i) {
            auto data = mixDataQueue_.front();
            mixDataQueue_.pop_front();
            std::memcpy(dest + i * sizeof(int16_t), &data, sizeof(int16_t));
        }
        pcmData->dataSize = remainingLength * sizeof(int16_t);
        if (pcmBufferQueue_) {
            pcmBufferQueue_->Enqueue(pcmData);
        }
    }

    // send last frame with exit flag
    std::shared_ptr<PcmData> pcmData = std::make_shared<PcmData>();
    pcmData->flags = 1;
    if (pcmBufferQueue_) {
        pcmBufferQueue_->Enqueue(pcmData);
    }
}