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

#include "global.h"
#include "napi_manager.h"
#include "native_common.h"
#include "utils/log.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 * function for module exports
 */
EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"init", nullptr, Global::Init, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"start", nullptr, NapiManager::NapiOnPageAppear, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"show", nullptr, NapiManager::NapiOnPageShow, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"hide", nullptr, NapiManager::NapiOnPageHide, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"update", nullptr, NapiManager::NapiOnPageUpdate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"stop", nullptr, NapiManager::NapiOnPageDisappear, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getDistance", nullptr, NapiManager::NapiGetDistance, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getVolume", nullptr, NapiManager::NapiGetVolume, nullptr, nullptr, nullptr, napi_default, nullptr}
    };
    NAPI_CALL(env, napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc));
    bool ret = NapiManager::GetInstance()->Export(env, exports);
    if (!ret) {
        LOGE("Failed to init module.");
    }
    return exports;
}
EXTERN_C_END

// Napi Module define
static napi_module appNapiModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

// Module register function
extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&appNapiModule); }

#ifdef __cplusplus
}
#endif
