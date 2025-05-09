/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READ_CATALOG_H
#define READ_CATALOG_H

#include "string"
#include "utils/t_napi_helper.h"
#include <js_native_api_types.h>

using namespace std;

class Catalog {
public:
    Catalog(string id, string title, int catalogIndex)
    {
        this->title = title;
        this->id = id;
        this->index = catalogIndex;
    }

private:
    string title;
    int index;
    string id;

public:
    int GetIndex();

    void SetIndex(int catalogIndex);

    string GetTitle();

    void SetTitle(string title);

    string GetId();

    void SetId(string id);

    napi_value ToNs(napi_env env);
};

#endif // READ_CATALOG_H
