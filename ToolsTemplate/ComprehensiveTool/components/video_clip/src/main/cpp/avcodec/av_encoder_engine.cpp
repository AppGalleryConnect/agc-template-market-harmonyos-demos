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
#include "av_encoder_engine.h"
#include "codec_common.h"
#include <cinttypes>

#undef LOG_TAG
#define LOG_TAG "videoEditorEncoder"

namespace {
using namespace std::chrono_literals;
constexpr int64_t MICROSECOND = 1000000;
constexpr int32_t INPUT_FRAME_BYTES = 2 * 1024;
constexpr int32_t DEFAULT_PCM_BUFFER_QUEUE_CAPACITY = 5;
} // namespace

std::shared_ptr<IAVEncoderEngine> IAVEncoderEngine::Create(const AVEncodeParam& encodeParam,
    std::weak_ptr<AVEncodeCallback> cb)
{
    std::shared_ptr<IAVEncoderEngine> engine = std::make_shared<AVEncoderEngine>(encodeParam, cb);

    return engine;
}

AVEncoderEngine::AVEncoderEngine(const AVEncodeParam& encodeParam, std::weak_ptr<AVEncodeCallback> cb)
{
    sampleInfo_.outputFd = encodeParam.muxerParam.targetFileFd;
    sampleInfo_.rotation = encodeParam.muxerParam.rotation;
    cb_ = cb;
    sampleInfo_.videoCodecMime = "video/hevc";
    sampleInfo_.frameRate = 30;
    sampleInfo_.videoWidth = 1920;
    sampleInfo_.videoHeight = 1080;
    sampleInfo_.bitrate = 800000;
    sampleInfo_.bitrateMode = VBR;
    sampleInfo_.hevcProfile = 0;
    sampleInfo_.audioCodecMime = OH_AVCODEC_MIMETYPE_AUDIO_AAC;
    sampleInfo_.audioSampleForamt = OH_BitsPerSample::SAMPLE_S16LE;
    sampleInfo_.audioSampleRate = 44100;
    sampleInfo_.audioChannelCount = 2;
    sampleInfo_.audioBitRate = 96000;
    sampleInfo_.audioChannelLayout = OH_AudioChannelLayout::CH_LAYOUT_STEREO;
    sampleInfo_.audioMaxInputSize = sampleInfo_.audioSampleRate * 0.02 * sampleInfo_.audioChannelCount * sizeof(short);
    SetAVFormat(encodeParam);
}

AVEncoderEngine::~AVEncoderEngine()
{
    StartRelease();
    WaitForDone();
}

int32_t AVEncoderEngine::Init()
{
    std::lock_guard<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(videoEncoder_ == nullptr && muxer_ == nullptr, AVCODEC_SAMPLE_ERR_ERROR,
                             "Already started.");
    // Audio Capturer Init
    audioEncoder_ = std::make_unique<AudioEncoder>();

    videoEncoder_ = std::make_unique<VideoEncoder>();
    muxer_ = std::make_unique<Muxer>();

    int32_t ret = muxer_->Create(sampleInfo_.outputFd);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create muxer with fd(%{public}d) failed",
                             sampleInfo_.outputFd);
    ret = muxer_->Config(sampleInfo_);

    ret = CreateAudioEncoder();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create audio encoder failed");

    ret = CreateVideoEncoder();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create video encoder failed");
    releaseThread_ = nullptr;
    AVCODEC_SAMPLE_LOGI("Succeed");

    pcmBufferQueue_ = std::make_shared<PcmBufferQueue>(DEFAULT_PCM_BUFFER_QUEUE_CAPACITY);

    return AV_OK;
}

