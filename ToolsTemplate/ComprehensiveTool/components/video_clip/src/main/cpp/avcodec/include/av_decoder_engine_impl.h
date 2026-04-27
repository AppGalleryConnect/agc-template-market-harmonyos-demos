/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

#ifndef OH_AV_DECODER_ENGINE_IMPL_H
#define OH_AV_DECODER_ENGINE_IMPL_H

#include <bits/alltypes.h>
#include <mutex>
#include <memory>
#include <atomic>
#include <thread>
#include <unistd.h>
#include "video_decoder.h"
#include "audio_decoder.h"
#include "video_process.h"
#include "demuxer.h"
#include "i_av_decoder_engine.h"

class AudioDecoderCallback {
public:
    virtual ~AudioDecoderCallback() = default;

    virtual void OnAVDataReady(std::shared_ptr<PcmData> pcmData) = 0;

    virtual void OnMusicDataReady(std::shared_ptr<PcmData> pcmData) = 0;

    virtual void OnAVSamplingRateChanged(const int32_t samplingRate) = 0;

    virtual void OnMusicSamplingRateChanged(const int32_t samplingRate) = 0;

    virtual void OnAVDecodingFinish() = 0;

    virtual void OnMusicDecodingFinish() = 0;
};

struct AudioStreamBuilderDeleter {
    void operator()(OH_AudioStreamBuilder *builder) const {
        if (builder) {
            OH_AudioStreamBuilder_Destroy(builder);
        }
    };
};

struct AudioRendererDeleter {
    void operator()(OH_AudioRenderer *renderer) const {
        if (renderer) {
            OH_AudioRenderer_Release(renderer);
        }
    };
};

enum class EosProcessResult {
    NEED_TO_CONTINUE = 0,
    NEED_TO_BREAK = 1
};

/**
 * @brief AVDecoderEngineImpl implements audio and video demuxing and decoding.
 *        It has two attributes: isPreviewed and isDecodingAudioOnly, therefore it has four working modes in total:
 *        1. isPreviewed: true. isDecodingAudioOnly: true. Decoding background music files for previewing.
 *           The decoded data is sent to renderer. When catching EOS, the decoding task will be restarted.
 *        2. isPreviewed: false. isDecodingAudioOnly: true. Decoding background music files for exporting.
 *           The decoded data is send to encoder. The decoding task will loop until the selected video file ends.
 *        3. isPreviewed: true. isDecodingAudioOnly: false. Decoding the selected video file for previewing.
 *           The decoded data is send to renderer. When catching EOS, the decoding task will wait for restarting.
 *        4. isPreviewed: false. isDecodingAudioOnly: false. Decoding the selected video file for exporting.
 *           The decoded data is send to encoder. When catching EOS, the decoding task will be stopped.
 */
class AVDecoderEngineImpl {
public:
    /**
     * @brief Create av decoder engine instance.
     * @param fd. The fd of the file to be decoded.
     * @param cb. Callback used to notify decoding status. When decoding background music files, cb will not be used.
     * @param isDecodingAudioOnly. True means current decoder engine is used to demux and decode background music file.
     *                             False means current decoder engine is used to demux and decode the selected video.
     */
    AVDecoderEngineImpl(int fd, std::weak_ptr<AVDecodeCallback> cb, bool isDecodingAudioOnly);
    virtual ~AVDecoderEngineImpl();

public:
    int32_t Init();
    int32_t Start();
    int32_t Pause();
    int32_t Stop();
    int32_t Seek(int64_t millisecond, OH_AVSeekMode mode);
    int32_t SetPlayDuration(int64_t duration);
    int32_t SetVideoOutputWindow(OHNativeWindow* surfaceWindow);
    int32_t SetAudioOutputBufferQueue(std::weak_ptr<AudioDecoderCallback> callback);
    OH_AVFormat* GetVideoFormat();
    OH_AVFormat* GetAudioFormat();
    int32_t SetHighPerformance(bool enableFlag);
    int32_t AudioUnselect(bool unselectFlag);
    int32_t AudioMute(bool muteFlag);
    bool IsAudioTrackExisted();
    int64_t GetVideoDuration();

private:
    void VideoDecInputThread();
    void VideoDecOutputThread();
    void AudioDecInputThread();
    void AudioDecOutputThread();
    EosProcessResult ProcessVideoInputEos();
    EosProcessResult ProcessAudioInputEos();
    void Release();
    void StartRelease();
    void VPERelease();
    void ReleaseThread();
    int32_t CreateAudioDecoder();
    int32_t CreateVideoDecoder();
    void CheckAndWaitForRestart();

