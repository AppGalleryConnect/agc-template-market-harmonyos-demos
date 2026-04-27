/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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

#include "napi_manager.h"
#include "depth/depth_ar_application.h"
#include "image/image_ar_application.h"
#include "mesh/mesh_ar_application.h"
#include "semanticdense/semanticdense_ar_application.h"
#include "utils/log.h"
#include "world/world_ar_application.h"
#include <cstdint>
#include <cstdio>
#include <iomanip>
#include <sstream>
#include <string>

enum class ContextType {
    APP_LIFECYCLE = 0,
    JS_PAGE_LIFECYCLE,
};

NapiManager NapiManager::manager_;

void NapiManager::OnSurfaceCreatedCB(OH_NativeXComponent *component, void *window)
{
    LOGD("OnSurfaceCreatedCB");
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto app = NapiManager::GetInstance()->GetApp(id);
    app->OnSurfaceCreated(component, window);
}

void NapiManager::OnSurfaceChangedCB(OH_NativeXComponent *component, void *window)
{
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto app = NapiManager::GetInstance()->GetApp(id);
    app->OnSurfaceChanged(component, window);
}

void NapiManager::OnSurfaceDestroyedCB(OH_NativeXComponent *component, void *window)
{
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }

    std::string id(idStr);
    auto app = NapiManager::GetInstance()->GetApp(id);
    app->OnSurfaceDestroyed(component, window);
    NapiManager::GetInstance()->Release(id);
}

void NapiManager::DispatchTouchEventCB(OH_NativeXComponent *component, void *window)
{
    LOGD("DispatchTouchEventCB");
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }
    std::string id(idStr);
    auto app = NapiManager::GetInstance()->GetApp(id);
    app->DispatchTouchEvent(component, window);
}

void NapiManager::DispatchMouseEventCB(OH_NativeXComponent *component, void *window)
{
    LOGD("DispatchMouseEventCB");
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }
    std::string id(idStr);
    auto app = NapiManager::GetInstance()->GetApp(id);
    app->DispatchMouseEvent(component, window);
}

NapiManager::NapiManager()
{
    callback_.OnSurfaceCreated = NapiManager::OnSurfaceCreatedCB;
    callback_.OnSurfaceChanged = NapiManager::OnSurfaceChangedCB;
    callback_.OnSurfaceDestroyed = NapiManager::OnSurfaceDestroyedCB;
    callback_.DispatchTouchEvent = NapiManager::DispatchTouchEventCB;
    mouseEventcallback_.DispatchMouseEvent = NapiManager::DispatchMouseEventCB;
}

bool NapiManager::Export(napi_env env, napi_value exports)
{
    napi_status status;
    napi_value exportInstance = nullptr;
    OH_NativeXComponent *nativeXComponent = nullptr;
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;

    status = napi_get_named_property(env, exports, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance);
    if (status != napi_ok) {
        LOGE("NapiManager::Export fail 0.");
        return false;
    }

    status = napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent));
    if (status != napi_ok) {
        LOGE("NapiManager::Export fail 1: %{public}d.", status);
        return false;
    }

    ret = OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        LOGE("NapiManager::Export fail 2.");
        return false;
    }

    std::string id(idStr);
    NapiManager *context = NapiManager::GetInstance();
    if (context == nullptr) {
        LOGE("NapiManager::Export fail 3.");
        return false;
    }

    context->SetNativeXComponent(id, nativeXComponent);
    context->GetApp(id);

    return true;
}

void NapiManager::SetNativeXComponent(std::string &id, OH_NativeXComponent *nativeXComponent)
{
    LOGD("NapiManager::SetNativeXComponent");
    if (nativeXComponentMap_.find(id) == nativeXComponentMap_.end() || nativeXComponentMap_[id] != nativeXComponent) {
        nativeXComponentMap_[id] = nativeXComponent;
        OH_NativeXComponent_RegisterCallback(nativeXComponent, &callback_);
        OH_NativeXComponent_RegisterMouseEventCallback(nativeXComponent, &mouseEventcallback_);
    }
}

AppNapi *NapiManager::GetApp(std::string &id)
{
    if (appNapiMap_.find(id) == appNapiMap_.end()) {
        AppNapi *instance = CreateApp(id);
        appNapiMap_[id] = instance;
        return instance;
    } else {
        return appNapiMap_[id];
    }
}

void NapiManager::Release(const std::string &id)
{
    if (appNapiMap_.find(id) != appNapiMap_.end()) {
        delete appNapiMap_[id];
        appNapiMap_.erase(id);
    }
}

napi_value NapiManager::NapiOnPageAppear(napi_env env, napi_callback_info info)
{
    LOGD("NapiManager::NapiOnPageAppear");

    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    size_t resultSize = 0;
    napi_get_value_string_utf8(env, args[0], idStr, OH_XCOMPONENT_ID_LEN_MAX + 1, &resultSize);
    std::string id(idStr);

    // Get the incoming array typedarray to generate input_buffer
    napi_typedarray_type type; // data type
    napi_value input_buffer;
    size_t byte_offset; // data offset
    size_t length;
    napi_get_typedarray_info(env, args[1], &type, &length, NULL, &input_buffer, &byte_offset);

    AppNapi::ConfigParams params{};
    if (type == napi_int32_array) {
        // Get array data
        void *data;
        size_t byte_length;
        napi_get_arraybuffer_info(env, input_buffer, &data, &byte_length);
        int32_t *data_bytes = (int32_t *)(data);
        int32_t num = length / sizeof(int32_t);
        for (int32_t i = 0; i + 1 < num; i += 2) {
            int32_t key = *(data_bytes + i);
            int32_t value = *(data_bytes + i + 1);
            if (key == AppNapi::DEPTH_RENDER_MODE) {
                params.depthRenderMode = value;
            } else if (key == AppNapi::ROTATION) {
                params.rotation = value;
            } else if (key == AppNapi::SEMANTICDENSEMODE) {
                params.semanticDenseMode = value;
            }
        }
    }
    AppNapi *app = NapiManager::GetInstance()->GetApp(id);
    app->OnStart(params);

    return nullptr;
}

