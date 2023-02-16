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

import { CloudDBZoneWrapper } from '../clouddb/CloudDBZoneWrapper.js';
import * as Utils from '../utils/Utils.js';

export const myHandler = async function (event, context, callback, logger) {
  const credential = Utils.getCredential(context, logger);

  try {
    const cloudDBZoneWrapper = new CloudDBZoneWrapper(credential, logger);
    let addrInfo = cloudDBZoneWrapper.getAddrInfo(event.addr_id);
    await cloudDBZoneWrapper.updateAddrInfoRecord(addrInfo, event);
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
