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

import {
  AppStorageBank,
  CommonConstants,
  CommonUtils,
  FormItem,
  FormType,
  IUserInfo,
  PHONE_REG,
  RouterModule,
  updateUserInfo,
  UserInfo,
} from 'utils'
import { AppStorageV2, LengthMetrics } from '@kit.ArkUI';

@Builder
export function EditPersonalBuilder() {
  EditPersonal()
}

@ComponentV2
export struct EditPersonal {
  userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local avatarUrl: string = '';
  @Local nickName: string = '';
  @Local name: string = '';
  @Local gender: number = 0;
  @Local phone: string = '';
  @Local birthDate: Date | null = null;

  aboutToAppear(): void {
    this.assignInfo();
  }

  assignInfo() {
    this.avatarUrl = CommonUtils.handleImgUrl(this.userInfo.avatar ?? '');
    this.nickName = this.userInfo.nickName ?? '';
    this.name = this.userInfo.name ?? '';
    this.gender = this.userInfo.gender ?? 0;
    this.phone = this.userInfo.mobile ?? '';
    if (this.userInfo.birth) {
      this.birthDate = new Date(this.userInfo.birth);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          this.FormCard()
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ top: 10, bottom: 10 })

        this.BottomBar()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title('编辑资料', { paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
  }

  isValid() {
    if (this.phone && !PHONE_REG.test(this.phone)) {
      this.getUIContext().getPromptAction().showToast({ message: '请填写正确的手机号码' });
      return false;
    }

    return true;
  }

  buildParam() {
    const user: IUserInfo = {
      userId: this.userInfo.userId,
      nickName: this.nickName,
      avatar: this.avatarUrl,
      name: this.name,
      gender: this.gender,
      mobile: this.phone,
      birth: this.birthDate?.getTime(),
    };

    return user;
  }

  onSubmit() {
    if (!this.isValid()) {
      return;
    }
    const user = this.buildParam();
    updateUserInfo(user).then(() => {
      AppStorageBank.updateUserInfo(user);
      RouterModule.pop();
    });
  }

  @Builder
  FormCard() {
    Column() {
      FormItem({
        param: {
          type: FormType.AVATAR,
          label: '头像',
        },
        value: this.avatarUrl!!,
      })

      FormItem({
        param: {
          type: FormType.INPUT,
          label: '昵称',
        },
        value: this.nickName!!,
      })
      FormItem({
        param: {
          type: FormType.INPUT,
          label: '姓名',
        },
        value: this.name!!,
      })
      FormItem({
        param: {
          type: FormType.GENDER,
          label: '性别',
        },
        numberV: this.gender!!,
      })
      FormItem({
        param: {
          type: FormType.INPUT,
          inputType: InputType.PhoneNumber,
          label: '手机号',
        },
        value: this.phone!!,
      })
      FormItem({
        param: {
          type: FormType.DATE,
          label: '生日',
          last: true,
        },
        dateV: this.birthDate!!,
      })
    }
    .padding({ left: 10, right: 10 })
    .backgroundColor(Color.White)
  }

  @Builder
  BottomBar() {
    Row() {
      Button('保存')
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(500)
        .width(CommonConstants.FULL_PERCENT)
        .height(40)
        .onClick(() => {
          this.onSubmit();
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(10)
  }
}
