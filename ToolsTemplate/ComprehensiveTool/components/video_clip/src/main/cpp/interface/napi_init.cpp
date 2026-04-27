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

#include "napi/native_api.h"
#include <cstddef>
#include <string>
#include "index.h"
#include "Editor.h"
#include "js_utils.h"
#include <tuple>
#include "utils.h"
#include "asyncwork.h"


static void CallProcess(napi_env env, napi_value onProgress, void* context, void*data)
{
    napi_status status;
    int32_t progress = *reinterpret_cast<int32_t*>(data);
    napi_value argv[1]; 
    argv[0] = ToJsInt(env, progress);
    status = napi_call_function(env, nullptr, onProgress, 1, argv, nullptr);
    if (status != napi_ok) {
        LOGE("napi CallProcess get onProgress from ref failed");
        return;
    }
    free(data); // 只在这里free一次
}

static void CallEnd(napi_env env, napi_value onEnd, void* context, void*data)
{
    napi_status status;
    status = napi_call_function(env, nullptr, onEnd, 0, nullptr, nullptr);
}

static napi_value SetVideo(napi_env env, napi_callback_info info)
{
    size_t argc = 2;    
    napi_value args[2] = {nullptr};
    
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    std::string path = JsToString(env, args[0]);
    int32_t fd = GetFd(env, args[1]);
    VEditorStatus status =  Interface::SetVideo(path, fd);
    
    if (status == VEditorStatus::STATUS_OK) {
        return ToJsInt(env, 0);
    } else {
        return ToJsInt(env, -1);
    }
}

static napi_value SetBgAudio(napi_env env, napi_callback_info info)
{
    size_t argc = 2;    
    napi_value args[2] = {nullptr};
    
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    std::string path = JsToString(env, args[0]);
    int32_t fd = JsToInt32(env, args[1]);
    
    Interface::SetBgAudio(path, fd);
    
    return ToJsUndefined(env);
}

static napi_value AddImage(napi_env env, napi_callback_info info)
{
    size_t argc = 2;    
    napi_value args[2];
    
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    std::string path = JsToString(env, args[0]);
    bool isPath = JsToBool(env, args[1]);
    std::tuple<std::string, uint32_t, uint32_t> image = Interface::AddImage(path, isPath);
    napi_value imageId = ToJsString(env, std::get<0>(image));
    napi_value height = ToJsInt(env, (int32_t)std::get<1>(image));
    napi_value width = ToJsInt(env, (int32_t)std::get<2>(image));
    
    napi_value res;
    napi_create_object(env, &res);
    napi_set_named_property(env, res, "imageId", imageId);
    napi_set_named_property(env, res, "height", height);
    napi_set_named_property(env, res, "width", width);
    
    return res;
}

static napi_value RemoveImage(napi_env env, napi_callback_info info)
{
    size_t argc = 1;    
    napi_value args[1] = {nullptr};
    
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    std::string imageId = JsToString(env, args[0]);
    
    Interface::RemoveImage(imageId);
    
    return ToJsUndefined(env);
}

static napi_value UnsetBgAudio(napi_env env, napi_callback_info info)
{
    Interface::UnsetBgAudio();
    
    return ToJsUndefined(env);
}

static napi_value InitEditor(napi_env env, napi_callback_info info)
{
    Interface::InitEditor();
    
    return ToJsUndefined(env);
}

static napi_value DestroyEditor(napi_env env, napi_callback_info info)
{
    Interface::DestroyEditor();
    
    return ToJsUndefined(env);
}

static napi_value SetTrim(napi_env env, napi_callback_info info)
{
    size_t argc = 2;    
    napi_value args[2] = {nullptr};
    
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    uint64_t trimIn = JsToInt64(env, args[0]);
    uint64_t trimOut = JsToInt64(env, args[1]);
    
    Interface::SetTrim(trimIn, trimOut);
    
    return ToJsUndefined(env);
}

static napi_value GetDuration(napi_env env, napi_callback_info info)
{
    uint64_t duration = 0;
    duration = Interface::GetDuration();
    
    return ToJsInt(env, duration);
}

