/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READKIT_CHAPTER_H
#define READKIT_CHAPTER_H

#include "string"

using namespace std;

class Chapter {
public:
private:
public:
    Chapter(const string &id, const string &title, const string &content);

    const string &GetId() const;

    void SetId(const string &id);

    const string &GetTitle() const;

    void SetTitle(const string &title);

    const string &GetContent() const;

    void SetContent(const string &content);

private:
    string id;
    string title;
    string content;
};


#endif //READKIT_CHAPTER_H
