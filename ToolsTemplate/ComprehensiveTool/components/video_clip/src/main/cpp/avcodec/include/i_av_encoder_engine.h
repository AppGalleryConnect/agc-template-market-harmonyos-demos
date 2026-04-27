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

#ifndef OH_VEF_I_AV_ENCODER_ENGINE_H
#define OH_VEF_I_AV_ENCODER_ENGINE_H

#include "codec_common.h"
#include <memory>
#include "multimedia/player_framework/native_avcodec_base.h"
#include "pcm_buffer_queue.h"

/**
 * @brief AVEncodeCallback provides callback functions to notify encoding status changes.
 */
class AVEncodeCallback {
public:
    /**
     * @brief Destructor of AVEncodeCallback.
     */
    virtual ~AVEncodeCallback() = default;
    
    /**
     * @brief Callback to notify current encoding frame position in us.
     *
     * @param pts. Current encoding position expressed in microsecond.
     */
    virtual void OnEncodeFrame(uint64_t pts) = 0;
    
    /**
     * @brief Callback to notify encoding status changes.
     *
     * @param status. Current encoding status.
     */
    virtual void OnEncodeStatus(CodecStatus result) = 0;
};

/**
 * @brief AVMuxerParam contains muxing parameters.
 */
struct AVMuxerParam {
    /**
     * @brief Descriptor of the file to be muxed.
     */
    int targetFileFd { -1 };
    
    /**
     * @brief Format of the file to be muxed. The default format is mp4.
     */
    OH_AVOutputFormat avOutputFormat = AV_OUTPUT_FORMAT_MPEG_4;
    
    /**
     * @brief Rotation of the video to be muxed. The default rotation is 0.
     */
    int32_t rotation = 0;
};

/**
 * @brief AVEncodeParam contains video format information, audio format information and muxer parameters.
 */
struct AVEncodeParam {
    /**
     * @brief Muxing parameters.
     */
    AVMuxerParam muxerParam;
    
    /**
     * @brief Video encoding and muxing format information.
     */
    OH_AVFormat* videoTrunkFormat = nullptr;
    
    /**
     * @brief Audio encoding and muxing format information.
     */
    OH_AVFormat* audioTrunkFormat = nullptr;
};

/**
 * @brief IAVEncoderEngine provides audio and video encoding and muxing abilities in exporting scene.
 */
class IAVEncoderEngine {
public:
    /**
     * @brief Create IAVEncoderEngine instance.
     *
     * @param encodeParam. The encoding parameters for the encoding engine.
     * @param cb. Callback used to notify encoding status changes.
     * @return a shared pointer of an IAVEncoderEngine instance.
     */
    static std::shared_ptr<IAVEncoderEngine> Create(const AVEncodeParam& encodeParam,
        std::weak_ptr<AVEncodeCallback> cb);
    
    /**
     * @brief Destructor of IAVEncoderEngine.
     */
    virtual ~IAVEncoderEngine() = default;
    
    /**
     * @brief Initialize the IAVEncoderEngine.
     *
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t Init() = 0;
    
    /**
     * @brief Get the window to receive the decoded video data used for encoding.
     *        This function must be used after initializing.
     *
     * @return OHNativeWindow pointer of the native window to receive the decoded video data.
     */
    virtual OHNativeWindow* GetVideoInputWindow() = 0;
    
    /**
     * @brief Get the audio output buffer queue. This function must be used after initializing.
     *        This queue will be used to receive the decoded audio pcm data from IAVDecoderEngine.
     *
     * @return a shared pointer of the pcm buffer queue.
     */
    virtual std::shared_ptr<PcmBufferQueue> GetAudioInputBufferQueue() const = 0;
    
    /**
     * @brief Start the IAVEncoderEngine.
     *
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t Start() = 0;
    
    /**
     * @brief Stop the IAVEncoderEngine. Currently this function is not supported.
     *        If need to stop encoder task, please use SendEOS function instead.
     *
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t Stop() = 0;
    
    /**
     * @brief Send EOS to the encoder engine. This function will stop the encoding task.
     *
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t SendEOS() = 0;
};

#endif // OH_VEF_I_AV_ENCODER_ENGINE_H