static napi_value GetOriginalDuration(napi_env env, napi_callback_info info)
{
    uint64_t originalDuration = 0;
    originalDuration = Interface::GetOriginalDuration();
    
    return ToJsInt(env, originalDuration);
}

static napi_value MoveImage(napi_env env, napi_callback_info info)
{
    size_t argc = 3;    
    napi_value args[3] = {nullptr};
    
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    std::string imageId = JsToString(env, args[0]);
    int32_t positionX = JsToFloat(env, args[1]);
    int32_t positionY = JsToFloat(env, args[2]);
    
    Interface::MoveImage(imageId, positionX, positionY);
    
    return ToJsUndefined(env);
}

static napi_value ScaleImage(napi_env env, napi_callback_info info)
{
    size_t argc = 2;    
    napi_value args[2] = {nullptr};
    
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    std::string imageId = JsToString(env, args[0]);
    float scale = JsToFloat(env, args[1]);
    
    Interface::ScaleImage(imageId, scale);
    
    return ToJsUndefined(env);
}

static napi_value RotateImage(napi_env env, napi_callback_info info)
{
    size_t argc = 2;    
    napi_value args[2] = {nullptr};
    
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    std::string imageId = JsToString(env, args[0]);
    float scale = JsToFloat(env, args[1]);
    
    Interface::RotateImage(imageId, scale);
    
    return ToJsUndefined(env);
}

static napi_value PushImageTop(napi_env env, napi_callback_info info)
{
    size_t argc = 1;    
    napi_value args[1] = {nullptr};
    
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    std::string imageId = JsToString(env, args[0]);
    
    Interface::PushImageTop(imageId);
    
    return ToJsUndefined(env);
}

static napi_value Export(napi_env env, napi_callback_info info)
{
    napi_value thisArg;

    size_t argc = 3;    
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, &thisArg, nullptr);
    std::string path = JsToString(env, args[0]);
    napi_value onProgressCallback = args[1];
    napi_value onEndCallback = args[2];

    // napi_value async_resource;
    napi_threadsafe_function tsfnOnProgress;
    napi_create_threadsafe_function(
                            env, 
                            onProgressCallback, 
                            NULL, 
                            ToJsString(env, "Export On Progress callback"), 
                            0, 
                            1, 
                            NULL, 
                            NULL, 
                            NULL,
                            CallProcess, 
                            &tsfnOnProgress
    );
    napi_threadsafe_function tsfnOnEnd;
    napi_create_threadsafe_function(
                            env, 
                            onEndCallback, 
                            NULL, 
                            ToJsString(env, "Export On Progress callback"), 
                            0, 
                            1, 
                            NULL, 
                            NULL, 
                            NULL,
                            CallEnd, 
                            &tsfnOnEnd
    );
    
    VEditorStatus status;
    // 这里注册回调和启动引擎直接在js线程做，不会阻塞。
    Editor::GetInstance().RegisterExportCallback(tsfnOnProgress, tsfnOnEnd);

    LOGD("napi Export. path is %{public}s", path.c_str());
    status = Editor::GetInstance().PrepareExportEngine(path); // 前端传入的沙箱路径
    if (status == VEditorStatus::STATUS_ERROR) {
        LOGE("napi Export. Prepare export Engine failed");
        
        // 创建一个promise，立刻reject并返回
        napi_deferred deferred;
        napi_value promise;
        napi_create_promise(env, &deferred, &promise);
        
        napi_value error;
        napi_create_error(env, nullptr, ToJsString(env, "PrepareExportEngine"), &error);
        napi_reject_deferred(env, deferred, error);
        return promise;
    }
    
    // 导出异步
    AsyncPlayer* asyncPlayer = AsyncWork::CreateAsyncPlayer(env, PLAYER_COMMAND::EXPORT);
    
    napi_queue_async_work(env, asyncPlayer->work);
    return asyncPlayer->promise;
}

