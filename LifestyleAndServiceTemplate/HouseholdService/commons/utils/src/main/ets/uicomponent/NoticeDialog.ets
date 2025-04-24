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

import { AlertDialog } from '@kit.ArkUI';
import { CommonConstants } from '../common/Constant';
import { PopViewUtils } from '../common/PopViewUtils';

export interface ICommonDialogParams {
  content: ResourceStr;
  priBtnV?: ResourceStr;
  secBtnV?: ResourceStr;
  secBtnRole?: ButtonRole;
  confirm?: () => void;
  cancel?: () => void;
}

export class CommonDialogParams implements ICommonDialogParams {
  content: ResourceStr = '';
  priBtnV: ResourceStr = '取消';
  secBtnV: ResourceStr = '确认';
  secBtnRole: ButtonRole = ButtonRole.NORMAL;
  confirm: () => void = () => {
  };
  cancel: () => void = () => {
  };

  constructor(item: ICommonDialogParams) {
    this.content = item.content;
    if (item.priBtnV) {
      this.priBtnV = item.priBtnV;
    }
    if (item.secBtnV) {
      this.secBtnV = item.secBtnV;
    }
    if (item.secBtnRole) {
      this.secBtnRole = item.secBtnRole;
    }
    if (item.confirm) {
      this.confirm = item.confirm;
    }
    if (item.cancel) {
      this.cancel = item.cancel;
    }
  }
}

@Builder
export function NoticeDialogBuilder(params: CommonDialogParams) {
  Column() {
    Column() {
      AlertDialog({
        primaryTitle: '',
        secondaryTitle: '',
        content: params.content,
        primaryButton: {
          value: '好的',
          role: ButtonRole.NORMAL,
          action: () => {
            PopViewUtils.closePopView();
            params.confirm();
          },
        },
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius(32)
    .backgroundColor(Color.White)
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({ left: 10, right: 10 })
}

@Builder
export function ConfirmDialogBuilder(params: CommonDialogParams) {
  Column() {
    Column() {
      AlertDialog({
        primaryTitle: '',
        secondaryTitle: '',
        content: params.content,
        primaryButton: {
          value: params.priBtnV,
          role: ButtonRole.NORMAL,
          action: () => {
            PopViewUtils.closePopView();
            params.cancel();
          },
        },
        secondaryButton: {
          value: params.secBtnV,
          role: params.secBtnRole,
          background: $r('app.color.common_theme_color'),
          fontColor: Color.White,
          action: () => {
            PopViewUtils.closePopView();
            params.confirm();
          },
        },
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius(32)
    .backgroundColor(Color.White)
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({ left: 10, right: 10 })
}