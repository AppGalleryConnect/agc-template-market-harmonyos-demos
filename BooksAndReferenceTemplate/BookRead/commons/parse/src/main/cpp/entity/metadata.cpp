/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#include "metadata.h"

const string &MetaData::GetTitle() const
{
    return title;
}

void MetaData::SetTitle(const string &title)
{
    MetaData::title = title;
}

const string &MetaData::GetCreator() const
{
    return creator;
}

void MetaData::SetCreator(const string &creator)
{
    MetaData::creator = creator;
}

const string &MetaData::GetLanguage() const
{
    return language;
}

void MetaData::SetLanguage(const string &language)
{
    MetaData::language = language;
}

const string &MetaData::GetCoverPath() const
{
    return coverPath;
}

void MetaData::SetCoverPath(const string &coverPath)
{
    MetaData::coverPath = coverPath;
}
