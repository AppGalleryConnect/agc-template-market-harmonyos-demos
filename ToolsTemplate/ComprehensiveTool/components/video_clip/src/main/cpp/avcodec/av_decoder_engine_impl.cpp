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
#include <cstdint>
#include <sys/stat.h>
#include <chrono>
#include "avcodec_log.h"
#include "av_decoder_engine_impl.h"
#include "codec_common.h"
#include <cinttypes>

#undef LOG_TAG
#define LOG_TAG "videoEditor"

namespace {
constexpr int BALANCE_VALUE = 10;
constexpr int STEREO = 2;
static constexpr int32_t MS_IN_SECOND = 1000;
static constexpr int32_t US_IN_MS = 1000;
static constexpr int32_t SEEK_POSITION_OFFSET_MS = 500;
static constexpr int32_t DEFAULT_AV_BUFFER_CAPACITY = 2 * 1024 * 1024;
}

using namespace std::chrono_literals;

AVDecoderEngineImpl::AVDecoderEngineImpl(int fd, std::weak_ptr<AVDecodeCallback> cb, bool isDecodingAudioOnly)
    : isDecodingAudioOnly_(isDecodingAudioOnly), fd_(fd), cb_(cb)
{
    sampleInfo_.inputFd = fd_;
    struct stat fileStat;
    if (fstat(fd, &fileStat) == -1) {
        AVCODEC_SAMPLE_LOGE("fd[%{public}d] error.", fd);
    } else {
        sampleInfo_.inputFileSize = fileStat.st_size;
    }
}

AVDecoderEngineImpl::~AVDecoderEngineImpl()
{
    Stop();
    StartRelease();
    VPERelease();
}

int32_t AVDecoderEngineImpl::CreateAudioDecoder() {
    AVCODEC_SAMPLE_LOGW("audio mime:%{public}s", sampleInfo_.audioCodecMime.c_str());
    int32_t ret = audioDecoder_->Create(sampleInfo_.audioCodecMime);
    if (ret != AV_OK) {
        AVCODEC_SAMPLE_LOGE("Create audio decoder failed, mime:%{public}s", sampleInfo_.audioCodecMime.c_str());
    } else {
        audioDecContext_ = new CodecUserData;
        ret = audioDecoder_->Config(sampleInfo_, audioDecContext_);
        CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "Audio Decoder config failed");
        OH_AudioStreamBuilder *builder;
        OH_AudioStreamBuilder_Create(&builder, AUDIOSTREAM_TYPE_RENDERER);
        builder_.reset(builder);
        OH_AudioStreamBuilder_SetLatencyMode(builder_.get(), AUDIOSTREAM_LATENCY_MODE_NORMAL);
        // Set the audio sample rate
        OH_AudioStreamBuilder_SetSamplingRate(builder_.get(), sampleInfo_.audioSampleRate);
        // Set the audio channel
        OH_AudioStreamBuilder_SetChannelCount(builder_.get(), sampleInfo_.audioChannelCount);
        // Set the audio sample format
        OH_AudioStreamBuilder_SetSampleFormat(builder_.get(), AUDIOSTREAM_SAMPLE_S16LE);
        // Sets the encoding type of the audio stream
        OH_AudioStreamBuilder_SetEncodingType(builder_.get(), AUDIOSTREAM_ENCODING_TYPE_RAW);
        // Set the working scenario for the output audio stream
        OH_AudioStreamBuilder_SetRendererInfo(builder_.get(), AUDIOSTREAM_USAGE_MOVIE);
        AVCODEC_SAMPLE_LOGW("Init audioSampleRate: %{public}d, ChannelCount: %{public}d", sampleInfo_.audioSampleRate,
                            sampleInfo_.audioChannelCount);
        OH_AudioRenderer_Callbacks callbacks;
        // Configure the callback function
        callbacks.OH_AudioRenderer_OnWriteData = nullptr;
        callbacks.OH_AudioRenderer_OnStreamEvent = SampleCallback::OnRenderStreamEvent;
        callbacks.OH_AudioRenderer_OnInterruptEvent = SampleCallback::OnRenderInterruptEvent;
        callbacks.OH_AudioRenderer_OnError = SampleCallback::OnRenderError;
        // Set the callback for the output audio stream
        OH_AudioStreamBuilder_SetRendererCallback(builder_.get(), callbacks, audioDecContext_);
        OH_AudioRenderer_OnWriteDataCallback callback = SampleCallback::OnWriteDataCallback;
        OH_AudioStreamBuilder_SetRendererWriteDataCallback(builder_.get(), callback, audioDecContext_);
        OH_AudioRenderer *audioRenderer;
        OH_AudioStreamBuilder_GenerateRenderer(builder_.get(), &audioRenderer);
        audioRenderer_.reset(audioRenderer);
        builder_.reset();
    }
    return AV_OK;
}

