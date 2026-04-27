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

#ifndef AVCODECVIDEO_AUDIOENCODER_H
#define AVCODECVIDEO_AUDIOENCODER_H

#include "multimedia/player_framework/native_avcodec_audiocodec.h"
#include "multimedia/player_framework/native_avbuffer_info.h"
#include "multimedia/native_audio_channel_layout.h"
#include "avcodec_info.h"
#include "avcodec_callback.h"
#include "avcodec_error.h"
#include "avcodec_log.h"

class AudioEncoder {
public:
    AudioEncoder() = default;
    ~AudioEncoder();

    int32_t Create(const std::string &codecMime);
    int32_t Config(const SampleInfo &sampleInfo, CodecUserData *codecUserData);
    int32_t Start();
    int32_t PushInputData(CodecBufferInfo &info);
    int32_t FreeOutputData(uint32_t bufferIndex);
    int32_t Stop();
    int32_t Release();
    
private:
    int32_t SetCallback(CodecUserData *codecUserData);
    int32_t Configure(const SampleInfo &sampleInfo);
    
    bool isAVBufferMode_ = false;
    OH_AVCodec *encoder_;
};

#endif // AVCODECVIDEO_AUDIOENCODER_H
