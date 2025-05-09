/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READ_PAGERECT_H
#define READ_PAGERECT_H


class PageRect {
public:
private:
    float mRowSize; // vp
    float mPadding; // vp
    float mTop; // vp
    float mBottom; // vp
public:
    float GetMRowSize() const;

    void SetMRowSize(float rowSize);

    float GetMPadding() const;

    void SetMPadding(float padding);

    float GetMTop() const;

    void SetMTop(float top);

    float GetMBottom() const;

    void SetMBottom(float bottom);

    PageRect(float mr, float mp, float mt, float mb)
    {
        this->mRowSize = mr;
        this->mPadding = mp;
        this->mTop = mt;
        this->mBottom = mb;
    }
};


#endif //READ_PAGERECT_H
