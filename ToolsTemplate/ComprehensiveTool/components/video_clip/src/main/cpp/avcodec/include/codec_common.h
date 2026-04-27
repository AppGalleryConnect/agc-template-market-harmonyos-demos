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

#ifndef OH_VEF_CODEC_COMMON_H
#define OH_VEF_CODEC_COMMON_H
#include <vector>

enum class CodecType : uint32_t { VIDEO = 0, AUDIO };
enum class CodecStatus : uint32_t { INITIALIZED = 0, RUNNING, END_OF_STREAM, ERROR };
enum AVError : int32_t {
    AV_OK = 0,
    AV_ERROR = -1,
};

struct PcmData {
    std::vector<uint8_t> data;
    int32_t dataSize = 0;
    int64_t pts = 0;
    uint32_t flags = 0;
};

#endif // OH_VEF_CODEC_COMMON_H