int32_t AVDecoderEngineImpl::CreateVideoDecoder() {
    if (isDecodingAudioOnly_) {
        return AV_OK;
    }
    AVCODEC_SAMPLE_LOGW("video mime:%{public}s", sampleInfo_.videoCodecMime.c_str());
    int32_t ret = videoDecoder_->Create(sampleInfo_.videoCodecMime);
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "Create video decoder failed, mime:%{public}s",
        sampleInfo_.videoCodecMime.c_str());

    if (sampleInfo_.enableVPEFlag) {
        // create vpe
        // HDR to HDRVivid
        metadataGenerationVPE_ = std::make_shared<VideoProcess>();
        // HDRVivid to SDR
        colorSpaceConversionVPE_ = std::make_shared<VideoProcess>();
        bool retValue = metadataGenerationVPE_->PrepareSurface(VIDEO_PROCESSING_TYPE_METADATA_GENERATION);
        retValue = colorSpaceConversionVPE_->PrepareSurface(VIDEO_PROCESSING_TYPE_COLOR_SPACE_CONVERSION);
        CHECK_AND_RETURN_RET_LOG(retValue == true, AV_ERROR, "videoProcess_ Prepare failed");
        metadataGenerationVPE_->windowVPEOut_ = colorSpaceConversionVPE_->windowVPEIn_;
        colorSpaceConversionVPE_->windowVPEOut_ = sampleInfo_.window;
        sampleInfo_.window = metadataGenerationVPE_->windowVPEIn_;
        uint8_t metaData = -1;
        OH_NativeWindow_SetMetadataValue(colorSpaceConversionVPE_->windowVPEOut_, OH_HDR_METADATA_TYPE, sizeof(uint8_t),
                                         &metaData);
        OH_NativeWindow_NativeWindowHandleOpt(colorSpaceConversionVPE_->windowVPEOut_, SET_FORMAT,
                                              NATIVEBUFFER_PIXEL_FMT_YCBCR_420_SP);
        OH_NativeWindow_NativeWindowHandleOpt(colorSpaceConversionVPE_->windowVPEOut_, SET_TRANSFORM,
                                              ConvertRotateToDisplayRotate(sampleInfo_.rotation));
        OH_NativeWindow_SetColorSpace(colorSpaceConversionVPE_->windowVPEOut_, OH_COLORSPACE_BT709_LIMIT);

        retValue = metadataGenerationVPE_->InitProcessing();
        CHECK_AND_RETURN_RET_LOG(retValue == true, AV_ERROR, "metadataGenerationVPE_ Init failed");
        retValue = colorSpaceConversionVPE_->InitProcessing();
        CHECK_AND_RETURN_RET_LOG(retValue == true, AV_ERROR, "colorSpaceConversionVPE_ Init failed");
    }
    videoDecContext_ = new CodecUserData;
    videoDecContext_->errorCallback_ = [&](CodecStatus status) { OnErrorCallback(status); };
    videoDecContext_->streamChangedCallback_ = [&](OH_AVFormat *format) { OnStreamChanged(format); };
    ret = videoDecoder_->Config(sampleInfo_, videoDecContext_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, ret, "Video Decoder config failed");
    return AV_OK;
}

void AVDecoderEngineImpl::StartRelease() {
    AVCODEC_SAMPLE_LOGI("start release");
    // wait until all four threads finish.
    std::unique_lock<std::mutex> lock(doneMutex);
    doneCond_.wait(lock, [this]() {
        return isVideoInputDone_.load() && isVideoOutputDone_.load() && isAudioInputDone_.load() &&
            isAudioOutputDone_.load();
    });
    
    if (audioRenderer_) {
        OH_AudioRenderer_Stop(audioRenderer_.get());
    }
    if (!isReleased_) {
        isReleased_ = true;
        Release();
    }
}

void AVDecoderEngineImpl::VPERelease() {
    if (metadataGenerationVPE_ != nullptr) {
        OH_NativeWindow_DestroyNativeWindow(metadataGenerationVPE_->windowVPEIn_);
        metadataGenerationVPE_->StopProcessing();
        metadataGenerationVPE_->DestroyProcessing();
        metadataGenerationVPE_.reset();
    }
    if (colorSpaceConversionVPE_ != nullptr) {
        OH_NativeWindow_DestroyNativeWindow(colorSpaceConversionVPE_->windowVPEIn_);
        colorSpaceConversionVPE_->StopProcessing();
        colorSpaceConversionVPE_->DestroyProcessing();
        colorSpaceConversionVPE_.reset();
    }
    return;
}

void AVDecoderEngineImpl::ReleaseThread() {
    if (videoDecInputThread_ && videoDecInputThread_->joinable()) {
        videoDecInputThread_->detach();
        videoDecInputThread_.reset();
    }
    if (videoDecOutputThread_ && videoDecOutputThread_->joinable()) {
        videoDecOutputThread_->detach();
        videoDecOutputThread_.reset();
    }
    if (audioDecInputThread_ && audioDecInputThread_->joinable()) {
        audioDecInputThread_->detach();
        audioDecInputThread_.reset();
    }
    if (audioDecOutputThread_ && audioDecOutputThread_->joinable()) {
        audioDecOutputThread_->detach();
        audioDecOutputThread_.reset();
    }
}

void AVDecoderEngineImpl::Release() {
    std::lock_guard<std::mutex> lock(mutex_);
    isStarted_ = false;
    
    audioRenderer_.reset();
    ReleaseThread();

    if (demuxer_ != nullptr) {
        demuxer_->Release();
        demuxer_.reset();
    }
    if (videoDecoder_ != nullptr) {
        videoDecoder_->Release();
        videoDecoder_.reset();
    }
    if (videoDecContext_ != nullptr) {
        delete videoDecContext_;
        videoDecContext_ = nullptr;
    }
    if (audioDecoder_ != nullptr) {
        audioDecoder_->Release();
        audioDecoder_.reset();
    }
    if (audioDecContext_ != nullptr) {
        delete audioDecContext_;
        audioDecContext_ = nullptr;
    }
    builder_.reset();
    doneCond_.notify_all();
    // Clear the queue
    while (audioDecContext_ && !audioDecContext_->renderQueue.empty()) {
        audioDecContext_->renderQueue.pop();
    }
    AVCODEC_SAMPLE_LOGI("Succeed");
}

EosProcessResult AVDecoderEngineImpl::ProcessVideoInputEos()
{
    if (isPreview_) {
        // while previewing, if EOS is caught, video decoding input thread should wait until:
        // 1. the decoding task is restarted,
        // 2. or the decoding task is stopped.
        AVCODEC_SAMPLE_LOGI("Catch EOS, currently previewing, wait for restart");
        std::unique_lock<std::mutex> restartLock(decodingFinishMutex_);
        CHECK_AND_RETURN_RET_LOG(isStarted_, EosProcessResult::NEED_TO_BREAK, "Decoder input thread out");
        isRestarted_.store(false);
        decodingFinishCond_.wait(restartLock, [this]() { return isRestarted_.load() || !isStarted_.load(); });
        AVCODEC_SAMPLE_LOGI("Restart, continue running");
        return EosProcessResult::NEED_TO_CONTINUE;
    }
    // while exporting, if EOS is caught, video decoding input thread should exit immediately.
    AVCODEC_SAMPLE_LOGI("Catch EOS, currently exporting, thread out");
    return EosProcessResult::NEED_TO_BREAK;
}

