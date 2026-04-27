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

#ifndef VEDITOR_UTILS_H
#define VEDITOR_UTILS_H

#include <string>

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x1234
#define LOG_TAG "veditor"

#include "hilog/log.h"

#define LOGI(fmt, ...)                                                                                                 \
    do {                                                                                                               \
       OH_LOG_INFO(LOG_APP, "[%{public}s:%{public}d] [%{public}s] " fmt, __FILE__, __LINE__, __func__, ##__VA_ARGS__ );\
    } while (0)

#define LOGE(fmt, ...)                                                                                                 \
    do {                                                                                                               \
       OH_LOG_ERROR(LOG_APP, "[%{public}s:%{public}d] [%{public}s] " fmt, __FILE__, __LINE__, __func__, ##__VA_ARGS__ );\
    } while (0)

#define LOGD(fmt, ...)                                                                                                 \
    do {                                                                                                               \
       OH_LOG_DEBUG(LOG_APP, "[%{public}s:%{public}d] [%{public}s] " fmt, __FILE__, __LINE__, __func__, ##__VA_ARGS__ );\
    } while (0)

class OH_AVFormat;

enum VEditorStatus {
    STATUS_OK = 0,
    STATUS_ERROR = 1
};

std::string GenerateUniqueId();
std::string GenerateUniqueId(const std::string& tag);
std::string UriToPath(const std::string& fileUri);
std::string PathToUri(const std::string& path);
std::pair<int, int> convertTo720p(int inputWidth, int inputHeight);
#endif //AVCODECVIDEO_UTILS_H
