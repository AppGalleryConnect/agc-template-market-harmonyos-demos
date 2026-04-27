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

#ifndef VEDITOR_JS_UTILS_H
#define VEDITOR_JS_UTILS_H
#include "napi/native_api.h"
#include <string>

std::string JsToString(napi_env env, napi_value value);
int32_t JsToInt32(napi_env env, napi_value value);
uint64_t JsToInt64(napi_env env, napi_value value); //这里从int64_t转成了uint64_t，可能有问题
float JsToFloat(napi_env env, napi_value value);
bool JsToBool(napi_env env, napi_value value);
int32_t GetFd(napi_env env, napi_value value);

napi_value ToJsString(napi_env env, const std::string& value);
napi_value ToJsInt(napi_env env, int32_t value);
napi_value ToJsInt(napi_env env, uint64_t value);
napi_value ToJsUndefined(napi_env env);
napi_value ToJsFloat(napi_env env, float value);

void CallProcess(napi_env env, napi_value func, napi_value thisArg, float progress);
void CallEnd(napi_env env, napi_value func, napi_value thisArg);
#endif //MYAPPLICATION_JS_UTILS_H
