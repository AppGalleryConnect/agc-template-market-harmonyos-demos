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

#include "asyncwork.h"
#include "index.h"
#include "js_utils.h"

AsyncPlayer* AsyncWork::CreateAsyncPlayer(napi_env env, PLAYER_COMMAND command)
{
    AsyncPlayer* asyncPlayer = new AsyncPlayer();
    napi_status status;
    napi_value promise;
    napi_deferred deferred;
    
    status = napi_create_promise(env, &deferred, &promise);
    if (status != napi_status::napi_ok) {
        delete asyncPlayer;
        napi_throw_error(env, "ERR", "Create promise failed.");
        return nullptr;
    }
    
    asyncPlayer->deferred = deferred;
    asyncPlayer->promise = promise;
    asyncPlayer->command = command;
    
    status = napi_create_async_work(
        env, 
        nullptr, 
        ToJsString(env, "async player"), 
        [](napi_env env, void* data) {
            AsyncPlayer* asyncPlayer = (AsyncPlayer*)(data);
            PLAYER_COMMAND command = asyncPlayer->command;
            VEditorStatus status; // 因为编解码运行过程中是无返回码的，这里返回码只表明启动编解码是否成功，不能保证运行一定正常
            
            // 根据操作码调用函数
            if (command == PLAYER_COMMAND::PLAY) {
                status = Interface::Play();
            }
            if (command == PLAYER_COMMAND::PAUSE) {
                status = Interface::Pause();
            }
            if (command == PLAYER_COMMAND::PLAY_FROM_START) {
                status = Interface::PlayFromStart();
            }
            if (command == PLAYER_COMMAND::STOP) {
                status = Interface::Stop();
            }
            if (command == PLAYER_COMMAND::EXPORT) {
                // 导出前先启动暂停，暂停失败直接返回
                Interface::UnsetBgAudio();
                status = Interface::Pause();
            
                if (status == VEditorStatus::STATUS_ERROR) {
                    asyncPlayer->success = false;
                    return;
                }
                status = Interface::Export();
            }
            
            // 设置成功标志
            if(status == VEditorStatus::STATUS_OK) {
                asyncPlayer->success = true;
            } else {
                asyncPlayer->success = false;
            }
            return;
        }, 
        [](napi_env env, napi_status status, void* data) {
            AsyncPlayer* asyncPlayer = (AsyncPlayer*)(data);
            napi_value res;
            if (status != napi_status::napi_ok) {
                napi_create_error(env, nullptr, ToJsString(env, "napi async work failed."), &res);
                napi_reject_deferred(env, asyncPlayer->deferred, res);
            } else if (asyncPlayer->success == true) {
                res = ToJsUndefined(env);
                napi_resolve_deferred(env, asyncPlayer->deferred, res);
            } else {
                napi_create_error(env, nullptr, ToJsString(env, "player task failed."), &res);
                napi_reject_deferred(env, asyncPlayer->deferred, res);
            }
            napi_delete_async_work(env, asyncPlayer->work);
        
            delete asyncPlayer;
        }, 
        asyncPlayer, 
        &(asyncPlayer->work)
    );
    
    if (status != napi_status::napi_ok) {
        delete asyncPlayer;
        napi_throw_error(env, "ERR", "Create async worker failed.");
        return nullptr;
    }
    
    return asyncPlayer;
}
