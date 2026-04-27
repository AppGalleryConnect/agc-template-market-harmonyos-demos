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

#ifndef VEDITOR_CALLBACKS_H
#define VEDITOR_CALLBACKS_H
#include "i_av_decoder_engine.h"
#include "i_av_encoder_engine.h"
#include "utils.h"

class LambdaAVDecoderCallback: public AVDecodeCallback {
public:
    explicit LambdaAVDecoderCallback(
        std::function<void(uint64_t)> onFrameFunc,
        std::function<void(CodecStatus)> onStatusFunc
    ) : m_onFrameFunc(std::move(onFrameFunc)), m_onStatusFunc(std::move(onStatusFunc)) {LOGI("creat callback");}
    
    void OnDecodeFrame(uint64_t pts) override {
        if (m_onFrameFunc) {
            m_onFrameFunc(pts);
        }
    }
    
    void OnDecodeStatus(CodecStatus status) override {
        if (m_onStatusFunc) {
            m_onStatusFunc(status);
        }
    }
private:
    std::function<void(uint64_t)> m_onFrameFunc;
    std::function<void(CodecStatus)> m_onStatusFunc;
};

class LambdaAVEncoderCallback: public AVEncodeCallback {
public:
    explicit LambdaAVEncoderCallback(
        std::function<void(uint64_t)> onFrameFunc,
        std::function<void(CodecStatus)> onStatusFunc
    ) : m_onFrameFunc(std::move(onFrameFunc)), m_onStatusFunc(std::move(onStatusFunc)) {LOGI("creat callback");}

    void OnEncodeFrame(uint64_t pts) override  {
        if (m_onFrameFunc) {
            m_onFrameFunc(pts);
        }
    }
    
    void OnEncodeStatus(CodecStatus status) override {
        if (m_onStatusFunc) {
            m_onStatusFunc(status);
        }
    }
private:
    std::function<void(uint64_t)> m_onFrameFunc;
    std::function<void(CodecStatus)> m_onStatusFunc;
};


#endif //MYAPPLICATION_CALLBACKS_H
