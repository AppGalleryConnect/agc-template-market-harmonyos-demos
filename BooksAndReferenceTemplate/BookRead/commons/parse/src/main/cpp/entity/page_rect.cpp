/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#include "page_rect.h"

float PageRect::GetMRowSize() const
{
    return mRowSize;
}

void PageRect::SetMRowSize(float rowSize)
{
    PageRect::mRowSize = rowSize;
}

float PageRect::GetMPadding() const
{
    return mPadding;
}

void PageRect::SetMPadding(float padding)
{
    PageRect::mPadding = padding;
}

float PageRect::GetMTop() const
{
    return mTop;
}

void PageRect::SetMTop(float top)
{
    PageRect::mTop = top;
}

float PageRect::GetMBottom() const
{
    return mBottom;
}

void PageRect::SetMBottom(float bottom)
{
    PageRect::mBottom = bottom;
}
