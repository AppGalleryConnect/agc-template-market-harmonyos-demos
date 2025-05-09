/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2025. All rights reserved.
 */

#ifndef READKIT_XMLREADER_H
#define READKIT_XMLREADER_H

#include "third_party/pugixml/src/pugixml.hpp"
#include "utils/t_log.h"

using namespace std;

class XmlReader {
public:
    static pugi::xml_document LoadXml(const string &path)
    {
        pugi::xml_document doc;
        if (!doc.load_file(path.c_str())) {
            // error
            READ_LOGE("failed to load xml");
            return doc;
        }

        return doc;
    }

    static pugi::xpath_node_set FindNodes(const pugi::xml_document &doc, const string &path)
    {
        pugi::xpath_node_set nodes = doc.select_nodes(path.c_str());
        return nodes;
    }

    static pugi::xpath_node FindNode(const pugi::xml_document &doc, const string &path)
    {
        pugi::xpath_node node = doc.select_node(path.c_str());
        return node;
    }

    static string GetNodeAttrValue(const pugi::xpath_node &node, const string &attrName)
    {
        return node.node().attribute(attrName.c_str()).value();
    }

    static string GetNodeContent(const pugi::xpath_node node)
    {
        return node.node().child_value();
    }
};

#endif //READKIT_XMLREADER_H