    void FillAudioDataToRenderer(CodecBufferInfo &bufferInfo);
    std::shared_ptr<PcmData> FillAudioDataToEncoder(CodecBufferInfo &bufferInfo);
    void DataReadyCallback(std::shared_ptr<PcmData> pcmData);
    void SamplingRateChangeCallback(const int32_t samplingRate);
    void OnErrorCallback(CodecStatus status);
    void OnStreamChanged(OH_AVFormat *format);
    OH_NativeBuffer_TransformType ConvertRotateToDisplayRotate(int32_t rotation);
    
    bool isDecodingAudioOnly_ = false;
    uint64_t id_ = 0;
    int fd_ = -1;
    std::string logTag_ = "";
    std::weak_ptr<AVDecodeCallback> cb_;
    std::shared_ptr<Demuxer> demuxer_{nullptr};
    std::shared_ptr<VideoDecoder> videoDecoder_{nullptr};
    std::shared_ptr<VideoProcess> metadataGenerationVPE_{nullptr};
    std::shared_ptr<VideoProcess> colorSpaceConversionVPE_{nullptr};
    std::shared_ptr<AudioDecoder> audioDecoder_{nullptr};
    CodecStatus audioDecoderState_{CodecStatus::INITIALIZED};
    CodecStatus videoDecoderState_{CodecStatus::INITIALIZED};
    OHNativeWindow *nativeWindow_{nullptr};
    std::mutex mutex_;
    std::mutex doneMutex;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    std::atomic<bool> isStarted_{false};
    std::atomic<bool> isPaused_{false};
    std::atomic<bool> isReleased_{false};
    std::atomic<bool> isVideoInputDone_{true};
    std::atomic<bool> isVideoOutputDone_{true};
    std::atomic<bool> isAudioInputDone_{true};
    std::atomic<bool> isAudioOutputDone_{true};
    std::atomic<bool> isDecodingAudioFinished_{false};
    std::unique_ptr<std::thread> videoDecInputThread_ = nullptr;
    std::unique_ptr<std::thread> videoDecOutputThread_ = nullptr;
    std::unique_ptr<std::thread> audioDecInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioDecOutputThread_ = nullptr;
    CodecUserData *videoDecContext_ = nullptr;
    CodecUserData *audioDecContext_ = nullptr;
    std::unique_ptr<OH_AudioStreamBuilder, AudioStreamBuilderDeleter> builder_{nullptr, AudioStreamBuilderDeleter{}};
    std::unique_ptr<OH_AudioRenderer, AudioRendererDeleter> audioRenderer_{nullptr, AudioRendererDeleter{}};
    static constexpr int64_t MICROSECOND = 1000000;

    std::weak_ptr<AudioDecoderCallback> audioDataCb_;
    std::atomic<bool> isPreview_{true};
    bool highPerformanceFlag_ = false;
    OH_AVFormat *videoFormat_ = nullptr;
    bool isFlushedFlag = false;
    std::atomic<bool> isAudioUnselected_{false};
    std::atomic<bool> isAudioMute_{false};
    std::atomic<double> avDataDuration_{-1};
    double musicDecodingPosition_ = 0;
    double avDecodingPosition_ = 0;
    bool isAudioTrackExisted_ = true;
    std::condition_variable decodingFinishCond_;
    std::mutex decodingFinishMutex_;
    std::atomic<bool> isRestarted_{false};
};

#endif // OH_AV_DECODER_ENGINE_IMPL_H