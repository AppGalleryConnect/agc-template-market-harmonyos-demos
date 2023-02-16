import { CloudDBZoneWrapper } from '../clouddb/CloudDBZoneWrapper.js';
import * as Utils from '../utils/Utils.js';

export const myHandler = async function (event, context, callback, logger) {
  const credential = Utils.getCredential(context, logger);
  try {
    const cloudDBZoneWrapper = new CloudDBZoneWrapper(credential, logger);
    let shopCart = cloudDBZoneWrapper.getShopCartForUpdate(event.sc_id);
    await cloudDBZoneWrapper.updateShopCartRecord(shopCart, event.quantity, event.selected);
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
