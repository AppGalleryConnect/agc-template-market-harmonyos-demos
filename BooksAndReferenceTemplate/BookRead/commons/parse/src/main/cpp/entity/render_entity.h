/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READ_RENDER_ENTITY_H
#define READ_RENDER_ENTITY_H

#include <string>

using namespace std;

class RenderEntity {
public:
private:
    string id; // 渲染资源 id
    string title;
    int startPage; // 起始页 -- 与字号有关
    int endPage;   // 结束页 -- 与字号有关
    int fontSize; // 字号
    int textCount;    // 渲染字数
    vector <uint16_t> glyphs; // 渲染资源
    vector<int> pageIndex; // 每个页面的字数 
public:
    int GetTextCount();

    void SetTextCount(int tc);

    vector <uint16_t> GetGlyphs();

    void SetGlyphs(vector <uint16_t> glyphs);

    string GetId();

    void SetId(string id);

    int GetFontSize();

    void SetFontSize(int ft);

    int GetEnd();

    void SetEnd(int end);

    int GetStart();

    void SetStart(int start);

    vector<int> GetPageIndex();

    void SetPageIndex(vector<int> pageIndex);

    string GetTitle();

    void SetTitle(string title);
};

#endif //READ_RENDER_ENTITY_H
