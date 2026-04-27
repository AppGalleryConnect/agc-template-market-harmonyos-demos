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

#ifndef OH_VEF_AV_ENCODER_ENGINE_H
#define OH_VEF_AV_ENCODER_ENGINE_H

#include <mutex>
#include <memory>
#include <atomic>
#include <thread>
#include "video_encoder.h"
#include "audio_encoder.h"
#include "muxer.h"
#include "avcodec_info.h"
#include "i_av_encoder_engine.h"

class AVEncoderEngine : public IAVEncoderEngine {
public:
    AVEncoderEngine(const AVEncodeParam& encodeParam, std::weak_ptr<AVEncodeCallback> cb);
    ~AVEncoderEngine() override;
    int32_t Init() override;
    int32_t Start() override;
    int32_t Stop() override;
    int32_t SendEOS() override;
    OHNativeWindow* GetVideoInputWindow() override;
    std::shared_ptr<PcmBufferQueue> GetAudioInputBufferQueue() const override;

private:
    void EncOutputThread();
    void AudioEncInputThread();
    void AudioEncOutputThread();
    void Release();
    void StartRelease();
    int32_t WaitForDone();
    
    int32_t CreateAudioEncoder();
    int32_t CreateVideoEncoder();
    void SetAVFormat(const AVEncodeParam& encodeParam);

    bool FillAudioData(CodecBufferInfo &bufferInfo);
    void DrainAudioData();

    std::unique_ptr<VideoEncoder> videoEncoder_ = nullptr;
    std::unique_ptr<AudioEncoder> audioEncoder_ = nullptr;
    std::unique_ptr<Muxer> muxer_ = nullptr;

    std::mutex mutex_;
    std::atomic<bool> isStarted_{false};
    std::atomic<bool> isReleasedDone_{false};
    std::atomic<bool> isAudioEncodingFinished_{false};
    int32_t isFirstFrame_ = true;
    std::unique_ptr<std::thread> encOutputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncOutputThread_ = nullptr;
    std::unique_ptr<std::thread> releaseThread_ = nullptr;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    CodecUserData *encContext_ = nullptr;
    CodecUserData *audioEncContext_ = nullptr;

    std::weak_ptr<AVEncodeCallback> cb_;
    std::shared_ptr<PcmBufferQueue> pcmBufferQueue_ = nullptr;
    std::atomic<bool> isFirstSyncFrame_{true};
    std::atomic<bool> isFirstCodecData_{true};
};


#endif // OH_VEF_AV_ENCODER_ENGINE_H