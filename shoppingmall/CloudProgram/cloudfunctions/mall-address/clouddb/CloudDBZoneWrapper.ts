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
import { t_mall_user_addr as mallUserAddr } from './models/t_mall_user_addr';
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

  // 查询地址信息
  async queryAddressData(uid) {
    let addressList = [];
    if (!this.cloudDbZone) {
      this.logger.error("CloudDBClient is null, try re-initialize it");
    }
    const addressQuery = clouddb.CloudDBZoneQuery.where(mallUserAddr).equalTo(
      "uid",
      uid
    );
    try {
      const addressResp = await this.cloudDbZone.executeQuery(addressQuery);
      addressList = addressResp.getSnapshotObjects();
      this.logger.info("query address success ");
    } catch (error) {
      this.logger.error("query address failed ");
    }
    return addressList;
  }

  //更新地址信息
  async updateAddrInfoRecord(addrInfo, addressInfoData) {
    try {
      this.logger.info("begin update");
      let operator = clouddb.CloudDBZoneObjectOperator.build(addrInfo)
        .update("name", addressInfoData.name)
        .update("phone", addressInfoData.phone)
        .update("province", addressInfoData.province)
        .update("city", addressInfoData.city)
        .update("region", addressInfoData.region)
        .update("detail_addr", addressInfoData.detail_addr)
        .update("isdefault", addressInfoData.isdefault)
        .update("update_time", new Date());
      this.logger.info("operator ", operator);
      let updateRes = await this.cloudDbZone.executeUpdate(operator);
      this.logger.info("updateRes ", updateRes);
    } catch (error) {
      this.logger.error("executeupdate shopcart failed " + error);
    }
  }

  getAddrInfo(addrId) {
    let object = new mallUserAddr();
    object.setAddr_id(addrId);
    return object;
  }

  // 查询默认地址信息
  async queryDefaultAddressData(uid) {
    let addressList = [];
    if (!this.cloudDbZone) {
      this.logger.error("CloudDBClient is null, try re-initialize it");
    }
    const addressQuery = clouddb.CloudDBZoneQuery.where(mallUserAddr)
      .equalTo("uid", uid)
      .equalTo("isdefault", 1);
    try {
      const addressResp = await this.cloudDbZone.executeQuery(addressQuery);
      addressList = addressResp.getSnapshotObjects();
      this.logger.info("query address success ");
    } catch (error) {
      this.logger.error("query address failed ");
    }
    return addressList;
  }

  //新增收货地址
  async insertAddrInfoRecord(addrInfo) {
    if (!this.cloudDbZone) {
      this.logger.error("CloudDBClient is null, try re-initialize it");
    }

    try {
      let res = await this.cloudDbZone.executeUpsert(addrInfo);
      this.logger.info("Insert " + res + " records success");
    } catch (error) {
      this.logger.error("executeInsert addressRecords failed " + error);
    }
  }

  getAddress(shopCartParamData) {
    let object = new mallUserAddr();
    object.setAddr_id(shopCartParamData.addr_id);
    object.setUid(shopCartParamData.uid);
    object.setName(shopCartParamData.name);
    object.setPhone(shopCartParamData.phone);
    object.setPost_code(shopCartParamData.post_code);
    object.setProvince(shopCartParamData.province);
    object.setCity(shopCartParamData.city);
    object.setRegion(shopCartParamData.region);
    object.setDetail_addr(shopCartParamData.detail_addr);
    object.setCreate_time(new Date());
    object.setUpdate_time(new Date());
    object.setIsdefault(shopCartParamData.isdefault);
    return object;
  }
};
