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

#ifndef OH_VEF_AV_DECODER_ENGINE_H
#define OH_VEF_AV_DECODER_ENGINE_H

#include <memory>
#include "i_av_decoder_engine.h"
#include "av_decoder_engine_impl.h"
#include <deque>
#include "audio_proresampler.h"

class AVDecoderEngine : public IAVDecoderEngine, public AudioDecoderCallback,
    public std::enable_shared_from_this<AVDecoderEngine> {
public:
    AVDecoderEngine(int fd, std::weak_ptr<AVDecodeCallback> cb);
    ~AVDecoderEngine() override;

    int32_t Init() override;
    int32_t Start() override;
    int32_t Pause() override;
    int32_t Stop() override;
    int32_t Seek(int64_t millisecond, OH_AVSeekMode mode) override;
    int32_t SetPlayDuration(int64_t duration) override;
    int32_t SetVideoOutputWindow(OHNativeWindow* surfaceWindow) override;
    int32_t SetAudioOutputBufferQueue(std::shared_ptr<PcmBufferQueue>& queue) override;
    OH_AVFormat* GetVideoFormat() override;
    OH_AVFormat* GetAudioFormat() override;
    int32_t SetHighPerformance(bool enableFlag) override;
    int32_t AudioUnselect(bool unselectFlag) override;
    int32_t AudioMute(bool muteFlag) override;
    int32_t AddAudio(int fd) override;
    int32_t DeleteAudio(int fd) override;
    int64_t GetVideoDuration() override;

    void OnAVDataReady(std::shared_ptr<PcmData> pcmData) override;
    void OnMusicDataReady(std::shared_ptr<PcmData> pcmData) override;
    void OnAVSamplingRateChanged(const int32_t samplingRate) override;
    void OnMusicSamplingRateChanged(const int32_t samplingRate) override;
    void OnAVDecodingFinish() override;
    void OnMusicDecodingFinish() override;

private:
    void AVDataFormatConvert();
    void MusicDataFormatConvert();
    void MixAudioData();
    void SendAudioData();
    void DrainAudioData();
    void DrainResampledData();

    std::atomic<bool> isAudioDataMute_{false};
    bool isAvAudioExisted_ = true;
    std::mutex mutex_;
    std::atomic<bool> isAvDecodingStarted_{false};
    std::atomic<bool> isMusicDecodingStarted_{false};
    bool isAvDecodingFinished_ = false;
    bool isMusicDecodingFinished_ = false;
    int64_t avDataDuration_ = -1;
    int32_t avSamplingRate_ = 44100;
    int32_t musicSamplingRate_ = 44100;
    int32_t avResampleInputFrameLen_ = 3528;
    int32_t musicResampleInputFrameLen_ = 3528;

    std::shared_ptr<AVDecoderEngineImpl> avDecoderEngine_ = nullptr;
    std::shared_ptr<AVDecoderEngineImpl> musicDecoderEngine_ = nullptr;
    std::shared_ptr<PcmBufferQueue> pcmBufferQueue_ = nullptr;
    std::deque<int16_t> avDataQueue_;
    std::deque<int16_t> musicDataQueue_;
    std::deque<int16_t> avDataQueueAfterResample_;
    std::deque<int16_t> musicDataQueueAfterResample_;
    std::deque<int16_t> mixDataQueue_;
    std::vector<int16_t> avDataBuffer_;
    std::vector<int16_t> musicDataBuffer_;
    std::vector<int16_t> tempOutBuffer_;

    std::unique_ptr<Resampler> avResampler_ = nullptr;
    std::unique_ptr<Resampler> musicResampler_ = nullptr;
    std::vector<float> resampleInBuffer_;
    std::vector<float> resampleOutBuffer_;
};

#endif // OH_VEF_AV_DECODER_ENGINE_H