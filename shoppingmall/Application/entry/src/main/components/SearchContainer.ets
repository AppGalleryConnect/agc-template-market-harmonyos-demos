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
import { GoodModel } from '../model';
import { Empty } from './Empty';
import { Constants } from '../constants/Constants';

@Component
export struct SearchContainer {
  @Link searchResult: Array<GoodModel>;

  build() {
    Column() {
      if (!this.searchResult.length) {
        Empty()
      } else {
        Flex({ direction: FlexDirection.Column }) {
          Grid() {
            ForEach(this.searchResult, item => {
              GridItem() {
                Column() {
                  Image(item.pic_url)
                    .width(Constants.WIDTH_FULL)
                    .height(Constants.HIGH_TWO_THIRD_FULL)
                    .objectFit(ImageFit.Contain)
                    .margin({ bottom: $r('app.float.address_margin_bottom') })
                    .alignSelf(ItemAlign.Center)
                  Text(`【${item.name}】${item.desc}`)
                    .fontSize($r('app.float.font_large'))
                    .fontWeight(600)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ bottom: $r('app.float.margin_bottom_middle'), left: $r('app.float.margin_left_middle') })

                  Text(`￥${item.price.toFixed(2)}`)
                    .fontSize($r('app.float.font_large'))
                    .fontColor(Color.Red)
                    .margin({ left: $r('app.float.margin_left_middle') })
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width(Constants.WIDTH_NEAR_FULL)
              .height(Constants.GOODITEM_HIGH)
              .border({ width: 1, color: $r('app.color.good_grid'), radius: $r('app.float.border_radius_small') })
              .margin({ top: $r('app.float.margin_top_small'), bottom: $r('app.float.margin_bottom_small') })
              .backgroundColor(Color.White)
              .onClick(() => {
                router.push({
                  url: 'pages/GoodDetail',
                  params: { goodData: item }
                })
              })
            }, item => item.toString())
          }
          .columnsTemplate('1fr 1fr')
        }
      }
    }
    .width(Constants.WIDTH_FULL)
    .backgroundColor($r('app.color.page_background'))
  }
}