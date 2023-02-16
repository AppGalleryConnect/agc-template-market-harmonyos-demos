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

import router from '@ohos.router';
import prompt from '@ohos.promptAction';
import { AreaCodeModel } from '../../model';
import { areaCodeData, Constants } from '../../constants';
import { Login, AuthMode } from '@ohos/agconnect-auth-component';

@Entry
@Component
struct LoginComponent {
  @State areaCodeList: Array<AreaCodeModel> = areaCodeData;
  @State areaCode: string = '+86'
  @State isChecked: boolean = false;
  @State flag: boolean = false;
  @State phoneNumber: string = '';
  @State verifyCode: string = '';
  @State buttonColor: Color = Color.White;
  @State clickedColor: Color = Color.Gray;
  @State isClicked: boolean = false;
  @State time: number = 60;

  @Styles stack(){
    .width(Constants.WIDTH_NEAR_FULL)
    .margin({ top: $r('app.float.margin_top_middle') })
  }

  checkLoginParams() {
    //手机号或验证码为空
    let loginParamsCheck = true;

    if (!this.isChecked) {
      AlertDialog.show({
        message: '登录前请勾选相关协议'
      })
      loginParamsCheck = false;
    }
    return loginParamsCheck;
  }

  onBackPress() {
    //返回回首页
    router.push({
      url: 'pages/Main',
      params: {
        index: 0
      }
    })
    return true
  }

  build() {
    Column() {
      Stack() {
        Image($r('app.media.login'))
          .width(Constants.WIDTH_FULL).height(Constants.HIGH_FULL).zIndex(0)

        Image($r('app.media.back'))
          .objectFit(ImageFit.Contain)
          .width($r('app.float.img_small'))
          .height($r('app.float.img_small'))
          .position({ x: Constants.BACK_POSITION, y: Constants.BACK_POSITION })
          .zIndex(2)
          .onClick(() => {
            this.onBackPress();
          })

        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.End, alignItems: ItemAlign.Center }) {
          Row() {
            Login({
              modes: [AuthMode.PHONE_VERIFY_CODE],
              onSuccess: () => {
                router.push({
                  url: 'pages/Main'
                })
              },
              onError: (err) => {
                prompt.showToast({ message: JSON.stringify(err) })
              }
            }) {
              Button($r('app.string.login'))
                .fontSize($r('app.float.title_font'))
                .fontColor(Color.White)
                .width(Constants.WIDTH_NEAR_FULL)
                .height(Constants.BUTTON_HIGH)
            }
          }
        }.margin({ bottom: $r('app.float.login_margin_bottom') }).width(Constants.WIDTH_FULL).zIndex(1)
      }.width(Constants.WIDTH_FULL).height(Constants.HIGH_FULL)
    }.width(Constants.WIDTH_FULL).height(Constants.HIGH_FULL)
  }
}