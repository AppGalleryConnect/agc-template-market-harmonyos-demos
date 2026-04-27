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

#ifndef VEDITOR_ASYNCWORK_H
#define VEDITOR_ASYNCWORK_H

#include "napi/native_api.h"
#include <string>

enum PLAYER_COMMAND {
    PLAY = 0,
    PLAY_FROM_START,
    PAUSE,
    STOP,
    EXPORT
};

struct AsyncPlayer {
    napi_async_work work;
    napi_deferred deferred;
    napi_value promise;
    bool success{false}; // 这里的success只能感知到启动相应操作在调用编解码接口时是否成功
    void* data{nullptr};
    PLAYER_COMMAND command{PLAYER_COMMAND::PLAY};
};

namespace AsyncWork{
    AsyncPlayer* CreateAsyncPlayer(napi_env env, PLAYER_COMMAND command);
}

#endif