int32_t AVEncoderEngine::Start()
{
    std::lock_guard<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(encContext_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(videoEncoder_ != nullptr && muxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR,
                             "Already started.");
    int32_t ret = muxer_->Start();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Muxer start failed");
    ret = videoEncoder_->Start();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder start failed");

    isStarted_ = true;
    encOutputThread_ = std::make_unique<std::thread>(&AVEncoderEngine::EncOutputThread, this);
    if (encOutputThread_ == nullptr) {
        AVCODEC_SAMPLE_LOGE("Create thread failed");
        StartRelease();
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    if (audioEncContext_) {
        ret = audioEncoder_->Start();
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Audio Encoder start failed");
        isStarted_ = true;
        audioEncInputThread_ = std::make_unique<std::thread>(&AVEncoderEngine::AudioEncInputThread, this);
        audioEncOutputThread_ = std::make_unique<std::thread>(&AVEncoderEngine::AudioEncOutputThread, this);
        if (audioEncInputThread_ == nullptr || audioEncOutputThread_ == nullptr) {
            AVCODEC_SAMPLE_LOGE("Create thread failed");
            StartRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }

        // 清空播放缓存队列
        if (audioEncContext_ != nullptr) {
            audioEncContext_->ClearCache();
        }
    }

    AVCODEC_SAMPLE_LOGI("Succeed");

    return AV_OK;
}

int32_t AVEncoderEngine::Stop()
{
    return AV_OK;
}

int32_t AVEncoderEngine::SendEOS()
{
    CHECK_AND_RETURN_RET_LOG(videoEncoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "VideoEncoder is nullptr.");
    int32_t ret = videoEncoder_->NotifyEndOfStream();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder notifyEndOfStream failed");
    return WaitForDone();
}

OHNativeWindow *AVEncoderEngine::GetVideoInputWindow() 
{
    return sampleInfo_.window; 
}

std::shared_ptr<PcmBufferQueue> AVEncoderEngine::GetAudioInputBufferQueue() const
{
    return pcmBufferQueue_;
}

void AVEncoderEngine::EncOutputThread() {
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        std::unique_lock<std::mutex> lock(encContext_->outputMutex);
        bool condRet = encContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !encContext_->outputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!encContext_->outputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = encContext_->outputBufferInfoQueue.front();
        encContext_->outputBufferInfoQueue.pop();
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
        lock.unlock();
        //  codec_data is not considered a frame.
        if ((bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_CODEC_DATA) && isFirstCodecData_) {
            bufferInfo.attr.pts = 0;
            isFirstCodecData_.store(false);
        }
        if ((bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_SYNC_FRAME) ||
            (bufferInfo.attr.flags == AVCODEC_BUFFER_FLAGS_NONE)) {
            if (!isFirstSyncFrame_) {
                bufferInfo.attr.pts = encContext_->outputFrameCount * MICROSECOND / sampleInfo_.frameRate;
            }
            encContext_->outputFrameCount++;
            isFirstSyncFrame_.store(false);
        }
        AVCODEC_SAMPLE_LOGD(
            "Video encoder out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
            encContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags, bufferInfo.attr.pts);

        muxer_->WriteSample(muxer_->GetVideoTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                            bufferInfo.attr);
        int32_t ret = videoEncoder_->FreeOutputBuffer(bufferInfo.bufferIndex);
        if (auto cb = cb_.lock()) {
            cb->OnEncodeFrame(bufferInfo.attr.pts);
        }
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Encoder output thread out");
    }
    AVCODEC_SAMPLE_LOGI("Exit, frame count: %{public}u", encContext_->outputFrameCount);
    StartRelease();
}

void AVEncoderEngine::StartRelease() {
    if (releaseThread_ == nullptr) {
        AVCODEC_SAMPLE_LOGI("Start release CodecTest");
        isReleasedDone_.store(false);
        releaseThread_ = std::make_unique<std::thread>(&AVEncoderEngine::Release, this);
    }
}

void AVEncoderEngine::Release() {
    std::lock_guard<std::mutex> lock(mutex_);
    isStarted_ = false;
    if (encOutputThread_ && encOutputThread_->joinable()) {
        encOutputThread_->join();
        encOutputThread_.reset();
    }
    if (audioEncInputThread_ && audioEncInputThread_->joinable()) {
        audioEncContext_->inputCond.notify_all();
        audioEncInputThread_->join();
        audioEncInputThread_.reset();
    }
    if (audioEncOutputThread_ && audioEncOutputThread_->joinable()) {
        audioEncContext_->outputCond.notify_all();
        audioEncOutputThread_->join();
        audioEncOutputThread_.reset();
    }
    if (muxer_ != nullptr) {
        muxer_->Release();
        muxer_.reset();
        AVCODEC_SAMPLE_LOGI("Muxer release successful");
    }
    if (videoEncoder_ != nullptr) {
        videoEncoder_->Stop();
        if (sampleInfo_.window != nullptr) {
            OH_NativeWindow_DestroyNativeWindow(sampleInfo_.window);
            sampleInfo_.window = nullptr;
        }
        videoEncoder_->Release();
        videoEncoder_.reset();
        AVCODEC_SAMPLE_LOGI("Video encoder release successful");
    }
    if (audioEncoder_ != nullptr) {
        audioEncoder_->Stop();
        audioEncoder_->Release();
        audioEncoder_.reset();
        AVCODEC_SAMPLE_LOGI("Audio encoder release successful");
    }
    pcmBufferQueue_.reset();
    if (audioEncContext_ != nullptr) {
        delete audioEncContext_;
        audioEncContext_ = nullptr;
    }
    if (encContext_ != nullptr) {
        delete encContext_;
        encContext_ = nullptr;
    }
    isReleasedDone_.store(true);
    doneCond_.notify_all();
    AVCODEC_SAMPLE_LOGI("Succeed");
}

int32_t AVEncoderEngine::WaitForDone() {
    AVCODEC_SAMPLE_LOGI("Wait called");
    std::unique_lock<std::mutex> lock(mutex_);
    doneCond_.wait(lock, [this]() { return isReleasedDone_.load(); });
    if (releaseThread_ && releaseThread_->joinable()) {
        releaseThread_->join();
        releaseThread_.reset();
    }
    AVCODEC_SAMPLE_LOGI("Done");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AVEncoderEngine::CreateVideoEncoder() {
    int32_t ret = videoEncoder_->Create(sampleInfo_.videoCodecMime);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create video encoder failed");

    encContext_ = new CodecUserData;
    ret = videoEncoder_->Config(sampleInfo_, encContext_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder config failed");

    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AVEncoderEngine::CreateAudioEncoder() {
    int32_t ret = audioEncoder_->Create(sampleInfo_.audioCodecMime);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create audio encoder(%{public}s) failed",
                             sampleInfo_.audioCodecMime.c_str());
    AVCODEC_SAMPLE_LOGI("Create audio encoder(%{public}s)", sampleInfo_.audioCodecMime.c_str());

    audioEncContext_ = new CodecUserData;
    ret = audioEncoder_->Config(sampleInfo_, audioEncContext_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder config failed");

    return AVCODEC_SAMPLE_ERR_OK;
}

void AVEncoderEngine::AudioEncInputThread() {
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Encoder input thread out");
        std::unique_lock<std::mutex> lock(audioEncContext_->inputMutex);
        bool condRet = audioEncContext_->inputCond.wait_for(lock, 5s, [this]() {
            return !isStarted_ || !audioEncContext_->inputBufferInfoQueue.empty();
        });

        CHECK_AND_CONTINUE_LOG(!audioEncContext_->inputBufferInfoQueue.empty(),
            "Audio Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = audioEncContext_->inputBufferInfoQueue.front();
        audioEncContext_->inputBufferInfoQueue.pop();
        audioEncContext_->inputFrameCount++;

        if (!FillAudioData(bufferInfo)) {
            isAudioEncodingFinished_.store(true);
            break;
        }
        lock.unlock();

        if (isFirstFrame_) {
            bufferInfo.attr.flags = AVCODEC_BUFFER_FLAGS_CODEC_DATA;
            isFirstFrame_ = false;
        } else {
            bufferInfo.attr.flags = AVCODEC_BUFFER_FLAGS_NONE;
        }
        int32_t ret = audioEncoder_->PushInputData(bufferInfo);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Push data failed, thread out");
    }
}

void AVEncoderEngine::AudioEncOutputThread() {
    bool isReleaseNeeded = true;
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        if (isAudioEncodingFinished_) {
            DrainAudioData();
            isReleaseNeeded = false;
            AVCODEC_SAMPLE_LOGI("audio decoding finished, no need to release, thread out");
            break;
        }
        std::unique_lock<std::mutex> lock(audioEncContext_->outputMutex);
        bool condRet = audioEncContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioEncContext_->outputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!audioEncContext_->outputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = audioEncContext_->outputBufferInfoQueue.front();
        audioEncContext_->outputBufferInfoQueue.pop();
        audioEncContext_->outputFrameCount++;
        AVCODEC_SAMPLE_LOGD(
            "Audio Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
            audioEncContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags, bufferInfo.attr.pts);
//        lock.unlock();
        muxer_->WriteSample(muxer_->GetAudioTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                            bufferInfo.attr);
        int32_t ret = audioEncoder_->FreeOutputData(bufferInfo.bufferIndex);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Encoder output thread out");
    }
    AVCODEC_SAMPLE_LOGI("Exit, frame count: %{public}u", audioEncContext_->inputFrameCount);
    if (isReleaseNeeded) {
        StartRelease();
    }
}

bool AVEncoderEngine::FillAudioData(CodecBufferInfo &bufferInfo)
{
    uint8_t *inputBufferAddr = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
    std::shared_ptr<PcmData> pcmData = pcmBufferQueue_->Dequeue();
    CHECK_AND_RETURN_RET_LOG(pcmData, false, "deque buffer timeout");
    CHECK_AND_RETURN_RET_LOG(pcmData->flags == 0, false, "audio decoding finished");
    std::memcpy(inputBufferAddr, pcmData->data.data(), pcmData->dataSize);
    bufferInfo.attr.size = pcmData->dataSize;
    return true;
}

void AVEncoderEngine::DrainAudioData()
{
    std::unique_lock<std::mutex> lock(audioEncContext_->outputMutex);
    while (!audioEncContext_->outputBufferInfoQueue.empty()) {
        CodecBufferInfo bufferInfo = audioEncContext_->outputBufferInfoQueue.front();
        audioEncContext_->outputBufferInfoQueue.pop();
        audioEncContext_->outputFrameCount++;
        AVCODEC_SAMPLE_LOGD(
            "Audio Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
            audioEncContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags, bufferInfo.attr.pts);

        muxer_->WriteSample(muxer_->GetAudioTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
            bufferInfo.attr);
        int32_t ret = audioEncoder_->FreeOutputData(bufferInfo.bufferIndex);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Encoder output thread out");
    }
}

void AVEncoderEngine::SetAVFormat(const AVEncodeParam &encodeParam) 
{
    // get video format
    const char *dumpInfo = OH_AVFormat_DumpInfo(encodeParam.videoTrunkFormat);
    AVCODEC_SAMPLE_LOGI("GetVideoEncoderFormat: %{public}s", dumpInfo);
    OH_AVFormat_GetIntValue(encodeParam.videoTrunkFormat, OH_MD_KEY_WIDTH, &sampleInfo_.videoWidth);
    OH_AVFormat_GetIntValue(encodeParam.videoTrunkFormat, OH_MD_KEY_HEIGHT, &sampleInfo_.videoHeight);
    OH_AVFormat_GetDoubleValue(encodeParam.videoTrunkFormat, OH_MD_KEY_FRAME_RATE, &sampleInfo_.frameRate);
    OH_AVFormat_GetLongValue(encodeParam.videoTrunkFormat, OH_MD_KEY_BITRATE, &sampleInfo_.bitrate);
    char *videoCodecMime;

    bool ret = OH_AVFormat_GetStringValue(encodeParam.videoTrunkFormat, OH_MD_KEY_CODEC_MIME,
                                          const_cast<char const **>(&videoCodecMime));
    if (ret) {
        sampleInfo_.videoCodecMime = videoCodecMime;
    }
    OH_AVFormat_GetIntValue(encodeParam.videoTrunkFormat, OH_MD_KEY_PROFILE, &sampleInfo_.hevcProfile);
    // get audio format
    OH_AVFormat_GetIntValue(encodeParam.audioTrunkFormat, OH_MD_KEY_AUDIO_SAMPLE_FORMAT,
                            &sampleInfo_.audioSampleForamt);
    OH_AVFormat_GetIntValue(encodeParam.audioTrunkFormat, OH_MD_KEY_AUD_CHANNEL_COUNT, &sampleInfo_.audioChannelCount);
    OH_AVFormat_GetLongValue(encodeParam.audioTrunkFormat, OH_MD_KEY_CHANNEL_LAYOUT, &sampleInfo_.audioChannelLayout);
    OH_AVFormat_GetIntValue(encodeParam.audioTrunkFormat, OH_MD_KEY_AUD_SAMPLE_RATE, &sampleInfo_.audioSampleRate);
    OH_AVFormat_GetLongValue(encodeParam.audioTrunkFormat, OH_MD_KEY_BITRATE, &sampleInfo_.audioBitRate);
    char *audioCodecMime;
    ret = OH_AVFormat_GetStringValue(encodeParam.audioTrunkFormat, OH_MD_KEY_CODEC_MIME,
                               const_cast<char const **>(&audioCodecMime));
    if (ret) {
        sampleInfo_.audioCodecMime = audioCodecMime;
    }
    uint8_t *codecConfig = nullptr;
    OH_AVFormat_GetBuffer(encodeParam.audioTrunkFormat, OH_MD_KEY_CODEC_CONFIG, &codecConfig,
                          &sampleInfo_.codecConfigLen);
    if (sampleInfo_.codecConfigLen > 0 && sampleInfo_.codecConfigLen < sizeof(sampleInfo_.codecConfig)) {
        memcpy(sampleInfo_.codecConfig, codecConfig, sampleInfo_.codecConfigLen);
        AVCODEC_SAMPLE_LOGI(
            "codecConfig:%{public}p, len:%{public}i, 0:0x%{public}02x 1:0x:%{public}02x, bufLen:%{public}u",
            sampleInfo_.codecConfig, (int)sampleInfo_.codecConfigLen, sampleInfo_.codecConfig[0],
            sampleInfo_.codecConfig[1], sizeof(sampleInfo_.codecConfig));
    }
    OH_AVFormat_GetIntValue(encodeParam.audioTrunkFormat, OH_MD_KEY_AAC_IS_ADTS, &sampleInfo_.aacAdts);
    sampleInfo_.audioMaxInputSize = sampleInfo_.audioSampleRate * 0.02 * sampleInfo_.audioChannelCount * sizeof(short);
    return;
}