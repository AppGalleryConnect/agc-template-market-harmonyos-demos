/*
 * Copyright 2020. Huawei Technologies Co., Ltd. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import * as clouddb from '@agconnect/database-server';
import { t_mall_sku as mallSkuInfo } from './models/t_mall_sku';
import { t_mall_spu as mallSpuInfo } from './models/t_mall_spu';
import { t_mall_spu_attr as mallSpuAttrInfo } from './models/t_mall_spu_attr';
import { t_mall_order as mallOrderInfo } from './models/t_mall_order';
import { t_mall_user_addr as mallUserAddr } from './models/t_mall_user_addr';
import { t_mall_shopcart as shopCartInfo } from './models/t_mall_shopcart';
import * as agconnect from '@agconnect/common-server';

const ZONE_NAME = "shopping";

export class CloudDBZoneWrapper {
    logger;
    cloudDbZone;

    constructor(credential, logger) {
        this.logger = logger;
        try {
            // 初始化AGCClient
            logger.info("begin to init agcClient");
            let agcClient;
            try {
                agcClient = agconnect.AGCClient.getInstance();
            } catch {
                agconnect.AGCClient.initialize(credential);
                agcClient = agconnect.AGCClient.getInstance();
            }
            // 初始化AGConnectCloudDB实例
            logger.info("begin to init clouddb");
            let cloudDbInstance;
            try {
                cloudDbInstance = clouddb.AGConnectCloudDB.getInstance(agcClient);
            } catch {
                clouddb.AGConnectCloudDB.initialize(agcClient);
                cloudDbInstance = clouddb.AGConnectCloudDB.getInstance(agcClient);
            }
            // 创建CloudDBZoneConfig配置对象，并设置云侧CloudDB zone名称，打开Cloud DB zone实例
            const cloudDBZoneConfig = new clouddb.CloudDBZoneConfig(ZONE_NAME);
            this.cloudDbZone = cloudDbInstance.openCloudDBZone(cloudDBZoneConfig);
        } catch (err) {
            logger.error("init CloudDBZoneWrapper error: " + err);
        }
    }

    // 查询商品信息
    async queryGoodsData(pageSize, currentPage) {
        let mallSkuInfoList = [];
        let mallSpuInfoList = [];
        let mallSpuAttrInfoList = [];
        let result = [];
        if (!this.cloudDbZone) {
            this.logger.error("CloudDBClient is null, try re-initialize it");
        }
        let startId = Number(pageSize) * Number(currentPage) - pageSize + 1;
        let skuInfo = new mallSkuInfo();
        let spuInfo = new mallSpuInfo();
        skuInfo.setSku_id(startId);
        spuInfo.setSpu_id(startId);
        const mallSkuInfoQuery = clouddb.CloudDBZoneQuery.where(mallSkuInfo)
            .orderByAsc("sku_id")
            .startAt(skuInfo)
            .limit(pageSize);
        const mallSpuInfoQuery = clouddb.CloudDBZoneQuery.where(mallSpuInfo)
            .orderByAsc("spu_id")
            .startAt(spuInfo)
            .limit(pageSize);
        const mallSpuAttrInfoQuery =
        clouddb.CloudDBZoneQuery.where(mallSpuAttrInfo);
        const mallSkuInfoResp = await this.cloudDbZone.executeQuery(
            mallSkuInfoQuery
        );
        const mallSpuInfoResp = await this.cloudDbZone.executeQuery(
            mallSpuInfoQuery
        );
        const mallSpuAttrInfoResp = await this.cloudDbZone.executeQuery(
            mallSpuAttrInfoQuery
        );
        mallSkuInfoList = mallSkuInfoResp.getSnapshotObjects();
        mallSpuInfoList = mallSpuInfoResp.getSnapshotObjects();
        mallSpuAttrInfoList = mallSpuAttrInfoResp.getSnapshotObjects();
        result = this.getQueryResult(
            mallSpuInfoList,
            mallSkuInfoList,
            mallSpuAttrInfoList
        );
        this.logger.info("query GoodsList success ");
        return result;
    }

    getQueryResult(spuList, skuList, spuAttrList) {
        let result = [];
        skuList.forEach((skuElm) => {
            let spuIdIndex = spuList.findIndex((elm) => elm.spu_id === skuElm.spu_id);
            let skuElmResult = {
                detail_pic_url: skuElm.pic_url || null,
            };
            let attr_list = [];
            let attrsArr = JSON.parse(skuElm.attrs);
            attrsArr.attr_ids.forEach((attrItem) => {
                let attrElm = spuAttrList.find((elm) => attrItem == elm.attr_id);
                attr_list.push({
                    name: attrElm.name,
                    value: JSON.parse(attrElm.attr_vals),
                });
            });
            let spuAttrElmResult = {
                attr_list: JSON.stringify(attr_list),
            };
            let spuElmResult = {
                name: spuList[spuIdIndex]?.name || null,
                desc: spuList[spuIdIndex]?.desc || null,
                price: spuList[spuIdIndex]?.price || null,
                spu_id: spuList[spuIdIndex]?.spu_id || null,
                category_id: spuList[spuIdIndex]?.category_id || null,
                pic_url: spuList[spuIdIndex]?.pic_url || null,
            };
            result.push(Object.assign(skuElmResult, spuElmResult, spuAttrElmResult));
        });
        return result;
    }

    // 搜索商品信息
    async searchGoodsData(keyword) {
        let mallSkuInfoList = [];
        let mallSpuInfoList = [];
        let mallSpuAttrInfoList = [];
        let result = [];
        if (!this.cloudDbZone) {
            this.logger.error("CloudDBClient is null, try re-initialize it");
        }
        const mallSkuInfoQuery = clouddb.CloudDBZoneQuery.where(mallSkuInfo);
        const mallSpuInfoQuery = clouddb.CloudDBZoneQuery.where(
            mallSpuInfo
        ).contains("name", keyword);
        const mallSpuAttrInfoQuery =
        clouddb.CloudDBZoneQuery.where(mallSpuAttrInfo);
        try {
            const mallSkuInfoResp = await this.cloudDbZone.executeQuery(
                mallSkuInfoQuery
            );
            const mallSpuInfoResp = await this.cloudDbZone.executeQuery(
                mallSpuInfoQuery
            );
            const mallSpuAttrInfoResp = await this.cloudDbZone.executeQuery(
                mallSpuAttrInfoQuery
            );
            mallSkuInfoList = mallSkuInfoResp.getSnapshotObjects();
            mallSpuInfoList = mallSpuInfoResp.getSnapshotObjects();
            mallSpuAttrInfoList = mallSpuAttrInfoResp.getSnapshotObjects();
            result = this.getSearchResult(
                mallSpuInfoList,
                mallSkuInfoList,
                mallSpuAttrInfoList
            );
            this.logger.info("get search result success");
        } catch (error) {
            this.logger.error("get search result failed");
        }
        return result;
    }

    getSearchResult(spuList, skuList, spuAttrList) {
        let result = [];
        spuList.forEach((spuEle) => {
            let skuIndex = skuList.findIndex((elm) => elm.spu_id === spuEle.spu_id);
            let skuElmResult = {
                pic_url: skuList[skuIndex].pic_url || null,
            };
            let attr_list = [];
            let attrsArr = JSON.parse(skuList[skuIndex].attrs);
            attrsArr.attr_ids.forEach((attrItem) => {
                let attrElm = spuAttrList.find((elm) => attrItem == elm.attr_id);
                attr_list.push({
                    name: attrElm.name,
                    value: JSON.parse(attrElm.attr_vals),
                });
            });
            let spuAttrElmResult = {
                attr_list: JSON.stringify(attr_list),
            };
            let spuElmResult = {
                name: spuEle?.name || null,
                desc: spuEle?.desc || null,
                price: spuEle?.price || null,
                spu_id: spuEle?.spu_id || null,
                category_id: spuEle?.category_id || null,
                detail_pic_url: spuEle?.pic_url || null,
            };
            result.push(Object.assign(skuElmResult, spuElmResult, spuAttrElmResult));
        });
        return result;
    }

    // 查询商品详情
    async queryGoodsDataById(spuId) {
        let mallSkuInfoObj = new mallSkuInfo();
        let mallSpuInfoObj = new mallSpuInfo();
        let mallSpuAttrInfoArr = [];
        if (!this.cloudDbZone) {
            this.logger.error("CloudDBClient is null, try re-initialize it");
        }
        if (!spuId) {
            this.logger.error("spuId is empty");
            return;
        }
        const mallSkuInfoQuery = clouddb.CloudDBZoneQuery.where(
            mallSkuInfo
        ).equalTo("spu_id", spuId);
        const mallSpuInfoQuery = clouddb.CloudDBZoneQuery.where(
            mallSpuInfo
        ).equalTo("spu_id", spuId);
        const mallSpuAttrInfoQuery =
        clouddb.CloudDBZoneQuery.where(mallSpuAttrInfo);
        try {
            const mallSkuInfoResp = await this.cloudDbZone.executeQuery(
                mallSkuInfoQuery
            );
            const mallSpuInfoResp = await this.cloudDbZone.executeQuery(
                mallSpuInfoQuery
            );
            const mallSpuAttrInfoResp = await this.cloudDbZone.executeQuery(
                mallSpuAttrInfoQuery
            );
            mallSkuInfoObj = mallSkuInfoResp.getSnapshotObjects()[0];
            mallSpuInfoObj = mallSpuInfoResp.getSnapshotObjects()[0];
            mallSpuAttrInfoArr = mallSpuAttrInfoResp.getSnapshotObjects();
            this.logger.info("query GoodsDetail success ");
        } catch (error) {
            this.logger.error("query GoodsDetail failed ");
        }
        let { attr_ids } = JSON.parse(mallSkuInfoObj.attrs);
        let attr_list = {};
        attr_ids.forEach((elm) => {
            let attrIdItem = mallSpuAttrInfoArr.find((item) => item.attr_id == elm);
            attr_list[attrIdItem.name] = attrIdItem.attr_vals;
        });
        return {
            spu_id: spuId,
            name: mallSpuInfoObj.name,
            desc: mallSpuInfoObj.desc,
            price: mallSpuInfoObj.price,
            pic_url: mallSpuInfoObj.pic_url,
            category_id: mallSpuInfoObj.category_id,
            detail_pic_url: mallSpuInfoObj.pic_url,
            attr_list,
        };
    }
};
