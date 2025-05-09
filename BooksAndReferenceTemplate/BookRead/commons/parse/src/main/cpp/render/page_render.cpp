/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#include "page_render.h"
#include "iostream"

PageRender::PageRender(int windowHeight, int windowWidth, int fontSize, PageRect *pageRect)
{
    this->pageRect = pageRect;
    this->maxReaderHeight = windowHeight - this->pageRect->GetMBottom();
    this->maxReaderWidth = windowWidth - this->pageRect->GetMPadding() * 2 - fontSize;
    this->curY = this->pageRect->GetMRowSize();
    this->font = OH_Drawing_FontCreate();
    this->pageNum = 1;
    OH_Drawing_FontSetTextSize(this->font, fontSize);
}

int PageRender::LayoutContent(string id, Chapter *c)
{
    if (c == nullptr) {
        return 0;
    }
    string content = c->GetContent();
    string title = c->GetTitle();
    if (content == "" || content[0] == '\n') {
        return 0;
    }

    // 重排版
    BuildTextGlyphs(id, title, content);
    int count = this->LayoutParagraph(id);
    return count;
}

int PageRender::LayoutContentById(string id)
{
    // 重新绘制当前 id
    return this->LayoutParagraph(id);
}

void PageRender::ModifyFont(int fontSize)
{
    this->pageNum = 1;
    this->curY = this->pageRect->GetMRowSize();
    // 目录重排
    this->catalog.clear();
    OH_Drawing_FontSetTextSize(this->font, fontSize);
}

void PageRender::ModifyWindowSize(float windowHeight, float windowWidth)
{
    float fontSize = OH_Drawing_FontGetTextSize(this->font);
    this->pageNum = 1;
    this->maxReaderHeight = windowHeight - this->pageRect->GetMBottom();
    this->maxReaderWidth = windowWidth - this->pageRect->GetMPadding() * 2 - fontSize;
    this->curY = this->pageRect->GetMRowSize();
    // 目录重排
    this->catalog.clear();
    OH_Drawing_FontSetTextSize(this->font, fontSize);
}

int PageRender::GetTotalNum()
{ return this->pageNum; }

void PageRender::Render(OH_Drawing_Canvas *canvas, int number)
{
    OH_Drawing_TextBlob *textBlob = this->textblobMap[number];
    if (textBlob != nullptr) {
        OH_Drawing_CanvasDrawTextBlob(canvas, textBlob, 0, this->pageRect->GetMTop());
    }
}

int PageRender::LayoutParagraph(string id)
{
    double preLineWidth = 0; // 前序字符总宽度
    double curLineWidth = 0; // 当前字符总宽度
    int contentNum = this->pageNum;
    vector <OH_Drawing_Point2D> points;
    vector <uint16_t> curGlyphs; // 当前字符数组
    RenderEntity *e = this->chapterRenderMap[id];
    if (e == nullptr) {
        return contentNum;
    }
    vector<int> pageIndex;
    int textCount = e->GetTextCount();
    vector <uint16_t> glyphs = e->GetGlyphs();

    float textWidth[textCount]; // 总字宽数组
    OH_Drawing_FontGetWidths(this->font, glyphs.data(), textCount, textWidth);

    for (int i = 0; i < textCount; i++) {
        // 获取当前字符和字符数组的宽度
        uint16_t glyph = glyphs[i];

        if (this->curY > this->maxReaderHeight) {
            // 换页
            this->BuildTextBlob(curGlyphs, points);
            points.clear();
            curGlyphs.clear();
            curLineWidth = 0;
            preLineWidth = 0;
            pageIndex.push_back(curGlyphs.size());
            this->curY = this->pageRect->GetMRowSize();
        }

        // 更新位置
        curGlyphs.push_back(glyph);
        OH_Drawing_Point2D p;
        p.x = curLineWidth;
        p.y = this->curY;
        points.push_back(p);
        preLineWidth = curLineWidth;
        // 下一个字符的起始位置，为当前字符长度
        curLineWidth += textWidth[i];

        if ((preLineWidth < this->maxReaderWidth && curLineWidth > this->maxReaderWidth) || glyph == 0) {
            // 换行
            curLineWidth = 0;
            preLineWidth = 0;
            this->curY += this->pageRect->GetMRowSize(); // 更新 Y 坐标
        }
    }

    // 处理最后一行
    if (curGlyphs.size() > 0 || this->curY != this->pageRect->GetMRowSize()) {
        this->BuildTextBlob(curGlyphs, points);
        pageIndex.push_back(curGlyphs.size());
    }

    // 还原 Y 坐标
    this->curY = this->pageRect->GetMRowSize();
    // 更新章节每页字数
    this->chapterRenderMap[id]->SetPageIndex(pageIndex);
    // 更新章节结束编号
    this->chapterRenderMap[id]->SetEnd(this->pageNum);
    // 更新目录数组
    this->BuildCatalog(id, e->GetTitle());
    // 返回当前内容的起始章节
    return contentNum;
}

void PageRender::BuildTextGlyphs(string id, string title, string content)
{
    int textCount = OH_Drawing_FontCountText(this->font, content.data(), content.size(), TEXT_ENCODING_UTF8);

    uint16_t glyphs[textCount]; // 总字符数组
    // 获取字符数组的宽度
    OH_Drawing_FontTextToGlyphs(this->font, content.data(), content.size(), TEXT_ENCODING_UTF8, glyphs, textCount);

    RenderEntity *e = new RenderEntity();
    vector <uint16_t> v(glyphs, glyphs + textCount);

    e->SetGlyphs(v);
    e->SetId(id);
    e->SetTextCount(textCount);
    e->SetStart(this->pageNum);
    e->SetTitle(title);

    this->chapterRenderMap[id] = e;
}

void PageRender::BuildTextBlob(vector <uint16_t> curGlyphs, vector <OH_Drawing_Point2D> points)
{
    // 是否可以使用 OH_Drawing_TextBlobBuilderMake 创建 textblob
    OH_Drawing_TextBlobBuilder *builder = OH_Drawing_TextBlobBuilderCreate();
    size_t textCount = curGlyphs.size();
    const OH_Drawing_RunBuffer *runBuffer =
            OH_Drawing_TextBlobBuilderAllocRunPos(builder, this->font, textCount, nullptr);
    for (size_t idx = 0; idx < textCount; idx++) {
        runBuffer->glyphs[idx] = curGlyphs[idx];
        OH_Drawing_Point2D point = points[idx];
        runBuffer->pos[idx * 2] = point.x;
        runBuffer->pos[idx * 2 + 1] = point.y;
    }

    // 通过文本构造器创建文本
    OH_Drawing_TextBlob *tb = OH_Drawing_TextBlobBuilderMake(builder);
    // 释放内存
    OH_Drawing_TextBlobBuilderDestroy(builder);
    this->textblobMap[this->pageNum] = tb;
    this->pageNum += 1;
}

void PageRender::BuildCatalog(string id, string title)
{
    Catalog *c = new Catalog(id, title, this->pageNum - 1); // 存放当前章节的最后一页
    this->catalog.push_back(c);
}

vector<Catalog *> PageRender::GetCatalog()
{ return this->catalog; }

bool PageRender::GetIsLoadFinish()
{ return this->isLoadFinish; }

void PageRender::SetIsLoadFinish(bool misLoadFinish)
{ this->isLoadFinish = misLoadFinish; }