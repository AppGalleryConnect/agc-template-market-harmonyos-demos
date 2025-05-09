/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#include "napi/native_api.h"
#include "manager/epub_manager.h"
#include "page_rect.h"
#include "string"
#include "utils/t_napi_helper.h"

using namespace std;

static napi_value SetEpub(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    string name = NapiHelper::ToCStirng(env, args[0]);
    string path = NapiHelper::ToCStirng(env, args[1]);
    EpubManager::GetInstance()->SetEpubParser(name, path);
    return nullptr;
}

static napi_value GetChapterIds(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    string name = NapiHelper::ToCStirng(env, args[0]);

    vector<string> ids;
    napi_value napiIds;

    if (EpubManager::GetInstance()->GetEpubParser(name) != nullptr) {
        ids = EpubManager::GetInstance()->GetEpubParser(name)->GetChapterList();
        napiIds = NapiHelper::ToNSArray(env, ids);
    }

    return napiIds;
}

static napi_value GetContentByChapterId(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    string name = NapiHelper::ToCStirng(env, args[0]);
    string id = NapiHelper::ToCStirng(env, args[1]);

    Chapter *c;
    napi_value content;

    if (EpubManager::GetInstance()->GetEpubParser(name) != nullptr) {
        c = EpubManager::GetInstance()->GetEpubParser(name)->GetChapterById(id);
        if (c != nullptr) {
            content = NapiHelper::ToNString(env, c->GetContent());
        }
    }

    return content;
}

static napi_value LoadEpubChapter(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    string name = NapiHelper::ToCStirng(env, args[0]);
    int n = EpubManager::GetInstance()->LoadEpubChapter(name);

    napi_value num = NapiHelper::ToNNumber(env, n);
    return num;
}

static napi_value ModifyFont(napi_env env, napi_callback_info info)
{
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    string name = NapiHelper::ToCStirng(env, args[0]);
    int pageNum = NapiHelper::ToCInt(env, args[1]);
    int fontSize = NapiHelper::ToCInt(env, args[2]);
    int n = EpubManager::GetInstance()->ModifyFont(name, pageNum, fontSize);

    napi_value num = NapiHelper::ToNNumber(env, n);
    return num;
}

static napi_value ModifyWindowSize(napi_env env, napi_callback_info info)
{
    size_t argc = 4;
    napi_value args[4] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    string name = NapiHelper::ToCStirng(env, args[0]);
    int windowHeight = NapiHelper::ToCInt(env, args[1]);
    int windowWidth = NapiHelper::ToCInt(env, args[2]);
    int pageNum = NapiHelper::ToCInt(env, args[3]);
    int n = EpubManager::GetInstance()->ModifyWindowSize(name, windowHeight, windowWidth, pageNum);

    napi_value num = NapiHelper::ToNNumber(env, n);
    return num;
}

static napi_value GetEpubPageTotal(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    string name = NapiHelper::ToCStirng(env, args[0]);
    int n = EpubManager::GetInstance()->GetEpubPageTotal(name);

    napi_value num = NapiHelper::ToNNumber(env, n);
    return num;
}


static napi_value DrawEpubPage(napi_env env, napi_callback_info info)
{
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    string name = NapiHelper::ToCStirng(env, args[0]);
    int number = NapiHelper::ToCInt(env, args[1]);
    void *temp = nullptr;
    napi_unwrap(env, args[2], &temp);
    OH_Drawing_Canvas *canvas = reinterpret_cast<OH_Drawing_Canvas *>(temp);
    EpubManager::GetInstance()->DrawEpubPage(name, number, canvas);
    return nullptr;
}

static napi_value GetEpubCatalog(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    string name = NapiHelper::ToCStirng(env, args[0]);

    vector<Catalog *> catalog = EpubManager::GetInstance()->GetCatalog(name);
    napi_value array;
    napi_create_array(env, &array);

    for (size_t i = 0; i < catalog.size(); i++) {
        napi_value obj = catalog[i]->ToNs(env);
        napi_set_element(env, array, i, obj);
    }

    return array;
}

static napi_value InitManager(napi_env env, napi_callback_info info)
{
    size_t argc = 7;
    napi_value args[7] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    float wh = NapiHelper::ToCFloat(env, args[0]);
    float ww = NapiHelper::ToCFloat(env, args[1]);
    float mr = NapiHelper::ToCFloat(env, args[2]);
    float mp = NapiHelper::ToCFloat(env, args[3]);
    float mt = NapiHelper::ToCFloat(env, args[4]);
    float mb = NapiHelper::ToCFloat(env, args[5]);
    float fontSize = NapiHelper::ToCFloat(env, args[6]);

    PageRect *rect = new PageRect(mr, mp, mt, mb);
    EpubManager::GetInstance()->Init(ww, wh, rect, fontSize);
    return nullptr;
}


EXTERN_C_START
static napi_value
Init(napi_env
env,
napi_value exports
) {
napi_property_descriptor desc[] = {
        {"setEpub",               nullptr, SetEpub,               nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getChapterIds",         nullptr, GetChapterIds,         nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getContentByChapterId", nullptr, GetContentByChapterId, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"loadEpubChapter",       nullptr, LoadEpubChapter,       nullptr, nullptr, nullptr, napi_default, nullptr},
        {"modifyFont",            nullptr, ModifyFont,            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"modifyWindowSize",      nullptr, ModifyWindowSize,      nullptr, nullptr, nullptr, napi_default, nullptr},
        {"drawEpubPage",          nullptr, DrawEpubPage,          nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getEpubPageTotal",      nullptr, GetEpubPageTotal,      nullptr, nullptr, nullptr, napi_default, nullptr},
        {"initManager",           nullptr, InitManager,           nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getEpubCatalog",        nullptr, GetEpubCatalog,        nullptr, nullptr, nullptr, napi_default, nullptr}};
napi_define_properties(env, exports,
sizeof(desc) / sizeof(desc[0]), desc);
return
exports;
}
EXTERN_C_END

static napi_module
g_readModule = {
        .nm_version = 1,
        .nm_flags = 0,
        .nm_filename = nullptr,
        .nm_register_func = Init,
        .nm_modname = "parse",
        .nm_priv = ((void *) 0),
        .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterParseModule(void)
{ napi_module_register(&g_readModule); }
