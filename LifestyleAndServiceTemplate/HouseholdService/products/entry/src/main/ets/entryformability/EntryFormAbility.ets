/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FormUtils } from '../widget/util/FormUtils';

const TAG: string = '[EntryFormAbility]';
const DOMAIN: number = 0x0000;

export default class EntryFormAbility extends FormExtensionAbility {

  onAddForm(want: Want) {
    const formId: string = want.parameters?.[formInfo.FormParam.IDENTITY_KEY] as string;
    hilog.info(DOMAIN, TAG, `onAddForm formId: ${formId}`);
    if (formId) {
      FormUtils.addFormId(formId, this.context);
    }
    FormUtils.checkAndCleanExpiredFormData(this.context);

    return formBindingData.createFormBindingData(FormUtils.queryFormDataFromLocal(this.context));
  }

  // 卡片定时刷新
  onUpdateForm(formId: string) {
    hilog.info(DOMAIN, TAG, `onUpdateForm, formId = ${formId}`);
    FormUtils.checkAndCleanExpiredFormData(this.context);
  }


  // 卡片移除时调用
  onRemoveForm(formId: string) {
    hilog.info(DOMAIN, TAG, `onRemoveForm, formId = ${formId}`);
    FormUtils.delFormId(formId, this.context);
  }

  onAcquireFormState(want: Want) {
    // 卡片提供方接收查询卡片状态通知接口，默认返回卡片初始状态。
    return formInfo.FormState.READY;
  }
};