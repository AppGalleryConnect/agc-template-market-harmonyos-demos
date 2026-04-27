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

#include "app_file.h"
#include "fcntl.h"
#include "log.h"
#include <sys/stat.h>
#include <unistd.h>

#define OS_OPEN open
#define OS_READ read
#define OS_WRITE write
#define OS_CLOSE close

app_file::app_file() : m_fd(-1) {}

app_file::~app_file() { Close(); }

int32_t app_file::Open(const std::string &filePath, Mode mode)
{
    // Convert open parameters
    int32_t flag;
    const char *openFileMode;
    switch (mode) {
    case HMC_FILE_READ:
        flag = O_RDONLY;
        openFileMode = "r";
        break;
    case HMC_FILE_WRITE:
        flag = O_WRONLY;
        openFileMode = "w";
        break;
    case HMC_FILE_CREATE:
        flag = O_WRONLY | O_CREAT | O_TRUNC;
        openFileMode = "w";
        break;
    default:
        return -1;
    }

    mode_t old_umask = umask(0);

    m_fd = open(filePath.c_str(), flag, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);

    umask(old_umask);

    if (-1 == m_fd) {
        LOGE("Failed to open file, error %{public}d. (%{public}s).", errno, strerror(errno));
        return -1;
    }

    m_filePath = filePath;
    return 0;
}

int32_t app_file::Read(void *buffer, uint32_t size)
{
    // Check if the file object is already open
    if (-1 == m_fd) {
        return -1;
    }

    int32_t len = (int32_t)OS_READ(m_fd, buffer, size);
    return len;
}

int64_t app_file::GetSize()
{
    // Check if the file object is already open
    if (0 == m_fd) {
        LOGE("Invalid fd.");
        return -1;
    }

    struct stat st;
    int err = fstat(m_fd, &st);
    if (err) {
        LOGE("Failed to stat file, error %d (%s).", errno, strerror(errno));
        return -1;
    }
    return (int64_t)st.st_size;
}

void app_file::Close()
{
    // The HmcFile constructed by the externally passed fd should not be closed (fd)
    if (0 != m_fd && m_filePath.find("fd://") != 0) {
        OS_CLOSE(m_fd);
        m_fd = 0;
        m_filePath.clear();
    }
}