EosProcessResult AVDecoderEngineImpl::ProcessAudioInputEos()
{
    if (isDecodingAudioOnly_) {
        // while decoding background music files, if EOS is caught, the audio decoding input thread should continue,
        // and then restarts when audio decoding output thread seeks to 0.
        AVCODEC_SAMPLE_LOGW("Catch EOS, thread continue");
        return EosProcessResult::NEED_TO_CONTINUE;
    } else if (isPreview_) {
        // while decoding videos for previewing, if EOS is caught, audio decoding input thread should wait until:
        // 1. the decoding task is restarted,
        // 2. or the decoding task is stopped.
        AVCODEC_SAMPLE_LOGI("Catch EOS, currently previewing, wait for restart");
        std::unique_lock<std::mutex> restartLock(decodingFinishMutex_);
        CHECK_AND_RETURN_RET_LOG(isStarted_, EosProcessResult::NEED_TO_BREAK, "Decoder input thread out");
        isRestarted_.store(false);
        decodingFinishCond_.wait(restartLock, [this]() { return isRestarted_.load() || !isStarted_.load(); });
        AVCODEC_SAMPLE_LOGI("Restart, continue running");
        return EosProcessResult::NEED_TO_CONTINUE;
    }
    // while decoding videos for exporting, if EOS is caught, audio decoding input thread should exit immediately:
    AVCODEC_SAMPLE_LOGI("Catch EOS, currently exporting, thread out");
    return EosProcessResult::NEED_TO_BREAK;
}

void AVDecoderEngineImpl::VideoDecInputThread() {
    {
        std::lock_guard<std::mutex> lock(doneMutex);
        isVideoInputDone_ = false;
    }
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder input thread out");
        CheckAndWaitForRestart();
        std::unique_lock<std::mutex> lock(videoDecContext_->inputMutex);
        bool condRet = videoDecContext_->inputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !videoDecContext_->inputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!videoDecContext_->inputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = videoDecContext_->inputBufferInfoQueue.front();
        videoDecContext_->inputBufferInfoQueue.pop();
        videoDecContext_->inputFrameCount++;
        lock.unlock();

        demuxer_->ReadSample(demuxer_->GetVideoTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                             bufferInfo.attr);

        int32_t ret = videoDecoder_->PushInputBuffer(bufferInfo);
        CHECK_AND_LOGW(ret == AV_OK, "video decoder free PushInputBuffer failed:%{public}d", ret);
        
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            EosProcessResult processResult = ProcessVideoInputEos();
            if (processResult == EosProcessResult::NEED_TO_CONTINUE) {
                continue;
            } else if (processResult == EosProcessResult::NEED_TO_BREAK) {
                break;
            }
        }
    }
    {
        std::lock_guard<std::mutex> lock(doneMutex);
        isVideoInputDone_ = true;
    }
    StartRelease();
}

void AVDecoderEngineImpl::VideoDecOutputThread() {
    {
        std::lock_guard<std::mutex> lock(doneMutex);
        isVideoOutputDone_ = false;
    }
    sampleInfo_.frameInterval = MICROSECOND / sampleInfo_.frameRate;
    while (true) {
        thread_local auto lastPushTime = std::chrono::system_clock::now();
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        CheckAndWaitForRestart();
        std::unique_lock<std::mutex> lock(videoDecContext_->outputMutex);
        bool condRet = videoDecContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !videoDecContext_->outputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        CHECK_AND_CONTINUE_LOG(!videoDecContext_->outputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = videoDecContext_->outputBufferInfoQueue.front();
        videoDecContext_->outputBufferInfoQueue.pop();
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            if (isPreview_) {
                // while previewing, if EOS is caught, video decoding output thread should callback to notify EOS and
                // wait until:
                // 1. the decoding task is restarted,
                // 2. or the decoding task is stopped.
                AVCODEC_SAMPLE_LOGI("Catch EOS, currently previewing, wait for restart");
                std::unique_lock<std::mutex> restartLock(decodingFinishMutex_);
                if (auto cb = cb_.lock()) {
                    cb->OnDecodeStatus(CodecStatus::END_OF_STREAM);
                }
                CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
                isRestarted_.store(false);
                lock.unlock();
                decodingFinishCond_.wait(restartLock, [this]() { return isRestarted_.load() || !isStarted_.load(); });
                AVCODEC_SAMPLE_LOGI("Restart, continue running");
                continue;
            }
            // while exporting, if EOS is caught, video decoding input thread should callback to notify EOS and
            // exit immediately.
            AVCODEC_SAMPLE_LOGI("Catch EOS, currently exporting, thread out");
            if (auto cb = cb_.lock()) {
                cb->OnDecodeStatus(CodecStatus::END_OF_STREAM);
            }
            break;
        }

        videoDecContext_->outputFrameCount++;
        if (auto cb = cb_.lock()) {
            cb->OnDecodeFrame(bufferInfo.attr.pts);
        }
        AVCODEC_SAMPLE_LOGD(
            "Video decoder out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
            videoDecContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags, bufferInfo.attr.pts);
        lock.unlock();

        int32_t ret = videoDecoder_->FreeOutputBuffer(bufferInfo.bufferIndex, true);
        CHECK_AND_LOGW(ret == AV_OK, "video decoder free FreeOutputBuffer failed:%{public}d", ret);
        if (highPerformanceFlag_ == false) {
            std::this_thread::sleep_until(lastPushTime + std::chrono::microseconds(sampleInfo_.frameInterval));
        }
        lastPushTime = std::chrono::system_clock::now();
    }
    {
        std::lock_guard<std::mutex> lock(doneMutex);
        isVideoOutputDone_ = true;
    }
    StartRelease();
}

