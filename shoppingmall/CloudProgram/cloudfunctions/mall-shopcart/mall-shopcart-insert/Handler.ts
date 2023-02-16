import { CloudDBZoneWrapper } from '../clouddb/CloudDBZoneWrapper.js';
import * as Utils from '../utils/Utils.js';

export const myHandler = async function (event, context, callback, logger) {
  const credential = Utils.getCredential(context, logger);
  try {
    const cloudDBZoneWrapper = new CloudDBZoneWrapper(credential, logger);
    let shopcart = cloudDBZoneWrapper.getShopCart(
      event.spu_id,
      event.sc_id,
      event.uid,
      event.quantity,
      event.spu_attrs
    );
    await cloudDBZoneWrapper.insertShopCartRecord(
      shopcart,
      event.spu_id,
      event.spu_attrs,
      event.quantity,
      event.sc_id,
      event.uid
    );
    callback({
      ret: { code: 0, desc: "SUCCESS" },
    });
  } catch (err) {
    logger.error("func error:" + err.message + " stack:" + err.stack);
    callback({
      ret: { code: -1, desc: "ERROR" },
    });
  }
};
