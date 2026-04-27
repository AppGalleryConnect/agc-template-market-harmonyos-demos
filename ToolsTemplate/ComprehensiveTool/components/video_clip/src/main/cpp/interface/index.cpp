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

#include "index.h"
#include "Editor.h"
#include "ImageAsset.h"
#include "Timeline.h"
#include "VideoAsset.h"
#include "i_av_decoder_engine.h"
#include "utils.h"
#include "Canvas.h"
#include <unistd.h>

VEditorStatus Interface::SetVideo(std::string& path, int32_t fd) 
{
    LOGI("Interface::SetVideo. path=%{public}s. fd=%{public}d", path.c_str(), fd);
    if (fd < 0 || path == "") {
        LOGE("Interface::SetVideo invalid fd or path.");
        return VEditorStatus::STATUS_ERROR;
    }
    path = UriToPath(path);
    LOGD("Interface::SetVideo. true path is %{public}s.", path.c_str()); // 真实路径
    
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::SetVideo timeline is nullptr.");
        return VEditorStatus::STATUS_ERROR;
    }
    timeline->SetMainVideo(path); //同时用fd创建decoder
    VEditorStatus status = Editor::GetInstance().PreparePreviewEngine(fd); 
    if (status == VEditorStatus::STATUS_OK) {
        Editor::GetInstance().TrackFd(fd);
    } else {
        LOGE("Interface::SetVideo Create preview decoder failed.");
        timeline->UnsetMainVideo();    
        close(fd);
        return VEditorStatus::STATUS_ERROR;
    }
    return VEditorStatus::STATUS_OK;
}

void Interface::SetBgAudio(std::string &path, int32_t fd)
{
    LOGI("Interface::SetBgAudio. path=%{public}s.", path.c_str());
    if (fd < 0) {
        LOGE("Interface::SetBgAudio. invalid fd.");
        return;
    }
    path = UriToPath(path);
    LOGD("Interface::SetVideo. true path is %{public}s.", path.c_str()); // 真实路径
    
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::SetBgAudio. timeline is nullptr.");
        return;
    }
    timeline->SetBgAudio(path);
    
    // 加入音频到预览解码引擎
    std::shared_ptr<IAVDecoderEngine> previewEngine = Editor::GetInstance().GetPreviewEngine();
    if (previewEngine == nullptr) {
        LOGE("Interface::SetBgAudio. decoderEngine is nullptr.");
    }
    previewEngine->AddAudio(fd); 
    LOGI("Interface::SetBgAudio. bgAudio fd is %{public}d", fd);
    Editor::GetInstance().TrackFd(fd);
}

std::tuple<std::string, int32_t, int32_t> Interface::AddImage(std::string &path, bool isPath)
{
    LOGI("Interface::AddImage. path=%{public}s.", path.c_str());
    if (!isPath) {
        path = UriToPath(path);
        LOGI("Interface::AddImage. true path=%{public}s.", path.c_str());
    }
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::AddImage. timeline is nullptr.");
        return {"", 0, 0};
    }
    std::string imageId = timeline->AddImage(path);
    
    std::shared_ptr<ImageAsset> image = timeline->GetImage(imageId);
    if (image == nullptr) {
        LOGE("Interface::AddImage. image is nullptr.");
        return {"", 0, 0};
    }
    image->PrepareImageInfo(); // 读一下image info拿到真实宽高
    LOGI("Interface::AddImage. height=%{public}d, width = %{public}d.", image->GetHeight(), image->GetWidth());
    return {imageId, image->GetHeight(), image->GetWidth()};
}

void Interface::RemoveImage(std::string &imageId)
{
    LOGI("Interface::RemoveImage. imageId=%{public}s.", imageId.c_str());
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::RemoveImage. timeline is nullptr.");
        return;
    }
    timeline->RemoveImage(imageId);
}

