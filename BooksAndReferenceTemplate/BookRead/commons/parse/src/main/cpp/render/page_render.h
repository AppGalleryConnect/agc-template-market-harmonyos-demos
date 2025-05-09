/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READ_PAGERENDER_H
#define READ_PAGERENDER_H

#include "catalog.h"
#include "entity/page_rect.h"
#include "native_drawing/drawing_canvas.h"
#include "native_drawing/drawing_text_blob.h"
#include "native_drawing/drawing_font.h"
#include <map>
#include <string>
#include "entity/render_entity.h"
#include "chapter.h"

using namespace std;

class PageRender {
public:
    PageRender(int windowHeight, int windowWidth, int fontSize, PageRect *pageRect);

    int LayoutContent(string id, Chapter *c);

    int LayoutContentById(string id);

    int GetTotalNum();

    void Render(OH_Drawing_Canvas *canvas, int number);

    void ModifyFont(int fontSize);

    void ModifyWindowSize(float windowHeight, float windowWidth);

    vector<Catalog *> GetCatalog();

    bool GetIsLoadFinish();

    void SetIsLoadFinish(bool misLoadFinish);

private:
    int LayoutParagraph(string id);

    void BuildTextBlob(vector <uint16_t> curGlyphs, vector <OH_Drawing_Point2D> points);

    void BuildTextGlyphs(string id, string title, string content);

    void BuildCatalog(string id, string title);

    PageRect *pageRect;
    double curY;
    float maxReaderWidth;
    float maxReaderHeight;
    int pageNum;

    map<int, OH_Drawing_TextBlob *> textblobMap;  // 每页的绘制字块
    map<string, RenderEntity *> chapterRenderMap; // 每章的字符数组
    vector<Catalog *> catalog;
    OH_Drawing_Font *font;
    bool isLoadFinish = false;
};


#endif // READ_PAGERENDER_H
