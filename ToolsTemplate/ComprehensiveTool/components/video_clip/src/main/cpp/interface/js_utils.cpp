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

#include "js_utils.h"

std::string JsToString(napi_env env, napi_value value)
{
    size_t len = 0;
    napi_get_value_string_utf8(env, value, nullptr, 0, &len);
    std::string res(len, '\0');
    // c11开始，std::string.data() 返回const char*， 这里去const。
    napi_get_value_string_utf8(env, value, const_cast<char*>(res.data()), len+1, &len);
    return res;
}

int32_t JsToInt32(napi_env env, napi_value value)
{
    int32_t res;
    napi_get_value_int32(env, value, &res);
    return res;
}

bool JsToBool(napi_env env, napi_value value)
{
    bool res;
    napi_get_value_bool(env, value, &res);
    return res;
}

napi_value ToJsUndefined(napi_env env)
{
    napi_value res;
    napi_get_undefined(env, &res);
    return res;
}

napi_value ToJsString(napi_env env, const std::string &value)
{
    napi_value res;
    napi_create_string_utf8(env, value.c_str(), value.length(), &res);
    return res;
}

int32_t GetFd(napi_env env, napi_value value) {
    int32_t fd;
    if (napi_get_value_int32(env, value, &fd) != napi_ok) {
        return -1; 
    }
    return fd >= 0 ? fd : -1;
}

uint64_t JsToInt64(napi_env env, napi_value value)
{
    int64_t res;
    napi_get_value_int64(env, value, &res);
    return static_cast<uint64_t>(res);
}

napi_value ToJsInt(napi_env env, int32_t value)
{
    napi_value res;
    napi_create_int32(env, value, &res);
    return res;
}

napi_value ToJsInt(napi_env env, uint64_t value)
{
    napi_value res;
    napi_create_int64(env, static_cast<int64_t>(value), &res);
    return res;
}

napi_value ToJsFloat(napi_env env, float value)
{
    napi_value res;
    napi_create_double(env, static_cast<double>(value), &res);
    return res;
}

float JsToFloat(napi_env env, napi_value value)
{
    double res;
    napi_get_value_double(env, value, &res);
    return res;
}
