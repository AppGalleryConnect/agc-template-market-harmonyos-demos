/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#include "catalog.h"

int Catalog::GetIndex()
{ return this->index; }

void Catalog::SetIndex(int catalogIndex)
{ this->index = catalogIndex; }

string Catalog::GetTitle()
{ return this->title; }

void Catalog::SetTitle(string title)
{ this->title = title; }

string Catalog::GetId()
{ return this->id; }

void Catalog::SetId(string id)
{ this->id = id; }

napi_value Catalog::ToNs(napi_env env)
{
    napi_value obj;
    napi_create_object(env, &obj);
    napi_value id = NapiHelper::ToNString(env, this->id);
    napi_value title = NapiHelper::ToNString(env, this->title);
    napi_value catalogIndex = NapiHelper::ToNNumber(env, this->index);

    napi_set_named_property(env, obj, "id", id);
    napi_set_named_property(env, obj, "title", title);
    napi_set_named_property(env, obj, "index", catalogIndex);

    return obj;
}