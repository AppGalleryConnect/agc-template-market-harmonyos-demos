/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#include "chapter.h"

const string &Chapter::GetId() const
{
    return id;
}

void Chapter::SetId(const string &id)
{
    Chapter::id = id;
}

const string &Chapter::GetTitle() const
{
    return title;
}

void Chapter::SetTitle(const string &title)
{
    Chapter::title = title;
}

const string &Chapter::GetContent() const
{
    return content;
}

void Chapter::SetContent(const string &content)
{
    Chapter::content = content;
}

Chapter::Chapter(const string &id, const string &title, const string &content) : id(id), title(title),
                                                                                 content(content)
{}
