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

import * as agconnect from '@agconnect/common-server';
import { AGCAuth }  from '@agconnect/auth-server';

export class AuthWrapper {
  logger;
  auth;
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
      logger.info("begin to init auth");
      this.auth = AGCAuth.getInstance();
    } catch (err) {
      logger.error("init AuthWrapper error: " + err);
    }
  }

  verifyToken(accessToken) {
    if (!this.auth) {
      this.logger.error("agcAuth is null, try re-initialize it");
    }

    this.logger.info("begin to verifyToken");

    let promise;

    try {
      promise = this.auth.verifyAccessToken(accessToken, false);
    } catch (err) {
      this.logger.error("verify token failed " + err);
    }

    return promise;
  }
};
