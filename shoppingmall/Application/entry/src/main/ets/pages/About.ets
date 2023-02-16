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

import prompt from '@ohos.promptAction'
import router from '@ohos.router';
import { Constants } from '../../constants/Constants';

@Entry
@Component
struct About {
  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width($r('app.float.img_small'))
          .height($r('app.float.img_small'))
          .margin({ left: $r('app.float.margin_left_middle') })
          .onClick(() => {
            router.back();
          })

        Text($r('app.string.personal_about_app'))
          .fontSize($r('app.float.title_font'))
          .fontWeight(FontWeight.Medium).margin({ left: $r('app.float.margin_left_middle') })
      }.height(Constants.SETTINGITEM_HIGH).width(Constants.WIDTH_FULL).backgroundColor($r('app.color.page_background'))

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Image($r('app.media.icon')).width($r('app.float.img_large')).height($r('app.float.img_large'))
        Text($r('app.string.personal_about_appName'))
          .fontWeight(FontWeight.Bold)
          .fontSize($r('app.float.title_font'))
          .margin({ top: $r('app.float.margin_top_middle') })
        Text($r('app.string.personal_version'))
          .fontSize($r('app.float.font_large'))
          .margin({ top: $r('app.float.margin_top_middle') })
      }.height(Constants.VERSION_HIGH).width(Constants.WIDTH_FULL)

      Divider().width(Constants.WIDTH_NEAR_FULL).color(Color.Gray)
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text($r('app.string.personal_app_update'))
          .fontSize($r('app.float.title_font'))
          .padding({ left: $r('app.float.margin_left_middle') })
        Text($r('app.string.personal_newest_app'))
          .fontSize($r('app.float.font_large'))
          .padding({ right: $r('app.float.margin_right_middle') })
          .fontColor(Color.Gray)
          .onClick(() => {
            prompt.showToast({
              message: $r('app.string.personal_newest_app'),
              duration: 2000,
            });
          })
      }.margin({ top: $r('app.float.margin_top_middle'), bottom: $r('app.float.margin_bottom_large') })

      Divider().width(Constants.WIDTH_NEAR_FULL).color(Color.Gray)
    }.alignItems(HorizontalAlign.Center)
  }
}