void AVDecoderEngineImpl::AudioDecInputThread() {
    {
        std::lock_guard<std::mutex> lock(doneMutex);
        isAudioInputDone_ = false;
    }
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder input thread out");
        CheckAndWaitForRestart();
        std::unique_lock<std::mutex> lock(audioDecContext_->inputMutex);
        bool condRet = audioDecContext_->inputCond.wait_for(lock, 5s, [this]() {
            return !isStarted_ || !audioDecContext_->inputBufferInfoQueue.empty() ||
                (!isPreview_ && isDecodingAudioFinished_);
        });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_BREAK_LOG(isPreview_ || !isDecodingAudioFinished_, "decoding audio finished, thread out");
        CHECK_AND_CONTINUE_LOG(!audioDecContext_->inputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = audioDecContext_->inputBufferInfoQueue.front();
        audioDecContext_->inputBufferInfoQueue.pop();
        audioDecContext_->inputFrameCount++;
        lock.unlock();

        demuxer_->ReadSample(demuxer_->GetAudioTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                             bufferInfo.attr);

        int32_t ret = audioDecoder_->PushInputBuffer(bufferInfo);
        CHECK_AND_LOGW(ret == AV_OK, "audio decoder free PushInputBuffer failed:%{public}d", ret);

        if ((bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS)) {
            EosProcessResult processResult = ProcessAudioInputEos();
            if (processResult == EosProcessResult::NEED_TO_CONTINUE) {
                continue;
            } else if (processResult == EosProcessResult::NEED_TO_BREAK) {
                break;
            }
        }
    }
    {
        std::lock_guard<std::mutex> lock(doneMutex);
        isAudioInputDone_ = true;
    }
    StartRelease();
}

void AVDecoderEngineImpl::AudioDecOutputThread() {
    {
        std::lock_guard<std::mutex> lock(doneMutex);
        isAudioOutputDone_ = false;
    }
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        CheckAndWaitForRestart();
        std::unique_lock<std::mutex> lock(audioDecContext_->outputMutex);
        bool condRet = audioDecContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioDecContext_->outputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        CHECK_AND_CONTINUE_LOG(!audioDecContext_->outputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = audioDecContext_->outputBufferInfoQueue.front();
        audioDecContext_->outputBufferInfoQueue.pop();
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            if (isDecodingAudioOnly_) {
                // while decoding background music files, if EOS is caught, the audio decoding output thread should seek
                // to 0, restart, and then continue.
                lock.unlock();
                Seek(0, SEEK_MODE_CLOSEST_SYNC);
                Start();
                AVCODEC_SAMPLE_LOGI("Catch EOS, thread continue");
                continue;
            } else if (isPreview_) {
                // while decoding videos for previewing, if EOS is caught, after the remaining data in renderQueue is 
                // drained, audio decoding output thread should wait until:
                // 1. the decoding task is restarted,
                // 2. or the decoding task is stopped.
                AVCODEC_SAMPLE_LOGI("Catch EOS, currently previewing, wait for restart");
                std::unique_lock<std::mutex> lockRender(audioDecContext_->renderMutex);
                audioDecContext_->renderCond.wait_for(lockRender, 500ms, [this]() {
                    return audioDecContext_->renderQueue.size() < 1 || !isStarted_.load();
                });
                CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
                OH_AudioRenderer_Pause(audioRenderer_.get());
                lockRender.unlock();
                std::unique_lock<std::mutex> restartLock(decodingFinishMutex_);
                CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
                isRestarted_.store(false);
                lock.unlock();
                decodingFinishCond_.wait(restartLock, [this]() { return isRestarted_.load() || !isStarted_.load(); });
                AVCODEC_SAMPLE_LOGI("Restart, continue running");
                continue;
            }
            // while decoding videos for exporting, if EOS is caught, audio decoding output thread should callback to
            // notify AvDecoderEngine and exit immediately:
            AVCODEC_SAMPLE_LOGI("Catch EOS, currently exporting, callback to decoder engine and thread out");
            if (auto cb = audioDataCb_.lock()) {
                cb->OnAVDecodingFinish();
            }
            break;
        }
        audioDecContext_->outputFrameCount++;
        AVCODEC_SAMPLE_LOGD(
            "Audio decoder out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
            audioDecContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags, bufferInfo.attr.pts);
        std::shared_ptr<PcmData> pcmData = nullptr;
        if (isPreview_) {
            FillAudioDataToRenderer(bufferInfo);
        } else {
            pcmData = FillAudioDataToEncoder(bufferInfo);
            CHECK_AND_BREAK_LOG(pcmData, "audio decoding finish, decoder output thread out");
        }
        lock.unlock();

        int32_t ret = audioDecoder_->FreeOutputBuffer(bufferInfo.bufferIndex, true);
        CHECK_AND_LOGW(ret == AV_OK, "audio decoder FreeOutputBuffer failed:%{public}d", ret);

        if (isPreview_) {
            std::unique_lock<std::mutex> lockRender(audioDecContext_->renderMutex);
            audioDecContext_->renderCond.wait_for(lockRender, 20ms, [this, bufferInfo]() {
                return audioDecContext_->renderQueue.size() < BALANCE_VALUE * bufferInfo.attr.size;
            });
        } else if (pcmData) {
            DataReadyCallback(pcmData);
        }
    }
    if (isPreview_) {
        std::unique_lock<std::mutex> lockRender(audioDecContext_->renderMutex);
        audioDecContext_->renderCond.wait_for(lockRender, 500ms, [this](){
            return audioDecContext_->renderQueue.size() < 1 || !isStarted_.load();
        });
    }
    {
        // while decoding audio files for exporting, when audio decoding output thread finished,
        // audio decoding input thread should be notified to stop.
        std::lock_guard<std::mutex> lock(doneMutex);
        isAudioOutputDone_ = true;
        if (!isPreview_) {
            isDecodingAudioFinished_ = true;
            audioDecContext_->inputCond.notify_all();
        }
    }
    AVCODEC_SAMPLE_LOGI("Out buffer end");
    StartRelease();
}

