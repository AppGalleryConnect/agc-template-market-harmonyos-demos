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

#include "avcodec_callback.h"
#include "avcodec_log.h"
#include "codec_common.h"

namespace {
constexpr int LIMIT_LOGD_FREQUENCY = 50;
}

// Custom write data function
OH_AudioData_Callback_Result SampleCallback::OnWriteDataCallback(OH_AudioRenderer* renderer, void* userData,
    void* audioData, int32_t audioDataSize) {
    (void)renderer;
    (void)audioDataSize;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);

    // Write the data to be played to the buffer by length
    uint8_t *dest = (uint8_t *)audioData;
    size_t index = 0;
    std::unique_lock<std::mutex> lock(codecUserData->outputMutex);
    if (codecUserData->renderQueue.size() < audioDataSize) {
        codecUserData->renderCond.notify_all();
        return AUDIO_DATA_CALLBACK_RESULT_INVALID;
    }
    // Retrieve the length of the data to be played from the queue
    while (!codecUserData->renderQueue.empty() && index < audioDataSize) {
        dest[index++] = codecUserData->renderQueue.front();
        codecUserData->renderQueue.pop();
    }
    AVCODEC_SAMPLE_LOGD("render BufferLength:%{public}d Out buffer count: %{public}u, renderQueue.size: %{public}u "
                        "renderReadSize: %{public}u",
                        audioDataSize, codecUserData->outputFrameCount, (unsigned int)codecUserData->renderQueue.size(),
                        (unsigned int)index);
    if (codecUserData->renderQueue.size() < audioDataSize) {
        codecUserData->renderCond.notify_all();
    }
    return AUDIO_DATA_CALLBACK_RESULT_VALID;
}

// Custom write data function
int32_t SampleCallback::OnRenderWriteData(OH_AudioRenderer *renderer, void *userData, void *buffer, int32_t length) {
    (void)renderer;
    (void)length;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);

    // Write the data to be played to the buffer by length
    uint8_t *dest = (uint8_t *)buffer;
    size_t index = 0;
    std::unique_lock<std::mutex> lock(codecUserData->outputMutex);
    // Retrieve the length of the data to be played from the queue
    while (!codecUserData->renderQueue.empty() && index < length) {
        dest[index++] = codecUserData->renderQueue.front();
        codecUserData->renderQueue.pop();
    }
    AVCODEC_SAMPLE_LOGD("render BufferLength:%{public}d Out buffer count: %{public}u, renderQueue.size: %{public}u "
                        "renderReadSize: %{public}u",
                        length, codecUserData->outputFrameCount, (unsigned int)codecUserData->renderQueue.size(),
                        (unsigned int)index);
    if (codecUserData->renderQueue.size() < length) {
        codecUserData->renderCond.notify_all();
    }
    return 0;
}
// Customize the audio stream event function
int32_t SampleCallback::OnRenderStreamEvent(OH_AudioRenderer *renderer, void *userData, OH_AudioStream_Event event) {
    (void)renderer;
    (void)userData;
    (void)event;
    // Update the player status and interface based on the audio stream event information represented by the event
    return 0;
}
// Customize the audio interrupt event function
int32_t SampleCallback::OnRenderInterruptEvent(OH_AudioRenderer *renderer, void *userData,
                                               OH_AudioInterrupt_ForceType type, OH_AudioInterrupt_Hint hint) {
    (void)renderer;
    (void)userData;
    (void)type;
    (void)hint;
    // Update the player status and interface based on the audio interrupt information indicated by type and hint
    return 0;
}
// Custom exception callback functions
int32_t SampleCallback::OnRenderError(OH_AudioRenderer *renderer, void *userData, OH_AudioStream_Result error) {
    (void)renderer;
    (void)userData;
    (void)error;
    AVCODEC_SAMPLE_LOGE("OnRenderError");
    // Handle the audio exception information based on the error message
    return 0;
}

void SampleCallback::OnCodecError(OH_AVCodec *codec, int32_t errorCode, void *userData) {
    (void)codec;
    (void)errorCode;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    CHECK_AND_RETURN_LOG(codecUserData != nullptr, "codecUserData is nullptr");
    CHECK_AND_RETURN_LOG(codecUserData->errorCallback_ != nullptr, "errorCallback_ is nullptr");
    codecUserData->errorCallback_(CodecStatus::ERROR);
    AVCODEC_SAMPLE_LOGI("On codec error, error code: %{public}d", errorCode);
}

void SampleCallback::OnCodecFormatChange(OH_AVCodec *codec, OH_AVFormat *format, void *userData) {
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    CHECK_AND_RETURN_LOG(codecUserData != nullptr, "codecUserData is nullptr");
    CHECK_AND_RETURN_LOG(codecUserData->streamChangedCallback_ != nullptr, "errorCallback_ is nullptr");
    codecUserData->streamChangedCallback_(format);
    AVCODEC_SAMPLE_LOGI("On codec format change");
}

void SampleCallback::OnNeedInputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData) {
    if (userData == nullptr) {
        return;
    }
    (void)codec;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    std::unique_lock<std::mutex> lock(codecUserData->inputMutex);
    codecUserData->inputBufferInfoQueue.emplace(index, buffer);
    codecUserData->inputCond.notify_all();
}

void SampleCallback::OnNewOutputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData) {
    if (userData == nullptr) {
        return;
    }
    (void)codec;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    std::unique_lock<std::mutex> lock(codecUserData->outputMutex);
    codecUserData->outputBufferInfoQueue.emplace(index, buffer);
    codecUserData->outputCond.notify_all();
}