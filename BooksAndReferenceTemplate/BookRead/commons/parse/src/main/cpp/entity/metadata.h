/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READKIT_METADATA_H
#define READKIT_METADATA_H

#include "string"

using namespace std;

class MetaData {
public:
    const string &GetTitle() const;

    void SetTitle(const string &title);

    const string &GetCreator() const;

    void SetCreator(const string &creator);

    const string &GetLanguage() const;

    void SetLanguage(const string &language);

    const string &GetCoverPath() const;

    void SetCoverPath(const string &coverPath);

private:
    string title;
    string creator;
    string language;
    string coverPath;
};


#endif //READKIT_METADATA_H