void Interface::UnsetBgAudio()
{
    LOGI("Interface::UnsetBgAudio.");
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::UnsetBgAudio. timeline is nullptr.");
        return;
    }
    timeline->UnsetBgAudio();
    std::shared_ptr<IAVDecoderEngine> previewEngine = Editor::GetInstance().GetPreviewEngine();
    if (previewEngine == nullptr) {
        LOGE("Interface::UnsetBgAudio. decoderEngine is nullptr.");
    } else {
         previewEngine->DeleteAudio(0); // 这里fd用不到
    }
}

void Interface::SetTrim(uint64_t trimIn, uint64_t trimOut)
{
    LOGI("Interface::SetTrim. TrimIn %{public}lu, TrimOut %{public}lu", trimIn, trimOut);
    if (trimIn < 0 || trimOut < 0) {
        LOGE("Interface::SetTrim. Invalid trimIn or trimOUt");
        return;
    }
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::SetTrim. timeline is nullptr.");
        return;
    }
    std::shared_ptr<VideoAsset> mainVideo = timeline->GetMainVideo();
    if (mainVideo == nullptr) {
        LOGE("Interface::SetTrim. mainVideo is nullptr");
        return;
    }
    mainVideo->SetTrimIn(trimIn);
    mainVideo->SetTrimOut(trimOut);
}

uint64_t Interface::GetDuration()
{
    LOGI("Interface::GetDuration.");
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::GetDuration. timeline is nullptr.");
        return 0;
    }
    std::shared_ptr<VideoAsset> mainVideo = timeline->GetMainVideo();
    if (mainVideo == nullptr) {
        LOGE("Interface::GetDuration. mainVideo is nullptr");
        return 0;
    }
    LOGD("Interface::GetDuration. Duration is %{public}d", mainVideo->GetDuration());
    return mainVideo->GetDuration();
}

uint64_t Interface::GetOriginalDuration()
{
    LOGI("Interface::GetOriginalDuration.");
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::GetOriginalDuration. timeline is nullptr.");
        return 0;
    }
    std::shared_ptr<VideoAsset> mainVideo = timeline->GetMainVideo();
    if (mainVideo == nullptr) {
        LOGE("Interface::GetOriginalDuration. mainVideo is nullptr");
        return 0;
    }
    LOGD("Interface::GetDuration. Duration is %{public}d", mainVideo->GetOriginalDuration());
    return mainVideo->GetOriginalDuration();
}

void Interface::MoveImage(std::string imageId, float positionX, float positionY)
{
    LOGI("Interface::MoveImage. id = %{public}s, move to (%{public}f, %{public}f)", imageId.c_str(), positionX, positionY);
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::MoveImage. timeline is nullptr.");
        return ;
    }
    std::shared_ptr<ImageAsset> image = timeline->GetImage(imageId);
    if (image == nullptr) {
        LOGE("Interface::MoveImage. image is null ptr");
        return;
    }
    image->SetPositionX(positionX);
    image->SetPositionY(positionY);
    return;
}

void Interface::ScaleImage(std::string imageId, float scale)
{
    LOGI("Interface::ScaleImage. id = %{public}s, scale (%{public}f)", imageId.c_str(), scale);
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::ScaleImage. timeline is nullptr.");
        return ;
    }
    std::shared_ptr<ImageAsset> image = timeline->GetImage(imageId);
    if (image == nullptr) {
        LOGE("Interface::ScaleImage. image is null ptr");
        return;
    }
    image->SetScale(scale);
    return;
}

void Interface::PushImageTop(std::string imageId)
{
    LOGI("Interface::PushImageTop. id = %{public}s", imageId.c_str());
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::PushImageTop. timeline is nullptr.");
        return ;
    }
    timeline->PushImageTop(imageId);
    return;
}

