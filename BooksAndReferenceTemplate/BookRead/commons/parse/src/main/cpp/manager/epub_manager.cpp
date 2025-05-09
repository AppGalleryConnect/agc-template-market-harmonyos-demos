/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#include "epub_manager.h"
#include "utils/t_log.h"
#include "chapter.h"

EpubParser *EpubManager::GetEpubParser(string name)
{
    auto it = parserMgt.find(name);
    if (it == parserMgt.end()) {
        READ_LOGW("%{public}s not exist in parseMgt", name.c_str());
        return nullptr;
    } else {
        return parserMgt[name];
    }
}

void EpubManager::SetEpubParser(string name, string path)
{
    auto pam = parserMgt.find(name);
    if (pam != parserMgt.end()) {
        READ_LOGI("%{public}s exist in parseMgt", name.c_str());
    } else {
        // 1. 初始化解析器
        EpubParser *ep = new EpubParser(path);
        // 2. 解析 opf 文件
        ep->Parse();
        // 3. 存入 map 中
        parserMgt[name] = ep;
    }

    auto per = renderMgt.find(name);
    if (per != renderMgt.end()) {
        READ_LOGI("%{public}s exist in renderMgt", name.c_str());
    } else {
        // 1. 初始化渲染器
        PageRender *pr = new PageRender(this->windowWidth, this->windowHeight, this->fontSize, this->rect);
        // 2. 存入 map
        renderMgt[name] = pr;
    }

    return;
}

int EpubManager::LoadEpubChapter(string name)
{
    auto pam = parserMgt.find(name);
    auto per = renderMgt.find(name);
    if (per == renderMgt.end() || pam == parserMgt.end()) {
        READ_LOGI("%{public}s not exist in parseMgt or renderMgt", name.c_str());
        return 0;
    }

    bool isParse = renderMgt[name]->GetIsLoadFinish();
    if (!isParse) {
        // 加载当前章节的内容
        vector<string> ids = parserMgt[name]->GetChapterList();
        for (string id: ids) {
            Chapter *chapter = parserMgt[name]->ReadChapterContent(id);
            // 重新排版当前页面
            renderMgt[name]->LayoutContent(id, chapter);
        }
        renderMgt[name]->SetIsLoadFinish(true);
    }
    int total = renderMgt[name]->GetTotalNum();

    READ_LOGI("cur book load success %{public}s", name.c_str());
    return total;
}

int EpubManager::ModifyFont(string name, int pageNum, int mfontSize)
{
    auto pam = parserMgt.find(name);
    auto per = renderMgt.find(name);
    if (per == renderMgt.end() || pam == parserMgt.end()) {
        READ_LOGI("%{public}s not exist in renderMgt", name.c_str());
        return 0;
    }

    renderMgt[name]->SetIsLoadFinish(false);
    vector<string> ids = parserMgt[name]->GetChapterList();
    renderMgt[name]->ModifyFont(mfontSize);
    for (string id: ids) {
        renderMgt[name]->LayoutContentById(id);
    }
    int total = renderMgt[name]->GetTotalNum();
    // 检测边界情况
    if (pageNum > total) {
        return total - 1;
    }

    renderMgt[name]->SetIsLoadFinish(true);
    READ_LOGI("cur page modify font %{public}d", pageNum);
    return pageNum;
}

int EpubManager::ModifyWindowSize(string name, float mwindowHeight, float mwindowWidth, int pageNum)
{
    auto pam = parserMgt.find(name);
    auto per = renderMgt.find(name);
    if (per == renderMgt.end() || pam == parserMgt.end()) {
        READ_LOGI("%{public}s not exist in renderMgt", name.c_str());
        return 0;
    }

    this->windowHeight = mwindowHeight;
    this->windowWidth = mwindowWidth;
    renderMgt[name]->SetIsLoadFinish(false);
    vector<string> ids = parserMgt[name]->GetChapterList();
    renderMgt[name]->ModifyWindowSize(mwindowHeight, mwindowWidth);
    for (string id: ids) {
        renderMgt[name]->LayoutContentById(id);
    }
    int total = renderMgt[name]->GetTotalNum();
    // 检测边界情况
    if (pageNum > total) {
        return total - 1;
    }

    renderMgt[name]->SetIsLoadFinish(true);
    READ_LOGI("cur page modify window size %{public}d", pageNum);
    return pageNum;
}

void EpubManager::DrawEpubPage(string name, int number, OH_Drawing_Canvas *canvas)
{
    auto per = renderMgt.find(name);
    if (per == renderMgt.end()) {
        READ_LOGI("%{public}s not exist in parseMgt", name.c_str());
        return;
    }

    renderMgt[name]->Render(canvas, number);
}

int EpubManager::GetEpubPageTotal(string name)
{
    auto per = renderMgt.find(name);
    if (per == renderMgt.end()) {
        READ_LOGI("%{public}s not exist in parseMgt", name.c_str());
        return 0;
    }

    return renderMgt[name]->GetTotalNum();
}

vector<Catalog *> EpubManager::GetCatalog(string name)
{
    auto per = renderMgt.find(name);
    if (per == renderMgt.end()) {
        READ_LOGI("%{public}s not exist in parseMgt", name.c_str());
        return vector<Catalog *>();
    }

    return renderMgt[name]->GetCatalog();
}

void EpubManager::Init(float mwindowWidth, float mwindowHeight, PageRect *mrect, float mfontSize)
{
    this->windowWidth = mwindowWidth;
    this->windowHeight = mwindowHeight;
    this->fontSize = mfontSize;
    this->rect = mrect;
}

EpubManager::~EpubManager()
{
    // 释放资源
    READ_LOGI("success to ~EpubManage");
}