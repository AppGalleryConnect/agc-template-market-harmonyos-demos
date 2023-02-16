import * as shopcartDelete from './mall-shopcart-delete/Handler';
import * as shopcartInsert from './mall-shopcart-insert/Handler';
import * as shopcartQuery from './mall-shopcart-query/Handler';
import * as shopcartUpdate from './mall-shopcart-update/Handler';
import { AuthWrapper } from './auth/AuthWrapper';
import * as Utils from './utils/Utils.js';

let myHandler = async function (event, context, callback, logger) {
  const credential = Utils.getCredential(context, logger);
  let operation;
  let params;
  let token;

  operation = event.body ? JSON.parse(event.body).operation : event.operation;
  params = event.body ? JSON.parse(event.body).params : event.params;
  token = event.body ? JSON.parse(event.body).token : event.token;

  logger.info("the operation is " + event.operation);

  try {
    const authWrapper = new AuthWrapper(credential, logger);
    const promise = authWrapper.verifyToken(token);
    promise
      .then((res) => {
        switch (operation) {
          case "delete":
            shopcartDelete.myHandler(params, context, callback, logger);
            break;
          case "insert":
            shopcartInsert.myHandler(params, context, callback, logger);
            break;
          case "query":
            shopcartQuery.myHandler(params, context, callback, logger);
            break;
          case "update":
            shopcartUpdate.myHandler(params, context, callback, logger);
            break;
          default:
            callback({
              ret: { code: -1, desc: "no such function" },
            });
        }
      })
      .catch((e) => {
        callback({
          ret: { code: -1, desc: "token verify failed" + e.getCode() },
        });
      });
  } catch (e) {
    logger.error("token is " + e);
    callback({
      ret: { code: -1, desc: "token verify failed" },
    });
  }
};

module.exports.myHandler = myHandler;
