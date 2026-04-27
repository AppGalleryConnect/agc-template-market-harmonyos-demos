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

#ifndef ARDEMO_WORLD_AR_FILE_MANAGER_H
#define ARDEMO_WORLD_AR_FILE_MANAGER_H

#include "ar/ar_engine_core.h"
#include <string>

using namespace std;
namespace ARWorld {
class WorldFileManager {
public:
    WorldFileManager() = default;
    ~WorldFileManager() = default;

    char mRootPath[128] = "";
    // Path you want to save image database
    char mImageDataBasePath[120] = "";
    // File path you want to save image database
    char mImageDataBaseFilePath[255] = "";
    // ImageDatabase file object
    FILE *mImageDataBaseFileObj = nullptr;

    char mImageDataBaseName[120] = "test";

    bool IsFolderExist(const std::string &path);

    /**
     * Save image database information
     * @param arSession  AREngine_ARSession: session object
     * @param mDataBase  AREngine_ARAugmentedImageDatabase: database object
     */
    void SaveImageDataBase(AREngine_ARSession *arSession, AREngine_ARAugmentedImageDatabase *mDataBase);
};

} // namespace ARWorld

#endif // ARDEMO_WORLD_AR_FILE_MANAGER_H
