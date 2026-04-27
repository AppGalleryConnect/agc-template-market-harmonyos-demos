/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

#ifndef OH_VEF_CODEC_AUDIO_PCM_BUFFER_QUEUE_H
#define OH_VEF_CODEC_AUDIO_PCM_BUFFER_QUEUE_H

#include <queue>
#include <vector>
#include <mutex>
#include "codec_common.h"

class PcmBufferQueue {
public:
    PcmBufferQueue(size_t capacity);
    ~PcmBufferQueue() = default;

    // 入队操作，如果队列满了，则阻塞等待
    void Enqueue(const std::shared_ptr<PcmData>& data);

    // 出队操作，如果队列空了，则阻塞等待
    std::shared_ptr<PcmData> Dequeue();

    void CancelEnqueue();
    void CancelDequeue();

private:
    std::mutex mutex_;
    std::condition_variable condEmpty_;
    std::condition_variable condFull_;
    std::queue<std::shared_ptr<PcmData>> queue_;
    size_t capacity_;
    bool cancelEnqueueFlag_ { false };
    bool cancelDequeueFlag_ { false };
};

#endif