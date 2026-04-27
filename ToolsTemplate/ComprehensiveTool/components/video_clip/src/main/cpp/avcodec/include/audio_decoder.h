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

#ifndef AUDIODECODER_H
#define AUDIODECODER_H

#include "multimedia/player_framework/native_avcodec_audiocodec.h"
#include "multimedia/player_framework/native_avbuffer_info.h"
#include "avcodec_callback.h"
#include "avcodec_log.h"

class AudioDecoder {
public:
    AudioDecoder() = default;
    ~AudioDecoder();

    int32_t Create(const std::string &codecMime);
    int32_t Config(const SampleInfo &sampleInfo, CodecUserData *codecUserData);
    int32_t Start();
    int32_t PushInputBuffer(CodecBufferInfo &info);
    int32_t FreeOutputBuffer(uint32_t bufferIndex, bool render);
    int32_t Release();
    int32_t Flush();
    
private:
    int32_t SetCallback(CodecUserData *codecUserData);
    int32_t Configure(const SampleInfo &sampleInfo);
    
    bool isAVBufferMode_ = false;
    OH_AVCodec *decoder_;
};
#endif // AUDIODECODER_H