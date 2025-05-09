/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READ_EPUBMANAGER_H
#define READ_EPUBMANAGER_H

#include "page_rect.h"
#include "parse/epub_parser.h"
#include "render/page_render.h"

using namespace std;

class EpubManager {
public:
    ~EpubManager();

    void Init(float mwindowWidth, float mwindowHeight, PageRect *mrect, float mfontSize);

    EpubParser *GetEpubParser(string name);

    void SetEpubParser(string name, string path);

    int LoadEpubChapter(string name);

    int ModifyFont(string name, int pageNum, int mfontSize);

    int ModifyWindowSize(string name, float windowHeight, float windowWidth, int pageNum);

    void DrawEpubPage(string name, int id, OH_Drawing_Canvas *canvas);

    int GetEpubPageTotal(string name);

    vector<Catalog *> GetCatalog(string name);

    static EpubManager *GetInstance()
    {
        static EpubManager instance;
        return &instance;
    }

private:
    static EpubManager *epubManager;
    PageRect *rect;
    float windowHeight;
    float windowWidth;
    float fontSize;
    map<string, EpubParser *> parserMgt;
    map<string, PageRender *> renderMgt;
};

#endif // READ_EPUBMANAGER_H