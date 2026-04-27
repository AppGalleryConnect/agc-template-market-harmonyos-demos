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

#include "world_file_manager.h"
#include "app_file.h"
#include "app_util.h"
#include "world_file_manager.h"
#include <string>
#include <sys/stat.h>

using namespace std;
using namespace std::chrono;

namespace ARWorld {

bool WorldFileManager::IsFolderExist(const std::string &path)
{
    struct stat info;
    char pathC[120];
    sprintf(pathC, "%s", path.c_str());
    if (stat(pathC, &info) != 0) {
        return false;
    } else if (info.st_mode & S_IFDIR) {
        return true;
    } else {
        return false;
    }
}

} // namespace ARWorld