int32_t AVDecoderEngineImpl::Init()
{
    std::unique_lock<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AV_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ == nullptr && videoDecoder_ == nullptr && audioDecoder_ == nullptr,
                             AV_ERROR, "Already started.");

    videoDecoder_ = std::make_unique<VideoDecoder>();
    audioDecoder_ = std::make_unique<AudioDecoder>();
    demuxer_ = std::make_unique<Demuxer>();
    int32_t ret = demuxer_->Create(sampleInfo_);
    if (ret == AV_OK) {
        if (((demuxer_->GetVideoFormat() == nullptr) && (!isDecodingAudioOnly_)) ||
            ((demuxer_->GetAudioFormat() == nullptr) && (isDecodingAudioOnly_))) {
            ret = AV_ERROR;
        } else if (demuxer_->GetAudioFormat() == nullptr) {
            isAudioTrackExisted_ = false;
        }
    } else {
        AVCODEC_SAMPLE_LOGE("Create demuxer failed");
    }

    if (ret == AV_OK && isAudioTrackExisted_) {
        ret = CreateAudioDecoder();
    } else {
        AVCODEC_SAMPLE_LOGE("missing audio or video resource");
    }
    
    if (ret == AV_OK) {
        ret = CreateVideoDecoder();
    } else {
        AVCODEC_SAMPLE_LOGE("Create audio decoder failed");
    }
    
    if (ret != AV_OK) {
        AVCODEC_SAMPLE_LOGE("Create video decoder failed");
        doneCond_.notify_all();
        lock.unlock();
        StartRelease();
        VPERelease();
        return AV_ERROR;
    }
    SamplingRateChangeCallback(sampleInfo_.audioSampleRate);
    if (auto cb = cb_.lock()) {
        cb->OnDecodeStatus(CodecStatus::INITIALIZED);
    }
    AVCODEC_SAMPLE_LOGI("Succeed");
    return AV_OK;
}

int64_t AVDecoderEngineImpl::GetVideoDuration()
{
    CHECK_AND_RETURN_RET_LOG(demuxer_, 0, "No Demuxer!");
    if (!videoFormat_) {
        videoFormat_ = demuxer_->GetVideoFormat();
    }
    int32_t videoTrackId = demuxer_->GetVideoTrackId();
    int64_t fileDuration;
    OH_AVFormat_GetLongValue(videoFormat_, OH_MD_KEY_DURATION, &fileDuration);
    
    OH_AVCodecBufferAttr attr;
    OH_AVBuffer *buffer = OH_AVBuffer_Create(DEFAULT_AV_BUFFER_CAPACITY);
    CHECK_AND_RETURN_RET_LOG(buffer, fileDuration, "OH_AVBuffer_Create failed");
    
    demuxer_->ReadSample(videoTrackId, buffer, attr);
    int64_t startPts = attr.pts;
    int64_t endPts = 0;
    int64_t frameDuration = 0;
    AVCODEC_SAMPLE_LOGI("the video start position is %{public}lld", startPts);
    
    // try seeking to the EOS
    int64_t seekPosition =
        fileDuration / US_IN_MS - SEEK_POSITION_OFFSET_MS >= 0 ? fileDuration / US_IN_MS - SEEK_POSITION_OFFSET_MS : 0;
    int32_t ret = demuxer_->Seek(seekPosition, SEEK_MODE_PREVIOUS_SYNC);
    if (ret != 0) {
        AVCODEC_SAMPLE_LOGE("seek failed, ret = %{public}d", ret);
        OH_AVBuffer_Destroy(buffer);
        return fileDuration;
    }
    
    // demux until EOS
    while (true) {
        demuxer_->ReadSample(videoTrackId, buffer, attr);
        if (attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            AVCODEC_SAMPLE_LOGI("the video duration is %{public}lld, while the file duration is %{public}lld",
                endPts + frameDuration - startPts, fileDuration);
            break;
        }
        OH_AVFormat *avFormat = OH_AVBuffer_GetParameter(buffer);
        OH_AVFormat_GetLongValue(avFormat, OH_MD_KEY_BUFFER_DURATION, &frameDuration);
        OH_AVFormat_Destroy(avFormat);
        endPts = attr.pts;
    }
    
    ret = demuxer_->Seek(0, SEEK_MODE_PREVIOUS_SYNC);
    CHECK_AND_LOGW(ret == 0, "seek failed, ret = %{public}d", ret);
    
    OH_AVBuffer_Destroy(buffer);
    if (endPts == 0) {
        AVCODEC_SAMPLE_LOGE("Invalid pts. startPts is %{public}lld, endPts is %{public}lld", startPts, endPts);
        return 0;
    }
    return endPts + frameDuration - startPts;
}

