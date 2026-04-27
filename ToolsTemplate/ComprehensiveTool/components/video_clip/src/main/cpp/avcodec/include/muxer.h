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

#ifndef MUXER_H
#define MUXER_H

#include "avcodec_log.h"
#include "avcodec_info.h"
#include "multimedia/player_framework/native_avmuxer.h"
#include <bits/alltypes.h>

class Muxer {
public:
    Muxer() = default;
    ~Muxer();

    int32_t Create(int32_t fd);
    int32_t Config(SampleInfo &sampleInfo);
    int32_t Start();
    int32_t WriteSample(int32_t trackId, OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr);
    int32_t Release();
    int32_t GetVideoTrackId();
    int32_t GetAudioTrackId();

private:
    OH_AVMuxer *muxer_ = nullptr;
    int32_t videoTrackId_ = -1;
    int32_t audioTrackId_ = -1;
    std::mutex writeMutex_;
};

#endif // MUXER_H