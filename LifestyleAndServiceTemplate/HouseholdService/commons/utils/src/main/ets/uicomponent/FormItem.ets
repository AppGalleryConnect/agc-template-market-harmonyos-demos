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

import { FormAvatar } from './formcontent/FormAvatar';
import { FormGender } from './formcontent/FormGender';
import { FormDate } from './formcontent/FormDate';
import { FormInput } from './formcontent/FormInput';
import { FormAddress } from './formcontent/FormAddress';
import { FormTextReadOnly } from './formcontent/FormTextReadOnly';
import { CommonConstants } from '../common/Constant';

export enum FormType {
  INPUT,
  GENDER,
  DATE,
  AVATAR,
  ADDRESS,
  TEXT,
  OTHER,
}

export interface IFormItem {
  type: FormType;
  label: string;
  required?: boolean;
  last?: boolean;
  inputType?: InputType;
}

@ComponentV2
export struct FormItem {
  @Require @Param param: IFormItem;
  @Param value: ResourceStr = '';
  @Event $value: (value: ResourceStr) => void = (value: ResourceStr) => {
  };
  @Param numberV: number = 0;
  @Event $numberV: (value: number) => void = (value: number) => {
  };
  @Param dateV: Date | null = null;
  @Event $dateV: (value: Date | null) => void = (value: Date | null) => {
  };
  @BuilderParam formContent: () => void;

  build() {
    Column() {
      Row({ space: 10 }) {
        Row() {
          Text('*')
            .fontColor($r('app.color.common_red'))
            .visibility(Boolean(this.param.required) ? Visibility.Visible : Visibility.None)
          Text(this.param.label).fontSize(16).fontWeight(500)
        }

        Row() {
          if (this.param.type === FormType.TEXT) {
            // 只读纯文本
            FormTextReadOnly({ value: this.value })
          } else if (this.param.type === FormType.INPUT) {
            // 输入框
            FormInput({
              value: this.value,
              inputType: this.param.inputType,
              onInputChange: (value: ResourceStr) => {
                this.$value(value);
              },
            })
          } else if (this.param.type === FormType.GENDER) {
            // 性别
            FormGender({
              selectIndex: this.numberV,
              onGenderSelect: (value: number) => {
                this.$numberV(value);
              },
            })
          } else if (this.param.type === FormType.AVATAR) {
            // 头像
            FormAvatar({
              url: this.value,
              onAvatarSelect: (value: ResourceStr) => {
                this.$value(value);
              },
            })
          } else if (this.param.type === FormType.DATE) {
            // 日期
            FormDate({
              date: this.dateV,
              onDateSelected: (date) => {
                this.$dateV(date);
              },
            })
          } else if (this.param.type === FormType.ADDRESS) {
            // 地址
            FormAddress({
              value: this.value,
              onChooseLocation: (value: ResourceStr) => {
                this.$value(value);
              },
            })
          } else {
            // 其他自定义场景
            if (this.formContent) {
              this.formContent()
            }
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)

      }
      .width(CommonConstants.FULL_PERCENT)
      .height(48)

      Divider().visibility(this.param.last ? Visibility.None : Visibility.Visible)
    }
  }
}