int32_t AVDecoderEngineImpl::Start()
{
    std::unique_lock<std::mutex> lock(mutex_);
    int32_t ret;
    if (isFlushedFlag == false && !isPaused_.load()) {
        CHECK_AND_RETURN_RET_LOG(!isStarted_, AV_ERROR, "Already started.");
    }
    if (videoDecContext_) {
        if (sampleInfo_.enableVPEFlag) {
            metadataGenerationVPE_->StartProcessing();
            colorSpaceConversionVPE_->StartProcessing();
        }
        ret = videoDecoder_->Start();
        if (ret != AV_OK) {
            AVCODEC_SAMPLE_LOGE("Video Decoder start failed");
            lock.unlock();
            StartRelease();
            VPERelease();
            return AV_ERROR;
        }
        isStarted_ = true;
        if (videoDecInputThread_ == nullptr && videoDecOutputThread_ == nullptr) {
            videoDecInputThread_ = std::make_unique<std::thread>(&AVDecoderEngineImpl::VideoDecInputThread, this);
            videoDecOutputThread_ = std::make_unique<std::thread>(&AVDecoderEngineImpl::VideoDecOutputThread, this);
        }
        if (videoDecInputThread_ == nullptr || videoDecOutputThread_ == nullptr) {
            AVCODEC_SAMPLE_LOGE("Create thread failed");
            lock.unlock();
            StartRelease();
            VPERelease();
            return AV_ERROR;
        }
    }
    if (audioDecContext_ && !isAudioUnselected_) {
        ret = audioDecoder_->Start();
        if (ret != AV_OK) {
            AVCODEC_SAMPLE_LOGE("Audio Decoder start failed");
            lock.unlock();
            StartRelease();
            VPERelease();
            return AV_ERROR;
        }
        isStarted_ = true;
        if (audioDecInputThread_ == nullptr && audioDecOutputThread_ == nullptr) {
            audioDecInputThread_ = std::make_unique<std::thread>(&AVDecoderEngineImpl::AudioDecInputThread, this);
            audioDecOutputThread_ = std::make_unique<std::thread>(&AVDecoderEngineImpl::AudioDecOutputThread, this);
        }
        if (audioDecInputThread_ == nullptr || audioDecOutputThread_ == nullptr) {
            AVCODEC_SAMPLE_LOGE("Create thread failed");
            lock.unlock();
            StartRelease();
            VPERelease();
            return AV_ERROR;
        }
    }

    {
        isPaused_.store(false);
        std::unique_lock<std::mutex> restartLock(decodingFinishMutex_);
        isRestarted_.store(true);
        decodingFinishCond_.notify_all();
    }
    if (audioRenderer_) {
        if (isAudioMute_) {
            OH_AudioRenderer_SetVolume(audioRenderer_.get(), 0.0f);
        } else {
            OH_AudioRenderer_SetVolume(audioRenderer_.get(), 1.0f);
        }
        OH_AudioRenderer_Start(audioRenderer_.get());
    }
    AVCODEC_SAMPLE_LOGI("Succeed");
    if (auto cb = cb_.lock()) {
        cb->OnDecodeStatus(CodecStatus::RUNNING);
    }
    isFlushedFlag = false;
    doneCond_.notify_all();
    return AV_OK;
}

int32_t AVDecoderEngineImpl::Pause()
{
    {
        std::unique_lock<std::mutex> restartLock(decodingFinishMutex_);
        isRestarted_.store(false);
    }
    isPaused_.store(true);
    if (audioDecContext_ && audioRenderer_) {
        OH_AudioRenderer_Pause(audioRenderer_.get());
    }
    return AV_OK;
}

int32_t AVDecoderEngineImpl::Stop()
{
    std::unique_lock<std::mutex> lock(decodingFinishMutex_);
    isStarted_ = false;
    lock.unlock();
    if (videoDecContext_) {
        videoDecContext_->inputCond.notify_all();
        videoDecContext_->outputCond.notify_all();
        decodingFinishCond_.notify_all();
    }
    if (audioDecContext_) {
        audioDecContext_->inputCond.notify_all();
        audioDecContext_->outputCond.notify_all();
        audioDecContext_->renderCond.notify_all();
        decodingFinishCond_.notify_all();
    }
    return AV_OK;
}

int32_t AVDecoderEngineImpl::Seek(int64_t millisecond, OH_AVSeekMode mode)
{
    std::lock_guard<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(demuxer_ != nullptr && videoDecoder_ != nullptr && audioDecoder_ != nullptr, AV_ERROR,
                             "demuxer_ videoDecoder_ audioDecoder_ is nullptr");
    // clear queue
    int32_t ret;
    if (videoDecContext_) {
        ret = videoDecoder_->Flush();
        CHECK_AND_LOGW(ret == AV_OK, "video flush failed, ret:%{public}d", ret);
        std::lock_guard<std::mutex> videoInputLock(videoDecContext_->inputMutex);
        std::lock_guard<std::mutex> videoOutputLock(videoDecContext_->outputMutex);
        std::queue<CodecBufferInfo>().swap(videoDecContext_->inputBufferInfoQueue);
        std::queue<CodecBufferInfo>().swap(videoDecContext_->outputBufferInfoQueue);
    }
    
    if (audioDecContext_) {
        ret = audioDecoder_->Flush();
        CHECK_AND_LOGW(ret == AV_OK, "audio flush failed, ret:%{public}d", ret);
        std::lock_guard<std::mutex> audioInputLock(audioDecContext_->inputMutex);
        std::lock_guard<std::mutex> audioOutputLock(audioDecContext_->outputMutex);
        std::queue<CodecBufferInfo>().swap(audioDecContext_->inputBufferInfoQueue);
        std::queue<CodecBufferInfo>().swap(audioDecContext_->outputBufferInfoQueue);
        if (audioRenderer_) {
            OH_AudioRenderer_Pause(audioRenderer_.get());
            OH_AudioRenderer_Flush(audioRenderer_.get());
        }
        std::queue<unsigned char>().swap(audioDecContext_->renderQueue);
    }
    
    ret = demuxer_->Seek(millisecond, mode);
    CHECK_AND_RETURN_RET_LOG(ret == AV_OK, AV_ERROR, "Seek failed, ret:%{public}d", ret);

    if (auto cb = cb_.lock() ) {
        cb->OnDecodeStatus(CodecStatus::INITIALIZED);
    }
    isFlushedFlag = true;
    return AV_OK;
}

int32_t AVDecoderEngineImpl::SetPlayDuration(int64_t duration)
{
    avDataDuration_.store(static_cast<double>(duration));
    return AV_OK;
}

int32_t AVDecoderEngineImpl::SetVideoOutputWindow(OHNativeWindow* surfaceWindow)
{
    sampleInfo_.window = surfaceWindow;
//    if (videoDecoder_ != nullptr) {
//        videoDecoder_->SetOutputSurface(surfaceWindow);
//    }
    return AV_OK;
}

