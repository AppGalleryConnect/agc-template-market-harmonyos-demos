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

#ifndef HMCFILE_H
#define HMCFILE_H

#include <rawfile/raw_file.h>
#include <string>

class app_file {
public:
    typedef enum {
        HMC_FILE_READ,  // Read only
        HMC_FILE_WRITE, // Write only, if the file does not exist, the open fails
        HMC_FILE_CREATE // Create a file. If the file already exists, overwrite it and truncate its length to 0
    } Mode;

public:
    app_file();

    virtual ~app_file();

public:
    int32_t Open(const std::string &filePath, Mode mode = HMC_FILE_READ);

    int32_t Read(void *buffer, uint32_t size);

    int64_t GetSize();

    void Close();

private:
    int32_t m_fd;
    std::string m_filePath;
    RawFileDescriptor m_descriptor;
    std::shared_ptr<RawFile> m_rawFile{nullptr};
};

#endif // HMCFILE_H