void Interface::RotateImage(std::string imageId, float rotate)
{
    LOGI("Interface::RotateImage. id = %{public}s, rotate (%{public}f)", imageId.c_str(), rotate);
    std::shared_ptr<Timeline> timeline = Editor::GetInstance().GetTimeline();
    if (timeline == nullptr) {
        LOGE("Interface::RotateImage. timeline is nullptr.");
        return ;
    }
    std::shared_ptr<ImageAsset> image = timeline->GetImage(imageId);
    if (image == nullptr) {
        LOGE("Interface::RotateImage. image is null ptr");
        return;
    }
    image->SetRotate(rotate);
    return;
}

VEditorStatus Interface::Export()
{
    LOGI("Interface::Export.");
    VEditorStatus status;
    status = Editor::GetInstance().Export();
    if (status == VEditorStatus::STATUS_ERROR) {
        LOGE("Interface::Export. Export failed");
        return VEditorStatus::STATUS_ERROR;
    }
    return VEditorStatus::STATUS_OK;
}

void Interface::InitEditor()
{
    LOGI("Interface::InitEditor.");
    Editor::GetInstance().Init();

    return;
}

void Interface::DestroyEditor()
{
    LOGI("Interface::DestroyEditor");
    Editor::GetInstance().Destroy();
    
    return;
}

VEditorStatus Interface::Play()
{
    LOGI("Interface::Play.");
    
    return Editor::GetInstance().Play();
}

VEditorStatus Interface::Pause()
{
    LOGI("Interface::Pause.");
    
    return Editor::GetInstance().Pause();
}

VEditorStatus Interface::Stop()
{
    LOGI("Interface::Stop.");
    
    return Editor::GetInstance().Stop();
}

VEditorStatus Interface::PlayFromStart()
{
    LOGI("Interface::PlayFromStart.");
    
    return Editor::GetInstance().PlayFromStart();
}

void Interface::MuteVideo(bool muted)
{
    LOGI("Interface::MuteVideo.");
    Editor::GetInstance().MuteVideo(muted);
    return;
}

void Interface::SetCanvasSize(int32_t height, int32_t width)
{
    LOGI("Interface::SetCanvasSize height %{public}d, width %{public}d", height, width);
    
    std::shared_ptr<Canvas> canvas = Editor::GetInstance().GetCanvas();
    if (canvas==nullptr) {
        LOGE("Interface::SetCanvasSize canvas is nullptr");
        return;
    }
    canvas->SetCanvasSize(static_cast<uint32_t>(height), static_cast<uint32_t>(width));
    return;
}

std::vector<std::pair<uint32_t, uint32_t>> Interface::GetDrawableArea(){
    LOGI("Interface::GetDrawableArea");
    std::shared_ptr<Canvas> canvas = Editor::GetInstance().GetCanvas();
    if (canvas==nullptr) {
        LOGE("Interface::SetCanvasSize canvas is nullptr");
        return {};
    }
    return canvas->GetDrawableArea();
}


void onCreated(OH_NativeXComponent* component, void* window)
{   
    LOGI("XComponent surface onCreated trigger");
    Editor::GetInstance().SetPreviewWindow(static_cast<OHNativeWindow*>(window));
    LOGI("Set preview window.");
}

// 这里跳转页面会重新调用napi的init,如果在这里调用Editor::GetInstance().Init()的话，跳转页面会刷新Timeline。
napi_value Interface::_Init(napi_env env, napi_value exports)
{   
    LOGI("Interface::_Init. napi init.");
    // 解析ArkTs定义的XComponent
    napi_value exportInstance = nullptr;
    if (napi_get_named_property(env, exports, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance) == napi_status::napi_ok) {
        // 这里没创建xComponent也会打日志不知道为什么
        LOGI("Interface::_Init. Find XComponent");
    
        OH_NativeXComponent *nativeXComponent = nullptr;
        napi_unwrap(env, exportInstance, reinterpret_cast<void**>(&nativeXComponent));
        
        LOGI("Interface::_Init. Unwrap XComponent");
        
        callback.OnSurfaceCreated = onCreated;
        OH_NativeXComponent_RegisterCallback(nativeXComponent, &callback);
    }
    return exports;
}

