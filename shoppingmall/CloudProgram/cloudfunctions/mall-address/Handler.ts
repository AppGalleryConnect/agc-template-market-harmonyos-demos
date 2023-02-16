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

import * as defaultAddressQuery from './mall-address-queryDefault/Handler';
import * as addressInsert from './mall-address-insert/Handler';
import * as addressQuery from './mall-address-query/Handler';
import * as addressUpdate from './mall-address-update/Handler';
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
          case "defaultQuery":
            defaultAddressQuery.myHandler(params, context, callback, logger);
            break;
          case "insert":
            addressInsert.myHandler(params, context, callback, logger);
            break;
          case "query":
            addressQuery.myHandler(params, context, callback, logger);
            break;
          case "update":
            addressUpdate.myHandler(params, context, callback, logger);
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