int32_t AVDecoderEngineImpl::SetAudioOutputBufferQueue(std::weak_ptr<AudioDecoderCallback> callback)
{
    CHECK_AND_RETURN_RET_LOG(isPreview_, AV_ERROR, "audio edit has already been started.");
    audioDataCb_ = callback;
    if (demuxer_) {
        SamplingRateChangeCallback(sampleInfo_.audioSampleRate);
    }
    if (!audioDecContext_) {
        isPreview_.store(false);
        return AV_OK;
    }
    if (audioRenderer_) {
        OH_AudioRenderer_Pause(audioRenderer_.get());
        OH_AudioRenderer_Stop(audioRenderer_.get());
        audioRenderer_.reset();
    }
    if (audioDecoder_) {
        audioDecoder_->Flush();
    }
    {
        std::unique_lock<std::mutex> lock(audioDecContext_->outputMutex);
        std::queue<CodecBufferInfo>().swap(audioDecContext_->outputBufferInfoQueue);
    }
    {
        std::unique_lock<std::mutex> lock(audioDecContext_->inputMutex);
        std::queue<CodecBufferInfo>().swap(audioDecContext_->inputBufferInfoQueue);
    }
    isPreview_.store(false);
    {
        std::unique_lock<std::mutex> lockRender(audioDecContext_->renderMutex);
        std::queue<unsigned char>().swap(audioDecContext_->renderQueue);
        audioDecContext_->renderCond.notify_all();
    }
    if (isStarted_ && audioDecoder_ && !isAudioUnselected_) {
        audioDecoder_->Start();
    }

    return AV_OK;
}

OH_AVFormat* AVDecoderEngineImpl::GetVideoFormat()
{
    if (!videoFormat_ && demuxer_) {
        videoFormat_ = demuxer_->GetVideoFormat();
    }
    const char *dumpInfo = OH_AVFormat_DumpInfo(videoFormat_);
    return videoFormat_;
}

OH_AVFormat* AVDecoderEngineImpl::GetAudioFormat()
{
    OH_AVFormat *format = demuxer_->GetAudioFormat();
    return format;
}

int32_t AVDecoderEngineImpl::SetHighPerformance(bool enableFlag)
{
    highPerformanceFlag_ = true;
    return AV_OK;
}

int32_t AVDecoderEngineImpl::AudioUnselect(bool unselectFlag)
{
    isAudioUnselected_.store(unselectFlag);
    return AV_OK;
}

int32_t AVDecoderEngineImpl::AudioMute(bool muteFlag)
{
    isAudioMute_.store(muteFlag);
    if (audioRenderer_) {
        if (muteFlag) {
            OH_AudioRenderer_SetVolume(audioRenderer_.get(), 0.0f);
        } else {
            OH_AudioRenderer_SetVolume(audioRenderer_.get(), 1.0f);
        }
    }
    return AV_OK;
}

bool AVDecoderEngineImpl::IsAudioTrackExisted()
{
    return isAudioTrackExisted_;
}

void AVDecoderEngineImpl::FillAudioDataToRenderer(CodecBufferInfo &bufferInfo)
{
    uint8_t *source = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
    CHECK_AND_RETURN_LOG(source, "source is nullptr");
    // Put the decoded PCM data into the render queue
    for (int i = 0; i < bufferInfo.attr.size; i++) {
        audioDecContext_->renderQueue.push(*(source + i));
    }
}

std::shared_ptr<PcmData> AVDecoderEngineImpl::FillAudioDataToEncoder(CodecBufferInfo &bufferInfo)
{
    double duration = static_cast<double>(bufferInfo.attr.size * MS_IN_SECOND) /
            sampleInfo_.audioChannelCount / sizeof(int16_t) / sampleInfo_.audioSampleRate;
    if (isDecodingAudioOnly_) {
        if (musicDecodingPosition_ + duration > avDataDuration_.load()) {
            if (auto cb = audioDataCb_.lock()) {
                cb->OnMusicDecodingFinish();
            }
            musicDecodingPosition_ = 0;
            AVCODEC_SAMPLE_LOGI("music decoding finish");
            return nullptr;
        }
        musicDecodingPosition_ += duration;
    } else {
        if (avDecodingPosition_ + duration > avDataDuration_.load()) {
            if (auto cb = audioDataCb_.lock()) {
                cb->OnAVDecodingFinish();
            }
            avDecodingPosition_ = 0;
            AVCODEC_SAMPLE_LOGI("av decoding finish");
            return nullptr;
        }
        avDecodingPosition_ += duration;
    }

    uint8_t *source = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
    // Put the decoded PCM data into the pcm buffer queue
    std::shared_ptr<PcmData> pcmData = std::make_shared<PcmData>();

    if (sampleInfo_.audioChannelCount == STEREO) {
        // for stereo case
        pcmData->data.reserve(bufferInfo.attr.size * STEREO / sampleInfo_.audioChannelCount);
        pcmData->data.assign(source, source + bufferInfo.attr.size);
    } else if (sampleInfo_.audioChannelCount < STEREO) {
        // for mono case
        pcmData->data.resize(bufferInfo.attr.size * STEREO / sampleInfo_.audioChannelCount);
        for (int32_t i = 0; i < bufferInfo.attr.size / sampleInfo_.audioChannelCount / sizeof(int16_t); ++i) {
            std::memcpy(pcmData->data.data() + i * STEREO * sizeof(int16_t),
                        source + i * sampleInfo_.audioChannelCount * sizeof(int16_t),
                        sizeof(int16_t));
            std::memcpy(pcmData->data.data() + i * STEREO * sizeof(int16_t) + sizeof(int16_t),
                        source + i * sampleInfo_.audioChannelCount * sizeof(int16_t),
                        sizeof(int16_t));
        }
    } else if (sampleInfo_.audioChannelCount > STEREO) {
        // for multichannel case
        pcmData->data.resize(bufferInfo.attr.size * STEREO / sampleInfo_.audioChannelCount);
        for (int32_t i = 0; i < bufferInfo.attr.size / sampleInfo_.audioChannelCount / sizeof(int16_t); ++i) {
            std::memcpy(pcmData->data.data() + i * STEREO * sizeof(int16_t),
                source + i * sampleInfo_.audioChannelCount * sizeof(int16_t),
                STEREO * sizeof(int16_t));
        }
    }

    pcmData->dataSize = bufferInfo.attr.size * STEREO / sampleInfo_.audioChannelCount;
    
    return pcmData;
}

