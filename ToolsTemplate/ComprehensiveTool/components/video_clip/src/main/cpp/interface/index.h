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

#ifndef VEDITOR_INDEX_H
#define VEDITOR_INDEX_H

#include "napi/native_api.h" // 这个头文件必须放在第一个引用，不然会报错，不知道为什么
#include "utils.h"
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <string>
#include <tuple>

struct Interface{
    static void InitEditor();
    static void DestroyEditor();
    static VEditorStatus SetVideo(std::string& path, int32_t fd);
    static void SetBgAudio(std::string& path, int32_t fd);
    static void UnsetBgAudio();
    static std::tuple<std::string, int32_t, int32_t> AddImage(std::string& path, bool isPath=false);
    static void RemoveImage(std::string& imageId);
    static void SetTrim(uint64_t trimIn, uint64_t trimOut);
    static void MoveImage(std::string imageId, float positionX, float positionY);
    static void ScaleImage(std::string imageId, float scale);
    static void RotateImage(std::string imageId, float rotate);
    static void PushImageTop(std::string imageId);
    static uint64_t GetDuration();
    static uint64_t GetOriginalDuration();
    static napi_value _Init(napi_env env, napi_value exports);
    static VEditorStatus Export();
    static VEditorStatus Play();
    static VEditorStatus Pause();
    static VEditorStatus Stop();
    static VEditorStatus PlayFromStart();
    static void MuteVideo(bool muted);
    static void SetCanvasSize(int32_t height, int32_t width);
    static std::vector<std::pair<uint32_t, uint32_t>> GetDrawableArea();
};

static void onCreated(OH_NativeXComponent* component, void* window);
static OH_NativeXComponent_Callback callback;
#endif //MYAPPLICATION_INDEX_H
