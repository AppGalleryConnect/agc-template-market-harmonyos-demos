/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import * as wxopensdk from '@tencent/wechat_open_sdk';

export { AggregatedPaymentPicker } from './src/main/ets/components/AggregatedPaymentPicker';

export { PickerType, ChannelType, WxExtraInfo } from './src/main/ets/common/Constant'

export { ChannelInfo } from './src/main/ets/model/Index'

export { wxEventHandler as WXEventHandler } from './src/main/ets/model/WXApiWrap'

export const wxApi = wxopensdk.WXAPIFactory.createWXAPI('wx05b3e2e9fc730840')