static napi_value Play(napi_env env, napi_callback_info info)
{   
    
    AsyncPlayer* asyncPlayer = AsyncWork::CreateAsyncPlayer(env, PLAYER_COMMAND::PLAY);
    
    napi_queue_async_work(env, asyncPlayer->work);
    return asyncPlayer->promise;
}

static napi_value Pause(napi_env env, napi_callback_info info)
{
    AsyncPlayer* asyncPlayer = AsyncWork::CreateAsyncPlayer(env, PLAYER_COMMAND::PAUSE);
    
    napi_queue_async_work(env, asyncPlayer->work);
    return asyncPlayer->promise;
}

static napi_value Stop(napi_env env, napi_callback_info info)
{
    AsyncPlayer* asyncPlayer = AsyncWork::CreateAsyncPlayer(env, PLAYER_COMMAND::STOP);
    
    napi_queue_async_work(env, asyncPlayer->work);
    return asyncPlayer->promise;
} 

static napi_value PlayFromStart(napi_env env, napi_callback_info info)
{   
    AsyncPlayer* asyncPlayer = AsyncWork::CreateAsyncPlayer(env, PLAYER_COMMAND::PLAY_FROM_START);
    
    napi_queue_async_work(env, asyncPlayer->work);
    return asyncPlayer->promise;
} 

static napi_value MuteVideo(napi_env env, napi_callback_info info)
{   
    size_t argc = 1;    
    napi_value args[1] = {nullptr};
    
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    bool muted = JsToBool(env, args[0]);
    
    Interface::MuteVideo(muted);
    
    return ToJsUndefined(env);
} 

static napi_value SetCanvasSize(napi_env env, napi_callback_info info)
{   
    size_t argc = 2;    
    napi_value args[2] = {nullptr};
    
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    int32_t height = JsToInt32(env, args[0]);
    int32_t width = JsToInt32(env, args[1]);
    
    Interface::SetCanvasSize(height, width);
    
    return ToJsUndefined(env);
} 

static napi_value GetDrawableArea(napi_env env, napi_callback_info info)
{
    napi_value res;
    napi_create_array_with_length(env, 4, &res);
    std::vector<std::pair<uint32_t, uint32_t>> points = Interface::GetDrawableArea(); 
    if (points.size() == 0) {
        return ToJsUndefined(env);
    }
    for (int32_t i=0; i<4; i++) {
        napi_value jsPoint;
        napi_create_object(env, &jsPoint);
        int32_t x = static_cast<int32_t>(points[i].first);
        int32_t y = static_cast<int32_t>(points[i].second);
        napi_set_named_property(env, jsPoint, "x", ToJsInt(env, x));
        napi_set_named_property(env, jsPoint, "y", ToJsInt(env, y));
        napi_set_element(env, res, i, jsPoint);
    }
    return res;
}


EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"SetVideo", nullptr, SetVideo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"SetBgAudio", nullptr, SetBgAudio, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"AddImage", nullptr, AddImage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"RemoveImage", nullptr, RemoveImage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"UnsetBgAudio", nullptr, UnsetBgAudio, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"InitEditor", nullptr, InitEditor, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"DestroyEditor", nullptr, DestroyEditor, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"SetTrim", nullptr, SetTrim, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"GetDuration", nullptr, GetDuration, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"GetOriginalDuration", nullptr, GetOriginalDuration, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"MoveImage", nullptr, MoveImage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"ScaleImage", nullptr, ScaleImage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"RotateImage", nullptr, RotateImage, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"Export", nullptr, Export, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"Play", nullptr, Play, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"Pause", nullptr, Pause, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"Stop", nullptr, Stop, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"PlayFromStart", nullptr, PlayFromStart, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"MuteVideo", nullptr, MuteVideo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"SetCanvasSize", nullptr, SetCanvasSize, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"GetDrawableArea", nullptr, GetDrawableArea, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"PushImageTop", nullptr, PushImageTop, nullptr, nullptr, nullptr, napi_default, nullptr}
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return Interface::_Init(env, exports);
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "veditor",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterVeditorModule(void)
{
    napi_module_register(&demoModule);
}
