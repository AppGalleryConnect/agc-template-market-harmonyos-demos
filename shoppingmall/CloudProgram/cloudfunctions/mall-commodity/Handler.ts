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

import * as commodityQuery from './mall-commodity-query/Handler';
import * as commoditySearch from './mall-commodity-search/Handler';
import * as commodityQueryById from './mall-commodity-queryById/Handler';

let myHandler = function (event, context, callback, logger) {
    let operation;
    let params;

    logger.info("enter mall-commodity func with operation " + event.operation);

    operation = event.body ? JSON.parse(event.body).operation : event.operation;
    params = event.body ? JSON.parse(event.body).params : event.params;

    switch (operation) {
        case "query":
            commodityQuery.myHandler(params, context, callback, logger);
            break;
        case "search":
            commoditySearch.myHandler(params, context, callback, logger);
            break;
        case "queryById":
            commodityQueryById.myHandler(params, context, callback, logger);
            break;
        default:
            callback({
                ret: { code: -1, desc: "no such function" },
            });
    }
};

module.exports.myHandler = myHandler;
