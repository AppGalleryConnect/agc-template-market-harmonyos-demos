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

  // 删除购物车
  async deleteShopCartRecord(shopCartList) {
    if (!this.cloudDbZone) {
      this.logger.error("CloudDBClient is null, try re-initialize it");
    }

    try {
      this.cloudDbZone
        .executeDelete(shopCartList)
        .then((res) => {
          this.logger.info("Delete records success");
        })
        .catch((err) => {
          this.logger.error("Delete records failed " + err);
        });
    } catch (error) {
      this.logger.error("executeDelete shopcart failed " + error);
    }
  }
  
  getShopCartForDelete(scList) {
    return scList.map((item) => {
      let object = new shopCartInfo();
      object.setSc_id(item);
      return object
    });
  }

  // 插入购物车
  async insertShopCartRecord(ShopCart, spuId, spuAttrs, quantity, scId, uid) {
    let shopCartRecord = [];
    if (!this.cloudDbZone) {
      this.logger.error("CloudDBClient is null, try re-initialize it");
    }

    const shopCartQuery = clouddb.CloudDBZoneQuery.where(shopCartInfo)
      .equalTo("spu_id", spuId)
      .equalTo("spu_attrs", spuAttrs)
      .equalTo("uid", uid);
    const shopCartResp = await this.cloudDbZone.executeQuery(shopCartQuery);
    shopCartRecord = shopCartResp.getSnapshotObjects();
    if (shopCartRecord.length !== 0) {
      try {
        //获取要更新的对象
        let updator = shopCartRecord[0].quantity;
        updator += quantity;
        let updatedShopCart = this.getShopCart(
          spuId,
          shopCartRecord[0].sc_id,
          uid,
          updator,
          spuAttrs
        );
        this.logger.info("quantity of update is " + updatedShopCart.quantity);
        let operator = clouddb.CloudDBZoneObjectOperator.build(
          updatedShopCart
        ).update("quantity", updator);
        this.logger.info("operator ", operator);
        let updateRes = await this.cloudDbZone.executeUpdate(operator);
        this.logger.info("updateRes ", updateRes);
      } catch (error) {
        this.logger.error("executeUpsert shopcart failed " + error);
      }
    } else {
      try {
        let res = await this.cloudDbZone.executeUpsert(ShopCart);
        this.logger.info("Insert " + res + " records success");
      } catch (error) {
        this.logger.error("executeInsert shopcart failed " + error);
      }
    }
  }

  getShopCartForInsert(spuId, scId, uid, quantity, spuAttrs) {
    let object = new shopCartInfo();
    object.setSpu_id(spuId);
    object.setSc_id(scId);
    object.setUid(uid);
    object.setQuantity(quantity);
    object.setSelected(0);
    object.setCreate_time(new Date());
    object.setUpdate_time(new Date());
    object.setSpu_attrs(spuAttrs);
    return object;
  }

  // 查询购物车
  async queryShopCartData(uid) {
    let shopCartList = [];
    let spuInfoList = [];
    let result = [];
    if (!this.cloudDbZone) {
      this.logger.error("CloudDBClient is null, try re-initialize it");
    }

    const shopCartQuery = clouddb.CloudDBZoneQuery.where(shopCartInfo).equalTo(
      "uid",
      uid
    );
    const spuInfoQuery = clouddb.CloudDBZoneQuery.where(mallSpuInfo);

    try {
      const shopCartResp = await this.cloudDbZone.executeQuery(shopCartQuery);
      const spuInfoResp = await this.cloudDbZone.executeQuery(spuInfoQuery);
      shopCartList = shopCartResp.getSnapshotObjects();
      spuInfoList = spuInfoResp.getSnapshotObjects();
      shopCartList.forEach((item) => {
        let spuIdItem = spuInfoList.find(
          (ele) => ele.spu_id === item.spu_id
        );
        let shopResult = {
          spu_id: item.spu_id || null,
          sc_id: item.sc_id || null,
          spu_attrs: item.spu_attrs || "",
          uid: item.uid || null,
          quantity: item.quantity,
          price: item.price,
          selected: item.selected,
          create_time: item.create_time || null,
          update_time: item.update_time || null,
        };
        let spuResult = {
          name: spuIdItem?.name || null,
          desc: spuIdItem?.desc || null,
          price: spuIdItem?.price || null,
          pic_url: spuIdItem?.pic_url || null,
        };
        this.logger.info("spuResult " + spuResult.name);
        result.push(Object.assign(shopResult, spuResult));
      });
    } catch (error) {
      this.logger.error("query shopCartList failed ");
    }
    return result;
  }
  // 更新购物车
  async updateShopCartRecord(shopCart, quantity, selected) {
    if (!this.cloudDbZone) {
      this.logger.error("CloudDBClient is null, try re-initialize it");
    }
    try {
      this.logger.info("begin update");
      let operator = clouddb.CloudDBZoneObjectOperator.build(shopCart)
        .update("quantity", quantity)
        .update("update_time", new Date())
        .update("selected", selected);
      this.logger.info("operator ", operator);
      let updateRes = await this.cloudDbZone.executeUpdate(operator);
      this.logger.info("updateRes ", updateRes);
    } catch (error) {
      this.logger.error("executeupdate shopcart failed " + error);
    }
  }

  getShopCartForUpdate(scId) {
    let object = new shopCartInfo();
    object.setSc_id(scId);
    return object;
  }

  getShopCart(spuId, scId, uid, quantity, spuAttrs) {
    let object = new shopCartInfo();
    object.setSpu_id(spuId);
    object.setSc_id(scId);
    object.setUid(uid);
    object.setQuantity(quantity);
    object.setSelected(0);
    object.setCreate_time(new Date());
    object.setUpdate_time(new Date());
    object.setSpu_attrs(spuAttrs);
    return object;
  }
};
