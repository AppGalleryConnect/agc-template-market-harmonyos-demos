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

#ifndef VEDITOR_EDITOR_H
#define VEDITOR_EDITOR_H

#include <cstdint>
#include <memory>
#include <multimedia/player_framework/native_avcodec_base.h>
#include <multimedia/player_framework/native_avformat.h>
#include <vector>
#include "napi/native_api.h"
#include "utils.h"
#include "Canvas.h"

class Timeline;
class IAVDecoderEngine;
class IAVEncoderEngine;
class IGLRenderEngine;
class PcmBufferQueue;


class Editor {
public:
    static Editor& GetInstance();
    
    Editor(const Editor&) = delete;
    Editor operator=(const Editor&) = delete;
    ~Editor() = default;
    
    void Init(); 
    void Destroy();
    void Reset();
    
    VEditorStatus Play(); // 预览资源到屏幕, 主视频加入后即触发Play()，在停止后重新play需要再次调用。
    VEditorStatus Stop(); // 清理编解码和渲染资源
    VEditorStatus Pause();
    VEditorStatus Export(); // 渲染导出资源
    VEditorStatus PlayFromStart(); // seek to start time and play
    
    VEditorStatus PreparePreviewEngine(int32_t videoFd); 
    VEditorStatus PrepareExportEngine(std::string savePath); // 初始化RenderEngine和IAVEncoderEngine，链接各个模块。
    
    void OnPlay(int64_t pts);
    void OnExport(int64_t pts);
    void SetPreviewWindow(OHNativeWindow* window);
    void MuteVideo(bool muted);
    std::shared_ptr<Timeline> GetTimeline();
    std::shared_ptr<IAVEncoderEngine> GetEncoderEngine();
    std::shared_ptr<IAVDecoderEngine> GetPreviewEngine();
    std::shared_ptr<IGLRenderEngine> GetRenderEngine();
    void RegisterExportCallback(napi_threadsafe_function onProgress, napi_threadsafe_function onEnd);
    void TrackFd(int32_t fd);
    void CloseFds();
    
    std::shared_ptr<Canvas> GetCanvas();
    napi_threadsafe_function m_exportSendEnd;
    napi_threadsafe_function m_exportSendProgress;
    
private:
    Editor();
    
    std::shared_ptr<Timeline> m_timeline{nullptr};
    std::shared_ptr<IAVDecoderEngine> m_previewEngine{nullptr}; // 预览的解码（封装）引擎
    std::shared_ptr<IAVDecoderEngine> m_exportEngine{nullptr}; // 导出的解码（封装）引擎
    std::shared_ptr<IAVEncoderEngine> m_encoderEngine{nullptr};
    std::shared_ptr<IGLRenderEngine> m_renderEngine{nullptr};
    std::shared_ptr<Canvas> m_canvas{nullptr}; // 画布
    OHNativeWindow* m_previewWindow; // 裸指针，nativeWindow生命周期由前端管理。
    
    std::shared_ptr<PcmBufferQueue> m_bufferQueue;
    std::vector<int32_t> m_openedFds; // 打开的文件描述符，Editor析构前要销毁;
    std::atomic<bool> m_isPlayReady{false};
    std::atomic<bool> m_isExportReady{false};
    
    OH_AVFormat* m_inVideoFormat{nullptr};
    std::atomic<bool> m_firstFrame{false};
    std::atomic<bool> m_sendEos{false};
    std::atomic<bool> m_isPreviewEngineStopped{false};
    
    std::atomic<float> m_progress;
};

#endif //AVCODECVIDEO_EDITOR_H
