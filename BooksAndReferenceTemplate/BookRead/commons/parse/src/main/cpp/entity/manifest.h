/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READKIT_MANIFEST_H
#define READKIT_MANIFEST_H

#include "string"

using namespace std;

class Manifest {
public:
    const string &GetId() const;

    void SetId(const string &id);

    const string &GetHref() const;

    void SetHref(const string &href);

    const string &GetMediaType() const;

    void SetMediaType(const string &mediaType);

    int GetFlag() const;

    void SetFlag(int mediaFlag);

private:
    string id;
    string href;
    string mediaType;
    int flag; // manifest 类型 0:章节，1:其他，优先搞0
};


#endif //READKIT_MANIFEST_H
