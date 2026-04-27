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

#ifndef GLOBAL_H_
#define GLOBAL_H_

#include <napi/native_api.h>
#include <rawfile/raw_file_manager.h>

class Global {
public:
    static napi_value Init(napi_env env, napi_callback_info info);

    static NativeResourceManager *mNativeResMgr;
};

#endif // GLOBAL_H_
