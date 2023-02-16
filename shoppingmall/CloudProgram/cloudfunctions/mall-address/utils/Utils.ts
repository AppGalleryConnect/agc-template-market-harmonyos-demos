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

const { ClientIdCredential } = require('@agconnect/common-server/dist/credential-service/clientid-credential');

export const getCredential = (context, logger) => {
  try {
    const credential = JSON.parse(context.env.PROJECT_CREDENTIAL);
    if (credential.type === 'team_client_id') {
      return new ClientIdCredential('', '', credential.developer_id, credential.type, credential.client_id, credential.client_secret, credential.configuration_version);
    } else if (credential.type === 'project_client_id') {
      return new ClientIdCredential(credential.project_id, credential.region, credential.developer_id, credential.type, credential.client_id, credential.client_secret, credential.configuration_version);
    }
  } catch {
    logger.error('get project credential failed');
  }
}