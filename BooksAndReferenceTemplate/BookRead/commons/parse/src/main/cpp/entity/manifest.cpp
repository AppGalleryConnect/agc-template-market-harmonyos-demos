/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#include "manifest.h"

const string &Manifest::GetId() const
{
    return id;
}

void Manifest::SetId(const string &id)
{
    Manifest::id = id;
}

const string &Manifest::GetHref() const
{
    return href;
}

void Manifest::SetHref(const string &href)
{
    Manifest::href = href;
}

const string &Manifest::GetMediaType() const
{
    return mediaType;
}

void Manifest::SetMediaType(const string &mediaType)
{
    Manifest::mediaType = mediaType;
}

int Manifest::GetFlag() const
{
    return flag;
}

void Manifest::SetFlag(int mediaFlag)
{
    Manifest::flag = mediaFlag;
}
