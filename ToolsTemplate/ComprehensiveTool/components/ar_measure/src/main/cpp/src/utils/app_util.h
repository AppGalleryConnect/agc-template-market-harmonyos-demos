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

#ifndef C_ARENGINE_HELLOE_AR_UTIL_H
#define C_ARENGINE_HELLOE_AR_UTIL_H

#include "GLUtils.h"
#include "ar/ar_engine_core.h"
#include <GLES2/gl2.h>
#include <multimedia/image_framework/image/image_common.h>
#include <string>
#include <vector>

#ifndef CHECK
#define SPLIT_FUNC(str) strtok((str), "(")
#define CHECK(condition)                                                                                               \
    do {                                                                                                               \
        auto ret = (condition);                                                                                        \
        if (ret) {                                                                                                     \
            char sentence[] = #condition;                                                                              \
            LOGE("*** CHECK FAILED at %{public}s:%{public}d: %{public}s ret: %{public}d", __FILE__, __LINE__,          \
                 SPLIT_FUNC(sentence), ret);                                                                           \
        }                                                                                                              \
    } while (false);

#ifndef ENABLE_API_STAT
#define CHECK_WITH_API_STAT(condition)                                                                                 \
    do {                                                                                                               \
        auto ret = (condition);                                                                                        \
        if (ret) {                                                                                                     \
            char sentence[] = #condition;                                                                              \
            LOGE("*** CHECK FAILED at %{public}s:%{public}d: %{public}s ret: %{public}d", __FILE__, __LINE__,          \
                 SPLIT_FUNC(sentence), ret);                                                                           \
            abort();                                                                                                   \
        }                                                                                                              \
    } while (false);
#else
#define CHECK_WITH_API_STAT(condition)                                                                                 \
    do {                                                                                                               \
        auto start = std::chrono::high_resolution_clock::now();                                                        \
        auto ret = (condition);                                                                                        \
        auto end = std::chrono::high_resolution_clock::now();                                                          \
        char sentence[] = #condition;                                                                                  \
        if (ret) {                                                                                                     \
            LOGE("*** CHECK FAILED at %{public}s:%{public}d: %{public}s ret: %{public}d", __FILE__, __LINE__,          \
                 SPLIT_FUNC(sentence), ret);                                                                           \
            abort();                                                                                                   \
        }                                                                                                              \
        auto diff = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();                        \
        LOGI("%{public}s cost time is : %{public}lld us", SPLIT_FUNC(sentence), diff);                                 \
    } while (false);
#endif

#define CHECK_WITH_REASON(condition, arSession, arCamera)                                                              \
    do {                                                                                                               \
        auto ret = (condition);                                                                                        \
        if (ret) {                                                                                                     \
            char sentence[] = #condition;                                                                              \
            LOGE("*** CHECK FAILED at %{public}s:%{public}d: %{public}s ret: %{public}d", __FILE__, __LINE__,          \
                 SPLIT_FUNC(sentence), ret);                                                                           \
            AREngine_ARTrackingStateReason cameraTrackingStateReason = ARENGINE_TRACKING_STATE_REASON_NONE;            \
            HMS_AREngine_ARCamera_GetTrackingStateReason(arSession, arCamera, &cameraTrackingStateReason);             \
            if (cameraTrackingStateReason != ARENGINE_TRACKING_STATE_REASON_NONE) {                                    \
                LOGW("tracking Paused, stateReason is:%{public}d", cameraTrackingStateReason);                         \
            }                                                                                                          \
            abort();                                                                                                   \
        }                                                                                                              \
    } while (false);
#endif

using FileInfor = struct {
    std::string fileName;
};

using FileData = struct {
    std::vector<char *> perVertInfoList;
    int i;
};

using DrawTempData = struct {
    std::vector<GLfloat> tempPositions;
    std::vector<GLfloat> tempNormals;
    std::vector<GLfloat> tempUvs;
    std::vector<GLushort> vertexIndices;
    std::vector<GLushort> normalIndices;
    std::vector<GLushort> uvIndices;
};

using ImageBufferData = struct {
    uint8_t *buffer;
    size_t bufferLen;
    uint32_t width;
    uint32_t height;
};

bool LoadPngFromAssetManager(const std::string &path);

/**
 * Load the obj file from the assets folder in the application.
 *
 * @param fileInformation Pointer to the AAssetManager,the name of the obj file.
 * @param outVertices Output vertex.
 * @param outNormals Output normal.
 * @param outUv UV coordinate of the output texture.
 * @param outIndices Output triangular exponent.
 * @return True if obj is loaded correctly, false otherwise.
 */
bool LoadObjFile(FileInfor fileInformation, std::vector<GLfloat> &outVertices, std::vector<GLfloat> &outNormals,
                 std::vector<GLfloat> &outUv, std::vector<GLushort> &outIndices);

void WriteBin(const char *path, uint8_t *data, int32_t size);

static AREngine_ARPoseType ArEngineRotateType(int32_t rotation)
{
    switch (rotation) {
        case 0:
            return ARENGINE_POSE_TYPE_IDENTITY;
        case 1:
            return ARENGINE_POSE_TYPE_ROTATE_270;
        case 2:
            return ARENGINE_POSE_TYPE_ROTATE_180;
        case 3:
            return ARENGINE_POSE_TYPE_ROTATE_90;
    }
    return ARENGINE_POSE_TYPE_IDENTITY;
}

Image_ErrorCode checkImage(AREngine_ARAugmentedImageDatabase *dataBase, const std::string &path);

#endif // C_ARENGINE_HELLOE_AR_UTIL_H
