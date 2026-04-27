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

#include "utils.h"
#include <iomanip>
#include <random>
#include <sstream>
#include <chrono>
#include <iostream>
#include <filemanagement/file_uri/oh_file_uri.h>
#include <multimedia/player_framework/native_avformat.h>
#include <multimedia/player_framework/native_avcodec_base.h>

std::string GenerateUniqueId()
{
    auto now = std::chrono::system_clock::now();
    auto timeStamp = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count();
    
    static std::mt19937 rng(std::random_device{}());
    static std::uniform_int_distribution<> dist(1000, 9999);
    
    std::stringstream ss;
    ss << timeStamp << "_" << dist(rng);
    
    return ss.str();
}

std::string GenerateUniqueId(const std::string& tag)
{ 
    return GenerateUniqueId() + "_" + tag;
}

std::string timestamp_filename() {
    auto now = std::chrono::system_clock::now();
    auto time_t = std::chrono::system_clock::to_time_t(now);
    std::tm tm = *std::localtime(&time_t);

    std::ostringstream oss;
    oss << std::put_time(&tm, "%Y-%m-%d_%H-%M-%S") << ".mp4";
    return oss.str();
}

std::string UriToPath(const std::string& fileUri) {
 
    uint32_t length = fileUri.size();
    char* path = nullptr;
    
    FileManagement_ErrCode ret = OH_FileUri_GetPathFromUri(fileUri.c_str(), length ,&path); 
    
    if (ret != 0 && path != nullptr) {
        LOGE("Get Uri failed");
        return "";
    }
    std::string res(path);
    
    if (path != nullptr) {
        free(path);
        path = nullptr;
    }
    return res;
}    

std::string PathToUri(const std::string &path) {
    uint32_t length = path.size();
    char* fileUri = nullptr;
    
    FileManagement_ErrCode ret = OH_FileUri_GetUriFromPath(path.c_str(), length, &fileUri);
    
    if (ret != 0 | fileUri == nullptr) {
        LOGE("Get uri failed");
        return "";
    }
    
    std::string res(fileUri);
    
    if (fileUri == nullptr) {
        free(fileUri);
        fileUri = nullptr;
    }
    return res;
}

std::pair<int, int> convertTo720p(int inputWidth, int inputHeight)
{
    // 校验输入合法性
    if (inputWidth <= 0 || inputHeight <= 0) {
        throw std::invalid_argument("输入分辨率必须为正整数");
    }
    
    int outputWidth, outputHeight;
    
    int shortSide = 720;
    int longSide;

    // 计算输入视频的宽高比（避免浮点数精度问题，用float类型）
    float aspectRatio = static_cast<float>(inputWidth) / inputHeight;

    // 短边720像素
    if (inputHeight < inputWidth) {
        // height 是短边
        longSide = static_cast<int>(std::round(aspectRatio * shortSide));
    } else {
        // height 是长边
        longSide = static_cast<int>(std::round(shortSide / aspectRatio));
    }
    // 可选优化：确保宽度为偶数（部分编码器要求宽高为偶数，避免绿边等异常）
    if (longSide % 2 != 0) {
        longSide += 1; // 偶数化处理（+1或-1均可，此处+1简化逻辑）
    }
        
    /***
    // 固定720P
    // 边界情况处理：若输入宽高比异常（如极端窄或极端宽），限制最大宽度（可选）
    // 例如：限制宽度不超过2560（避免超宽画面），可根据实际需求调整
    const int MAX_LENGTH = 2560;
    if (longSide > MAX_LENGTH) {
        longSide = MAX_LENGTH;
        // 此时高度可能略小于720，重新按宽度比例计算高度（确保比例正确）
        shortSide = static_cast<int>(std::round(longSide / aspectRatio));
        // 再次确保高度为偶数
        if (shortSide % 2 != 0) {
            shortSide += 1;
        }
    }***/
    if (inputWidth > inputHeight) {
        return {longSide, shortSide};
    } else {
        return {shortSide, longSide};
    }
}