import { CloudDBZoneWrapper } from '../clouddb/CloudDBZoneWrapper.js';
import * as Utils from '../utils/Utils.js';

export const myHandler = async function (event, context, callback, logger) {
  const credential = Utils.getCredential(context, logger);
  try {
    const cloudDBZoneWrapper = new CloudDBZoneWrapper(credential, logger);
    let shopcartList = cloudDBZoneWrapper.getShopCartForDelete(event.sc_list);
    await cloudDBZoneWrapper.deleteShopCartRecord(shopcartList);
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
