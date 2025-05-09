/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READ_NAPIHELPER_H
#define READ_NAPIHELPER_H

#include "catalog.h"
#include <js_native_api.h>
#include <string>

using namespace std;

class NapiHelper {
public:
    static string ToCStirng(napi_env env, napi_value arg)
    {
        // 默认字符长度 1024
        int cl = 1024;
        char rc[cl];
        size_t len;
        napi_get_value_string_utf8(env, arg, rc, cl, &len);
        return string(rc);
    }

    static int ToCInt(napi_env env, napi_value arg)
    {
        int a;
        napi_get_value_int32(env, arg, &a);
        return a;
    }

    static float ToCFloat(napi_env env, napi_value arg)
    {
        double dv;
        napi_get_value_double(env, arg, &dv);
        float fv = static_cast<float >(dv);
        return fv;
    }

    static napi_value ToNString(napi_env env, string str)
    {
        napi_value result;
        napi_create_string_utf8(env, str.c_str(), NAPI_AUTO_LENGTH, &result);
        return result;
    }

    static napi_value ToNNumber(napi_env env, int number)
    {
        napi_value result;
        napi_create_int32(env, number, &result);
        return result;
    }

    static napi_value ToNSArray(napi_env env, vector <string> data)
    {
        napi_value array;
        napi_create_array(env, &array);

        for (size_t i = 0; i < data.size(); i++) {
            napi_value e = ToNString(env, data[i]);
            napi_set_element(env, array, i, e);
        }

        return array;
    }
};

#endif //READ_NAPIHELPER_H
