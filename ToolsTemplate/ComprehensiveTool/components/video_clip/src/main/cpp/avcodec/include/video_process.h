/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

#ifndef VIDEOPROCESS_H
#define VIDEOPROCESS_H

#include "multimedia/video_processing_engine/video_processing.h"

#include "native_window/external_window.h"

enum class StatusVP {
    UNDEFINED_STATUS = 0,
    PREPARE_STATUS,
    INIT_PROCESSING,
    START_PROCESSING,
    STOP_PROCESSING
};

class VideoProcess {
public:
    VideoProcess() = default;
    ~VideoProcess();
    OHNativeWindow *windowVPEIn_ = nullptr; // 输入
    OHNativeWindow *windowVPEOut_ = nullptr;    // 输出

    VideoProcessing_Callback *callback_ = nullptr;
    bool PrepareSurface(int convertType);
    bool InitProcessing();
    bool StartProcessing();
    bool StopProcessing();
    void DestroyProcessing();
    uint64_t processedFramesNum_ = 0;
    
private:
    OH_VideoProcessing *processor_ = nullptr;
    bool hadBeenInitializeEnv_ = false;
    StatusVP status_ = StatusVP::UNDEFINED_STATUS;
};
#endif
