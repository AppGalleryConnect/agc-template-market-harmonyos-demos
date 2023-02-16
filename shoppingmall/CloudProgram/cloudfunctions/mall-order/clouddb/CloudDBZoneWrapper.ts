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

  // 查询订单信息
  async queryMallOrderData(uid) {
    let mallOrderList = [];
    let mallSpuInfoList = [];
    let result = [];
    if (!this.cloudDbZone) {
      this.logger.error("CloudDBClient is null, try re-initialize it");
    }
    const mallOrderInfoQuery = clouddb.CloudDBZoneQuery.where(
      mallOrderInfo
    ).equalTo("uid", uid);
    const mallSpuInfoQuery = clouddb.CloudDBZoneQuery.where(mallSpuInfo);
    try {
      const mallOrderInfoResp = await this.cloudDbZone.executeQuery(
        mallOrderInfoQuery
      );
      const mallSpuInfoResp = await this.cloudDbZone.executeQuery(
        mallSpuInfoQuery
      );
      mallOrderList = mallOrderInfoResp.getSnapshotObjects();
      this.logger.info("spu_id of mallOrderList " + mallOrderList.length);
      mallSpuInfoList = mallSpuInfoResp.getSnapshotObjects();
      this.logger.info("spu_id of mallOrderList " + mallSpuInfoList.length);
      mallOrderList.forEach((item) => {
        let spuIdIndex = mallSpuInfoList.findIndex(
          (ele) => ele.spu_id === item.spu_id
        );
        this.logger.info("spuIndex " + spuIdIndex);
        let orderResult = {
          order_id: item.order_id || null,
          uid: item.uid || null,
          spu_id: item.spu_id || null,
          spu_num: item.spu_num || null,
          status: item.status,
          order_time: item.order_time || null,
          pay_time: item.pay_time || null,
          amount: item.amount || null,
          create_time: item.create_time || null,
          update_time: item.update_time || null,
          spu_attrs: item.spu_attrs || null,
        };
        let spuResult = {
          name: mallSpuInfoList[spuIdIndex]?.name || null,
          desc: mallSpuInfoList[spuIdIndex]?.desc || null,
          price: mallSpuInfoList[spuIdIndex]?.price || null,
          pic_url: mallSpuInfoList[spuIdIndex]?.pic_url || null,
        };
        this.logger.info("spuResult " + spuResult.name);
        result.push(Object.assign(orderResult, spuResult));
      });
      this.logger.info("query mallOrderList success ");
    } catch (error) {
      this.logger.error("query mallOrderList failed " + JSON.stringify(error));
    }
    return result;
  }
  // 插入订单信息
  async insertMallOrderData(mallOrderData) {
    if (!this.cloudDbZone) {
      this.logger.error("CloudDBClient is null, try re-initialize it");
    }
    try {
      const res = await this.cloudDbZone.executeUpsert(mallOrderData);
      this.logger.info("insert" + " " + res + " " + "order success");
    } catch (error) {
      this.logger.error("insert order failed " + error);
    }
  }

  //插入入参
  setParamMallOrderData(orderParamData) {
    return orderParamData.map((item) => {
      let object = new mallOrderInfo();
      object.setOrder_id(item.order_id);
      object.setUid(item.uid);
      object.setSpu_id(item.spu_id);
      object.setSpu_num(item.spu_num);
      object.setStatus(item.status);
      object.setOrder_time(new Date());
      object.setPay_time(new Date());
      object.setAmount(item.amount);
      object.setCreate_time(new Date());
      object.setUpdate_time(new Date());
      object.setSpu_attrs(item.spu_attrs);
      return object;
    });
  }
  // 更新订单信息
  async updateOrderRecord(order, status, amount) {
    if (!this.cloudDbZone) {
      this.logger.error("CloudDBClient is null, try re-initialize it");
    }

    try {
      this.logger.info("begin update");
      let operator = clouddb.CloudDBZoneObjectOperator.build(order)
        .update("status", status)
        .update("update_time", new Date())
        .update("pay_time", new Date())
        .update("amount", amount);
      this.logger.info("operator ", operator);
      let updateRes = await this.cloudDbZone.executeUpdate(operator);
      this.logger.info("updateRes ", updateRes);
    } catch (error) {
      this.logger.error("executeupdate order failed " + error);
    }
  }

  getOrderInfo(orderId) {
    let object = new mallOrderInfo();
    object.setOrder_id(orderId);
    return object;
  }
};
