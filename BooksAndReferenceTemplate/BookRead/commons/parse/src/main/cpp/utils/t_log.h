/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READ_LOG_H
#define READ_LOG_H

#include <hilog/log.h>

#define LOG_PRINT_DOMAIN 0xFF00
#define APP_LOG_DOMAIN 0x0001
constexpr const char *APP_LOG_TAG = "ReadKit";
#define READ_LOGI(...) ((void)OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, APP_LOG_TAG, __VA_ARGS__))
#define READ_LOGD(...) ((void)OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_DOMAIN, APP_LOG_TAG, __VA_ARGS__))
#define READ_LOGW(...) ((void)OH_LOG_Print(LOG_APP, LOG_WARN, LOG_DOMAIN, APP_LOG_TAG, __VA_ARGS__))
#define READ_LOGE(...) ((void)OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, APP_LOG_TAG, __VA_ARGS__))


#endif  // READ_LOG_H