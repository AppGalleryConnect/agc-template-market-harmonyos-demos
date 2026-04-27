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

#ifndef OH_VEF_I_AV_DECODER_ENGINE_H
#define OH_VEF_I_AV_DECODER_ENGINE_H

#include <memory>
#include "multimedia/player_framework/native_avcodec_base.h"
#include "codec_common.h"
#include "pcm_buffer_queue.h"

/**
 * @brief AVDecodeCallback provides callback functions to notify decoding status changes.
 */
class AVDecodeCallback {
public:
    /**
     * @brief Destructor of AVDecodeCallback.
     */
    virtual ~AVDecodeCallback() = default;

    /**
     * @brief Callback to notify current decoding frame position in us.
     *
     * @param pts. Current decoding position expressed in microsecond.
     */
    virtual void OnDecodeFrame(uint64_t pts) = 0;
    
    /**
     * @brief Callback to notify decoding status changes.
     *
     * @param status. Current decoding status.
     */
    virtual void OnDecodeStatus(CodecStatus status) = 0;
};

/**
 * @brief IAVDecoderEngine provides audio and video demuxing and decoding abilities in previewing and exporting scenes.
 */
class IAVDecoderEngine {
public:
    /**
     * @brief Create IAVDecoderEngine instance.
     *
     * @param fd. The file descriptor of the selected file to be decoded.
     * @param cb. Callback used to notify decoding status changes.
     * @return a shared pointer of an IAVDecoderEngine instance.
     */
    static std::shared_ptr<IAVDecoderEngine> Create(int fd, std::weak_ptr<AVDecodeCallback> cb);

    /**
     * @brief Destructor of IAVDecoderEngine.
     */
    virtual ~IAVDecoderEngine() = default;
    
    /**
     * @brief Set which window the decoded video data will be sent to. This function must be called before initializing.
     *
     * @param surfaceWindow. The native window to receive the decoded video data.
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t SetVideoOutputWindow(OHNativeWindow* surfaceWindow) = 0;
    
    /**
     * @brief Initialize the IAVDecoderEngine.
     *
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t Init() = 0;
    
    /**
     * @brief Start the IAVDecoderEngine.
     *
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t Start() = 0;
    
    /**
     * @brief Pause the IAVDecoderEngine while previewing.
     *
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t Pause() = 0;
    
    /**
     * @brief Stop the IAVDecoderEngine while previewing.
     *
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t Stop() = 0;
    
    /**
     * @brief Seek to a specified position in ms. After calling this function, the decoder will be flushed and stopped.
     *        Start function should be called if need to restart the decoding task.
     *
     * @param millisecond. The position to be seeked to, expressed in millisecond.
     * @param mode. The specified seek mode.
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t Seek(int64_t millisecond, OH_AVSeekMode mode) = 0;
    
    /**
     * @brief Set the duration of the selected video file after cropping. The duration will be used to determine when
     *        the background music decoding task should stop.
     *
     * @param duration. The length of the selected video file after cropping.
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t SetPlayDuration(int64_t duration) = 0;
    
    /**
     * @brief Set the audio output buffer queue. This queue could be gotten from the target IAVEncoderEngine.
     *        The decoded audio pcm data will be sent to the IAVEncoderEngine through the pcm buffer queue.
     *        This function is suggested to be used between initializing and starting.
     *
     * @param queue. The pcm buffer queue from the target IAVEncoderEngine.
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t SetAudioOutputBufferQueue(std::shared_ptr<PcmBufferQueue>& queue) = 0;
    
    /**
     * @brief Get the video format of the input file.
     *
     * @return OH_AVFormat pointer of the input video.
     */
    virtual OH_AVFormat* GetVideoFormat() = 0;
    
    /**
     * @brief Get the audio format of the input file.
     *
     * @return OH_AVFormat pointer of the input audio.
     */
    virtual OH_AVFormat* GetAudioFormat() = 0;
    
    /**
     * @brief Enable or disable high performance mode of video decoding.
     *        When decoding video for exporting, high performance mode should be enabled for faster exporting speed.
     *
     * @param enableFlag. True means enable high performance mode, while false means disable high performance mode.
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t SetHighPerformance(bool enableFlag) = 0;
    
    /**
     * @brief Reserve or remove the original audio in the selected video file.
     *        This function should be used only in exporting scene.
     *
     * @param unselectFlag. True means remove the original audio, while false means reserve the original audio.
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t AudioUnselect(bool unselectFlag) = 0;
    
    /**
     * @brief Mute or unmute the original audio in the selected video file.
     *        This function should be used only in previewing scene.
     *        When the original audio is muted, the audio decoding task continues, and only the audio renderer is muted.
     *
     * @param muteFlag. True means mute the original audio, while false means unmute the original audio.
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t AudioMute(bool muteFlag) = 0;
    
    /**
     * @brief Add background music file. Only one background music file can be added in one decoding task.
     *        For previewing scene, if the decoder engine has already been started, this function will start playing
     *        music immediately; and if the decoder has not been started, the music will be played when decoder starts.
     *        For exporting scene, this function must be used before starting.
     *
     * @param fd. File descriptor of the background music file to be added.
     * @return 0 if successful or an error code if failed.
     */
    virtual int32_t AddAudio(int fd) = 0;
    
    /**
     * @brief Delete background music file. This function should be used after a background music file is added.
     *        For previewing scene, this function will stop playing the background music immediately.
     *        For exporting scene, this function must be used before starting.
     *
     * @param fd. File descriptor of the background music file.
     * @return 0 if successful or an error code if failed to be deleted.
     */
    virtual int32_t DeleteAudio(int fd) = 0;
    
    /**
     * @brief Get video duration. For files whose video duration is not equal to file duration, it is suggested to use
     *        video duration.
     *
     * @return video duration.
     */
    virtual int64_t GetVideoDuration() = 0;
};

#endif // OH_VEF_I_AV_DECODER_ENGINE_H