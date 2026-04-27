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

import { SettingModule } from '../model/Index';
import { SettingType } from './Enum';

export const SETTING_TYPE_MODULES: SettingModule[] = [
  {
    id: SettingType.FEEDBACK,
    title: '问题反馈',
    icon: $r('app.media.feedback'),
    url: 'SubmitFeedBack',
  },
  {
    id: SettingType.TERMS_OF_SERVICE,
    title: '用户协议',
    icon: $r('app.media.service'),
    url: 'TermsOfServicePage',
  },
  {
    id: SettingType.PRIVACY_POLICY,
    title: '隐私政策',
    icon: $r('app.media.privacy'),
    url: 'PrivacyPolicyPage',
  },
  {
    id: SettingType.SETTING,
    title: '设置',
    icon: $r('app.media.setting'),
    url: 'SettingPage',
  },
];
