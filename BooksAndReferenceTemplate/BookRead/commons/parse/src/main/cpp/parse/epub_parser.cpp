/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#include "epub_parser.h"
#include "constants/constants.h"

void EpubParser::Parse()
{
    ParseContainerFile();
    ParseOpfFile();
}

Chapter *EpubParser::ReadChapterContent(const string &id)
{
    Manifest *m = this->manifests.at(id);
    if (m == nullptr) {
        READ_LOGE("%{public}s failed to find content", id.c_str());
        return nullptr;
    }

    string path = this->epubPath + this->resourceBasePath + m->GetHref();
    pugi::xml_document doc = XmlReader::LoadXml(path);
    pugi::xpath_node bnode = XmlReader::FindNode(doc, "html");
    pugi::xpath_node titleNode = XmlReader::FindNode(doc, "html/head/title");
    pugi::xpath_node_set contentNodes = XmlReader::FindNodes(doc, "html/body/p");

    string title = XmlReader::GetNodeContent(titleNode);

    string content = "";
    for (pugi::xpath_node contentNode: contentNodes) {
        string line = XmlReader::GetNodeContent(contentNode);
        content
                .append(line)
                .append("\n");
    }

    Chapter *c = new Chapter(id, title, content);
    this->chapters[id] = c;
    return c;
}

Chapter *EpubParser::GetChapterById(const string &id)
{
    auto cc = this->chapters.find(id);
    if (cc == this->chapters.end() || cc == this->chapters.end()) {
        READ_LOGI("%{public}s not exist in parseMgt or renderMgt", id.c_str());
        return ReadChapterContent(id);
    }

    return this->chapters[id];
}

vector<string> EpubParser::GetChapterList()
{
    return this->spines;
}

void EpubParser::ParseContainerFile()
{
    string path = this->epubPath + "META-INF/container.xml";
    pugi::xml_document doc = XmlReader::LoadXml(path);
    pugi::xpath_node fileNode = XmlReader::FindNode(doc, "container/rootfiles/rootfile");
    this->opfPath = XmlReader::GetNodeAttrValue(fileNode, "full-path");
    // 获取资源文件根路径
    size_t lastSlash = this->opfPath.find_last_of("/");
    if (lastSlash != std::string::npos) {
        this->resourceBasePath = this->opfPath.substr(0, lastSlash + 1);
    }
}

void EpubParser::ParseOpfFile()
{
    string path = this->epubPath + this->opfPath;
    pugi::xml_document doc = XmlReader::LoadXml(path);
    // 1. 解析 metaData
    pugi::xpath_node_set metaDataNodes = XmlReader::FindNodes(doc, "package/metadata");
    // 2. 解析 manifest
    pugi::xpath_node_set manifestNodes = XmlReader::FindNodes(doc, "package/manifest/item");
    ReadManifest(manifestNodes);
    // 3. 解析 spine
    pugi::xpath_node_set spineNodes = XmlReader::FindNodes(doc, "package/spine/itemref");
    ReadSpine(spineNodes);
}

void EpubParser::ReadManifest(const pugi::xpath_node_set &manifestNodes)
{
    for (pugi::xpath_node node: manifestNodes) {
        auto *m = new Manifest();
        // id/href/media-type
        m->SetId(XmlReader::GetNodeAttrValue(node, "id"));
        m->SetHref(XmlReader::GetNodeAttrValue(node, "href"));
        m->SetMediaType(XmlReader::GetNodeAttrValue(node, "media-type"));
        m->SetFlag(m->GetMediaType() == XHTML_MEDIA_TYPE ? 0 : 1);
        this->manifests[m->GetId()] = m;
    }
}

void EpubParser::ReadSpine(const pugi::xpath_node_set &spineNodes)
{
    for (pugi::xpath_node node: spineNodes) {
        string chapterId = XmlReader::GetNodeAttrValue(node, "idref");
        this->spines.push_back(chapterId);
    }
}
