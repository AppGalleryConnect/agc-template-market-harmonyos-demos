/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READKIT_EPUBPARSER_H
#define READKIT_EPUBPARSER_H

#include "string"
#include "vector"
#include "map"
#include "third_party/pugixml/src/pugixml.hpp"
#include "entity/metadata.h"
#include "entity/manifest.h"
#include "entity/chapter.h"
#include "utils/t_xml_reader.h"

using namespace std;

class EpubParser {
public:
    explicit EpubParser(string path)
    {
        this->epubPath = path;
    }

    void Parse();

    Chapter *ReadChapterContent(const string &id);

    vector<string> GetChapterList();

    Chapter *GetChapterById(const string &id);

private:
    void ParseContainerFile();

    void ParseOpfFile();

    void ReadManifest(const pugi::xpath_node_set &manifestNodes);

    void ReadSpine(const pugi::xpath_node_set &spineNodes);

    string epubPath;
    string resourceBasePath;
    string opfPath;
    MetaData metadatas;
    map<string, Manifest *> manifests; // 每个章节的实际存储位置
    vector<string> spines; // 章节的预览顺序
    map<int, uint16_t *> glyphsByChapter; // 每个章节的字符索引
    map<string, Chapter *> chapters; // 每个场景的全量字符信息
};


#endif //READKIT_EPUBPARSER_H
