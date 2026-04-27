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
#include <native_buffer/buffer_common.h>
#include <native_buffer/native_buffer.h>
#include "avcodec_log.h"
#include "video_process.h"

#undef LOG_TAG
#define LOG_TAG "VideoProcess"

VideoProcess::~VideoProcess() {
    AVCODEC_SAMPLE_LOGD("~VideoProcess");
}

void OnError(OH_VideoProcessing *videoProcessing, VideoProcessing_ErrorCode error, void *userData)
{
    (void) videoProcessing;
    (void) userData;
    AVCODEC_SAMPLE_LOGW("OnError, error:%{public}d", error);
}

void OnState(OH_VideoProcessing *videoProcessing, VideoProcessing_State state, void *userData)
{
    (void) videoProcessing;
    (void) userData;
    AVCODEC_SAMPLE_LOGW("OnState, state:%{public}d", state);
}

void onNewOutputBuffer(OH_VideoProcessing *videoProcessing, uint32_t index, void *userData)
{
    static_cast<VideoProcess*>(userData)->processedFramesNum_++;
    OH_VideoProcessing_RenderOutputBuffer(videoProcessing, index);
    (void) userData;
}

bool VideoProcess::PrepareSurface(int convertType)
{
    int32_t ret = OH_VideoProcessing_InitializeEnvironment();
    CHECK_AND_LOGW(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessing_InitializeEnvironment failed, ret:%{public}d", ret);
    hadBeenInitializeEnv_ = true;
    ret = OH_VideoProcessing_Create(&processor_, convertType); // VIDEO_PROCESSING_TYPE_COLOR_SPACE_CONVERSION
    CHECK_AND_RETURN_RET_LOG(ret == VIDEO_PROCESSING_SUCCESS, false, "OH_VideoProcessing_Create");
    ret = OH_VideoProcessing_GetSurface(processor_, &windowVPEIn_);
    uint8_t metaData = OH_VIDEO_HDR_VIVID;
    OH_NativeWindow_SetMetadataValue(windowVPEIn_, OH_HDR_METADATA_TYPE, sizeof(uint8_t), &metaData);

    CHECK_AND_RETURN_RET_LOG(ret == VIDEO_PROCESSING_SUCCESS, false, "OH_VideoProcessing_GetSurface");
    status_ = StatusVP::PREPARE_STATUS;
    return true;
}

bool VideoProcess::InitProcessing()
{
    CHECK_AND_RETURN_RET_LOG(status_ == StatusVP::PREPARE_STATUS, false, "InitProcessing failed");
    int32_t ret = OH_VideoProcessing_SetSurface(processor_, windowVPEOut_);
    CHECK_AND_RETURN_RET_LOG(ret == VIDEO_PROCESSING_SUCCESS, false, "OH_VideoProcessing_SetSurface failed");
    ret = OH_VideoProcessingCallback_Create(&callback_);
    CHECK_AND_RETURN_RET_LOG(ret == VIDEO_PROCESSING_SUCCESS, false, "OH_VideoProcessingCallback_Create failed");
    ret = OH_VideoProcessingCallback_BindOnError(callback_, OnError);
    CHECK_AND_RETURN_RET_LOG(ret == VIDEO_PROCESSING_SUCCESS, false, "OH_VideoProcessingCallback_BindOnError failed");
    ret = OH_VideoProcessingCallback_BindOnState(callback_, OnState);
    CHECK_AND_RETURN_RET_LOG(ret == VIDEO_PROCESSING_SUCCESS, false, "OH_VideoProcessingCallback_BindOnState failed");
    ret = OH_VideoProcessingCallback_BindOnNewOutputBuffer(callback_, onNewOutputBuffer);
    CHECK_AND_RETURN_RET_LOG(ret == VIDEO_PROCESSING_SUCCESS, false, "OH_VideoProcessingCallback_BindOnError failed");
    ret = OH_VideoProcessing_RegisterCallback(processor_, callback_, this);
    CHECK_AND_RETURN_RET_LOG(ret == VIDEO_PROCESSING_SUCCESS, false, "OH_VideoProcessing_RegisterCallback failed");
    status_ = StatusVP::INIT_PROCESSING;
    return true;
}

bool VideoProcess::StartProcessing()
{
    if ((status_ != StatusVP::INIT_PROCESSING) && (status_ != (StatusVP::STOP_PROCESSING))) {
        AVCODEC_SAMPLE_LOGE("current status is %{public}d, predStatus: init or stop", status_);
        return false;
    }
    CHECK_AND_RETURN_RET_LOG(status_ == StatusVP::INIT_PROCESSING, false, "StartProcessing failed");
    int32_t ret = OH_VideoProcessing_Start(processor_);
    CHECK_AND_RETURN_RET_LOG(ret == VIDEO_PROCESSING_SUCCESS, false, "OH_VideoProcessing_Start failed");
    status_ = StatusVP::START_PROCESSING;
    return true;
}

bool VideoProcess::StopProcessing()
{
    CHECK_AND_RETURN_RET_LOG(status_ == StatusVP::START_PROCESSING, false, "StopProcessing failed");
    int32_t ret = OH_VideoProcessing_Stop(processor_);
    CHECK_AND_RETURN_RET_LOG(ret == VIDEO_PROCESSING_SUCCESS, false, "OH_VideoProcessing_Stop failed");
    status_ = StatusVP::STOP_PROCESSING;
    return true;
}

void VideoProcess::DestroyProcessing()
{
    if (callback_ != nullptr) {
        if (OH_VideoProcessingCallback_Destroy(callback_) != VIDEO_PROCESSING_SUCCESS) {
            AVCODEC_SAMPLE_LOGE("OH_VideoProcessingCallback_Destroy failed");
        }
        callback_ = nullptr;
    }
    if (processor_ != nullptr) {
        if (OH_VideoProcessing_Destroy(processor_) != VIDEO_PROCESSING_SUCCESS) {
            AVCODEC_SAMPLE_LOGE("OH_VideoProcessing_Destroy failed");
        }
        processor_ = nullptr;
    }
    if (hadBeenInitializeEnv_) {
        if (OH_VideoProcessing_DeinitializeEnvironment() != VIDEO_PROCESSING_SUCCESS) {
            AVCODEC_SAMPLE_LOGE("OH_VideoProcessing_DeinitializeEnvironment failed");
        }
        hadBeenInitializeEnv_  = false;
    }
}