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
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { UtilLog } from '@hw-agconnect/util-log';
import { CommonUtils, WindowUtil } from 'module_base';
import {
  AppStorageBank,
  CommonConstants,
  confirmRebindMobileWithSecret,
  GridRowColSetting,
  IUserInfo,
  LoginUtil,
  sendCode,
  updateUserInfo,
  UserInfo,
  verifyCode
} from 'lib_foundation';
import { ApiHandler, DataType, PersonalInfo, PersonalInfoView } from 'collect_personal_info';

@Builder
export function EditPersonalBuilder() {
  EditPersonal()
}

@ComponentV2
export struct EditPersonal {
  @Local breakpoint: string = '';
  userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local personalInfo: PersonalInfo = {};
  @Local apiInfo: ApiHandler = {};

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
    this.assignInfo();
    this.assignApiInfo();
  }

  assignInfo() {
    this.personalInfo.avatar = CommonUtils.handleImgUrl(this.userInfo.avatar ?? '');
    this.personalInfo.nickName = this.userInfo.nickName ?? '';
    this.personalInfo.fullName = this.userInfo.name ?? '';
    this.personalInfo.gender = this.userInfo.gender ?? 0;
    this.personalInfo.phoneNumber = this.userInfo.mobile ?? '';
    if (this.userInfo.birth) {
      this.personalInfo.birthDate = new Date(this.userInfo.birth);
    }
  }

  updateInfo() {
    const user: IUserInfo = {
      userId: this.userInfo.userId,
      nickName: this.personalInfo.nickName as string,
      avatar: this.personalInfo.avatar as string,
      name: this.personalInfo.fullName as string,
      gender: this.personalInfo.gender,
      mobile: this.personalInfo.phoneNumber,
      birth: this.personalInfo.birthDate?.getTime(),
    };
    updateUserInfo(user).then(() => {
      AppStorageBank.updateUserInfo(user);
    })
  }

  assignApiInfo() {
    this.apiInfo.updatePhoneInfo = {
      codeLength: 6,
      // todo 发送验证码的接口方法
      sendCode: async (phone: string) => {
        sendCode(phone).then((code) => {
          promptAction.showToast({ message: `验证码${code}` });
        })
      },
      // todo 校验验证码正确性的接口方法
      verifyCode: async (phone: string, code: string): Promise<boolean> => {
        const result = await verifyCode(phone, code);
        const message: string = result ? '验证成功' : '验证失败';
        promptAction.showToast({ message: message });
        return result;
      },
    }
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, }) {
          Column() {
            PersonalInfoView({
              switchInfo: { showIntroDesc: false },
              personalInfo: this.personalInfo,
              apiInfo: this.apiInfo,
              onChange: (type: DataType, data: PersonalInfo) => {
                this.personalInfo = data;
                this.updateInfo();
                if (type === DataType.PHONE_NUMBER) {
                    confirmRebindMobileWithSecret(data.phoneNumber!).then(() => {
                      LoginUtil.cancelAuthorization();
                      LoginUtil.queryUserInfo();
                    }).catch((error: BusinessError) => {
                      LoginUtil.cancelAuthorization();
                      UtilLog.error('[PersonalInfoView]', 'EnterReBindPhone error:' + JSON.stringify(error));
                      promptAction.showToast({ message: '解绑手机号失败，请稍后重试~' });
                    })
                }
              }
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .padding({
            left: GridRowColSetting.getPageMargin(this.breakpoint),
            right: GridRowColSetting.getPageMargin(this.breakpoint)
          })
        }
      }
      .onBreakpointChange((bp) => {
        this.breakpoint = bp;
      })
    }
    .title('编辑资料', {
      paddingStart: { value: GridRowColSetting.getPageMargin(this.breakpoint), unit: 1 }
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