napi_value NapiManager::NapiOnPageShow(napi_env env, napi_callback_info info)
{
    LOGD("NapiManager::NapiOnPageShow");

    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    size_t resultSize = 0;
    napi_get_value_string_utf8(env, args[0], idStr, OH_XCOMPONENT_ID_LEN_MAX + 1, &resultSize);
    std::string id(idStr);
    AppNapi *app = NapiManager::GetInstance()->GetApp(id);
    app->OnResume();

    return nullptr;
}

napi_value NapiManager::NapiOnPageHide(napi_env env, napi_callback_info info)
{
    LOGD("NapiManager::NapiOnPageHide");

    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    size_t resultSize = 0;
    napi_get_value_string_utf8(env, args[0], idStr, OH_XCOMPONENT_ID_LEN_MAX + 1, &resultSize);

    std::string id(idStr);
    AppNapi *app = NapiManager::GetInstance()->GetApp(id);
    app->OnPause();

    return nullptr;
}

napi_value NapiManager::NapiOnPageUpdate(napi_env env, napi_callback_info info)
{
    LOGD("NapiManager::NapiOnPageUpdate");

    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    size_t resultSize = 0;
    napi_get_value_string_utf8(env, args[0], idStr, OH_XCOMPONENT_ID_LEN_MAX + 1, &resultSize);

    std::string id(idStr);
    AppNapi *app = NapiManager::GetInstance()->GetApp(id);
    app->OnUpdate();
    if (id == std::string("ARWorld")) {
        napi_value res;
        napi_create_int32(env, ARWorld::WorldRenderManager::mPlaneCount, &res);
        return res;
    }

    return nullptr;
}

napi_value NapiManager::NapiOnPageDisappear(napi_env env, napi_callback_info info)
{
    LOGD("NapiManager::NapiOnPageDisappear");

    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    size_t resultSize = 0;
    napi_get_value_string_utf8(env, args[0], idStr, OH_XCOMPONENT_ID_LEN_MAX + 1, &resultSize);

    std::string id(idStr);
    AppNapi *app = NapiManager::GetInstance()->GetApp(id);
    app->OnStop();

    return nullptr;
}

napi_value NapiManager::NapiGetDistance(napi_env env, napi_callback_info info)
{
    LOGD("NapiManager::NapiGetCameraPose");

    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    size_t resultSize = 0;
    napi_get_value_string_utf8(env, args[0], idStr, OH_XCOMPONENT_ID_LEN_MAX + 1, &resultSize);

    std::string id(idStr);
    AppNapi *app = NapiManager::GetInstance()->GetApp(id);
    std::string distance = app->GetDistance();

    std::ostringstream distanceString;
    distanceString << std::setiosflags(std::ios::fixed) << std::setiosflags(std::ios::right) << std::setprecision(4)
                   << distance << std::endl;

    napi_value ret = nullptr;
    std::string result = distanceString.str();
    napi_create_string_utf8(env, result.c_str(), result.length(), &ret);

    return ret;
}

napi_value NapiManager::NapiGetVolume(napi_env env, napi_callback_info info) {
    LOGD("NapiManager::NapiGetVolume");

    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    size_t resultSize = 0;
    napi_get_value_string_utf8(env, args[0], idStr, OH_XCOMPONENT_ID_LEN_MAX + 1, &resultSize);

    std::string id(idStr);
    AppNapi *app = NapiManager::GetInstance()->GetApp(id);
    std::string volume = app->GetVolume();
    LOGE("NapiManager::NapiGetVolume volume is:%{public}s", volume.c_str());

    std::ostringstream distanceString;
    distanceString << setiosflags(ios::fixed) << setiosflags(ios::right) << setprecision(4)  <<volume << std::endl;

    napi_value ret = nullptr;
    string result = distanceString.str();
    napi_create_string_utf8(env, result.c_str(), result.length(), &ret);

    return ret;
}

// Create a service implementation class based on the service ID.
AppNapi *NapiManager::CreateApp(std::string &id)
{
    std::string scene;
    auto currentTime = std::chrono::system_clock::now();
    auto currentiTime_ms = std::chrono::time_point_cast<std::chrono::milliseconds>(currentTime);
    auto valueMs = currentiTime_ms.time_since_epoch().count();
    int len = std::to_string(valueMs).length();

    if(id.length() >= len) {
        scene = id.substr(len);
        LOGE("NapiManager::Before CreateApp is:%{public}s", scene.c_str());
    }
    
    if (scene == std::string("ARWorld")) {
        return new ARWorld::ARWorldApp(scene);
    }
    if (scene == std::string("ARDepth")) {
        return new ARDepth::ARDepthApp(scene);
    }
    if (scene == std::string("ARMesh")) {
        return new ARMesh::ARMeshApp(scene);
    }
    if (scene == std::string("ARImage")) {
        return new ARImage::ARImageApp(scene);
    }
    if (scene == std::string("ARSemanticDense")) {
        return new ARSemanticDense::ArSemanticDenseApp(scene);
    }
    return nullptr;
}
