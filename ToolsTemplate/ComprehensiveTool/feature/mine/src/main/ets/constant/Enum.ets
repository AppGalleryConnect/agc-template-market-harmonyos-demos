/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export enum SettingType {
  FEEDBACK = 0,
  PRIVACY_POLICY = 1,
  TERMS_OF_SERVICE = 2,
  SETTING = 3
}

export enum ErrorCode {
  // 使用华为账号登录组件时，未设置协议状态为ACCEPTED。
  ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED = 1005300001,
  // 用户未登录华为账号
  ERROR_CODE_UN_LOGIN1 = 1001502001,
  // 账号未登录
  ERROR_CODE_UN_LOGIN2 = 1001600002,
  // 用户取消当前操作。
  ERROR_CODE_CANCEL = 1001600005,
}