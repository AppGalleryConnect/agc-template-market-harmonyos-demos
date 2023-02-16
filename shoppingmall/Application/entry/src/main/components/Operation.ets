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
import { IconButtonProps } from '../model';
import { Constants } from '../constants/Constants';

@Component
export struct Operation {
  @Link orderCount: { [key: string]: number };
  @Link orderSnapShot: IconButtonProps[];
  private uid: string;
  private token: string;

  @Styles image(){
    .width($r('app.float.img_single'))
    .height($r('app.float.img_single'))
    .margin($r('app.float.margin_bottom_middle'))
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Text($r('app.string.personal_myOrder'))
            .fontSize($r('app.float.font_large'))

          Text($r('app.string.personal_allOrder'))
            .fontSize($r('app.float.font_middle')).fontColor(Color.Gray)
        }.onClick(() => {
          router.push({
            url: 'pages/OrderRecords',
            params: {
              tabIndex: 0,
              uid: this.uid,
              token: this.token
            }
          })
        })
        .padding({ left: $r('app.float.operation_padding_left'), right: $r('app.float.operation_padding_right') })

        Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          List() {
            ForEach(this.orderSnapShot, item => {
              ListItem() {
                Flex({
                  direction: FlexDirection.Column,
                  justifyContent: FlexAlign.Center,
                  alignItems: ItemAlign.Center
                }) {
                  Image(item.icon)
                    .image()
                  Text(`${item.text}`).fontSize($r('app.float.font_small'))
                  if (!!item.count) {
                    Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
                      Text(`${item.count}`).fontSize($r('app.float.font_middle')).fontColor(Color.White)
                    }
                    .backgroundColor(Color.Red)
                    .width(Constants.CORNER_MARK)
                    .height(Constants.CORNER_MARK)
                    .border({ radius: $r('app.float.border_radius_small') })
                    .position({ x: '28%', y: 6 })
                  }
                }
              }.onClick(() => {
                router.push({
                  url: 'pages/OrderRecords',
                  params: {
                    tabIndex: item.index,
                    uid: this.uid,
                    token: this.token
                  }
                })
              })
              .width(Constants.WIDTH_QUARTER)
            })
          }
          .listDirection(Axis.Horizontal)
          .width(Constants.WIDTH_FULL)
        }.width(Constants.WIDTH_FULL).margin({ top: $r('app.float.margin_top_middle') })
      }.height(Constants.HIGH_OPERATION)
    }.backgroundColor(Color.White).padding($r('app.float.padding_small')).borderRadius($r('app.float.border_radius_small'))
  }
}