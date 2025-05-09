/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#include "render_entity.h"

int RenderEntity::GetTextCount()
{ return this->textCount; }

void RenderEntity::SetTextCount(int tc)
{ this->textCount = tc; }

vector <uint16_t> RenderEntity::GetGlyphs()
{ return this->glyphs; }

void RenderEntity::SetGlyphs(vector <uint16_t> glyphs)
{ this->glyphs = glyphs; }

string RenderEntity::GetId()
{ return this->id; }

void RenderEntity::SetId(string id)
{ this->id = id; }

int RenderEntity::GetFontSize()
{ return this->fontSize; }

void RenderEntity::SetFontSize(int ft)
{ this->fontSize = ft; }

int RenderEntity::GetEnd()
{ return this->endPage; }

void RenderEntity::SetEnd(int end)
{ this->endPage = end; }

int RenderEntity::GetStart()
{ return this->startPage; }

void RenderEntity::SetStart(int start)
{ this->startPage = start; }

vector<int> RenderEntity::GetPageIndex()
{ return this->pageIndex; }

void RenderEntity::SetPageIndex(vector<int> pageIndex)
{ this->pageIndex = pageIndex; }

string RenderEntity::GetTitle()
{ return this->title; }

void RenderEntity::SetTitle(string title)
{ this->title = title; }