void AVDecoderEngineImpl::CheckAndWaitForRestart()
{
    if (isPaused_.load()) {
        std::unique_lock<std::mutex> restartLock(decodingFinishMutex_);
        AVCODEC_SAMPLE_LOGI("pause, wait for continuing");
        decodingFinishCond_.wait(restartLock, [this]() { return isRestarted_.load() || !isStarted_.load(); });
        AVCODEC_SAMPLE_LOGI("Restart, continue running");
    }
}

void AVDecoderEngineImpl::SamplingRateChangeCallback(const int32_t samplingRate)
{
    if (auto cb = audioDataCb_.lock()) {
        if (isDecodingAudioOnly_) {
            cb->OnMusicSamplingRateChanged(samplingRate);
        } else {
            cb->OnAVSamplingRateChanged(samplingRate);
        }
    }
}

void AVDecoderEngineImpl::DataReadyCallback(std::shared_ptr<PcmData> pcmData)
{
    if (auto cb = audioDataCb_.lock()) {
        if (isDecodingAudioOnly_) {
            cb->OnMusicDataReady(pcmData);
        } else {
            cb->OnAVDataReady(pcmData);
        }
    }
}

void AVDecoderEngineImpl::OnErrorCallback(CodecStatus status)
{
    if (auto cb = cb_.lock()) {
        cb->OnDecodeStatus(status);
    }
    return;
}

void AVDecoderEngineImpl::OnStreamChanged(OH_AVFormat *format) {
    if (!videoFormat_ && demuxer_) {
        videoFormat_ = demuxer_->GetVideoFormat();
    }
    bool ret = OH_AVFormat_GetIntValue(format, OH_MD_KEY_VIDEO_PIC_WIDTH, &sampleInfo_.videoWidth);
    if (ret) {
        OH_AVFormat_SetIntValue(videoFormat_, OH_MD_KEY_VIDEO_PIC_WIDTH, sampleInfo_.videoWidth);
    }
    OH_AVFormat_GetIntValue(format, OH_MD_KEY_VIDEO_PIC_HEIGHT, &sampleInfo_.videoHeight);
    if (ret) {
        OH_AVFormat_SetIntValue(videoFormat_, OH_MD_KEY_VIDEO_PIC_HEIGHT, sampleInfo_.videoHeight);
    }
    if (sampleInfo_.isHDRVivid || sampleInfo_.enableVPEFlag) {
        OH_AVFormat_SetIntValue(videoFormat_, OH_MD_KEY_RANGE_FLAG, 0);
        OH_AVFormat_SetIntValue(videoFormat_, OH_MD_KEY_COLOR_PRIMARIES, COLOR_PRIMARY_BT709);
        OH_AVFormat_SetIntValue(videoFormat_, OH_MD_KEY_TRANSFER_CHARACTERISTICS, TRANSFER_CHARACTERISTIC_BT709);
        OH_AVFormat_SetIntValue(videoFormat_, OH_MD_KEY_MATRIX_COEFFICIENTS, MATRIX_COEFFICIENT_BT709);
        OH_AVFormat_SetIntValue(videoFormat_, OH_MD_KEY_PROFILE, 0);
        AVCODEC_SAMPLE_LOGI(
            "width:%{public}d,height:%{public}d,rangeFlag:%{public}d,primary:%{public}d,transfer:%{public}d, "
            "matrix:%{public}d",
            sampleInfo_.videoWidth, sampleInfo_.videoHeight, 0, COLOR_PRIMARY_BT709, TRANSFER_CHARACTERISTIC_BT709,
            MATRIX_COEFFICIENT_BT709);
        return;
    }
    ret = OH_AVFormat_GetIntValue(format, OH_MD_KEY_RANGE_FLAG, &sampleInfo_.rangFlag);
    if (ret) {
        OH_AVFormat_SetIntValue(videoFormat_, OH_MD_KEY_RANGE_FLAG, sampleInfo_.rangFlag);
    }
    ret = OH_AVFormat_GetIntValue(format, OH_MD_KEY_COLOR_PRIMARIES, reinterpret_cast<int32_t *>(&sampleInfo_.primary));
    if (ret) {
        OH_AVFormat_SetIntValue(videoFormat_, OH_MD_KEY_COLOR_PRIMARIES, sampleInfo_.primary);
    }
    ret = OH_AVFormat_GetIntValue(format, OH_MD_KEY_TRANSFER_CHARACTERISTICS,
                                  reinterpret_cast<int32_t *>(&sampleInfo_.transfer));
    if (ret) {
        OH_AVFormat_SetIntValue(videoFormat_, OH_MD_KEY_TRANSFER_CHARACTERISTICS, sampleInfo_.transfer);
    }
    ret = OH_AVFormat_GetIntValue(format, OH_MD_KEY_MATRIX_COEFFICIENTS,
                                  reinterpret_cast<int32_t *>(&sampleInfo_.matrix));
    if (ret) {
        OH_AVFormat_SetIntValue(videoFormat_, OH_MD_KEY_MATRIX_COEFFICIENTS, sampleInfo_.matrix);
    }
    AVCODEC_SAMPLE_LOGI(
        "width:%{public}d,height:%{public}d,rangeFlag:%{public}d,primary:%{public}d,transfer:%{public}d, "
        "matrix:%{public}d",
        sampleInfo_.videoWidth, sampleInfo_.videoHeight, sampleInfo_.rangFlag, sampleInfo_.primary,
        sampleInfo_.transfer, sampleInfo_.matrix);
    return;
}

OH_NativeBuffer_TransformType AVDecoderEngineImpl::ConvertRotateToDisplayRotate(int32_t rotation) {
    if (rotation == 90) {
        return NATIVEBUFFER_ROTATE_270;
    } else if (rotation == 180) {
        return NATIVEBUFFER_ROTATE_180;
    } else if (rotation == 270) {
        NATIVEBUFFER_ROTATE_90;
    }
    return NATIVEBUFFER_ROTATE_NONE;
}