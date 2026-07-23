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

import { Constants } from '../common/Constants';
import { FormItemModel, MenuModel, MENU_DATTA } from '../models/Model';

const storageMini = new LocalStorage();

@Entry(storageMini)
@Component
struct WidgetCard {
  @LocalStorageProp('data') @Watch('onDataUpdated') data: string = '';
  @State list: FormItemModel = new FormItemModel('', '', '', '', '', false);
  readonly actionType: string = 'router';
  readonly abilityName: string = 'EntryAbility';

  onDataUpdated() {
    try {
      this.list = JSON.parse(this.data) as FormItemModel;
    } catch (e) {
      this.list = new FormItemModel('', '', '', '', '', false);
    }
  }

  build() {
    Column() {
      Row({ space: Constants.SPACE_S }) {
        Image($r('app.media.ic_widget_logo'))
          .width(Constants.APP_ICON_W)
          .height(Constants.APP_ICON_W)
          .borderRadius(Constants.ICON_BORDER)
        Text('家政元服务')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
      }
      .margin({ bottom: Constants.SPACE_M })

      Column() {
        if (this.list.isShow) {
          Column({ space: Constants.SPACE_M }) {
            Text(this.list.title ?? '家政元服务')
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)

            Text('已预约' + this.list.appointTime ?? '01-01 00:00')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_secondary'))
              .fontWeight(FontWeight.Regular)
          }
          .margin({ bottom: Constants.PADDING_M })
          .width(Constants.FULL_PERCENT)
          .alignItems(HorizontalAlign.Start)
          .onClick(() => {
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: {
                source: Constants.SOURCE,
                pageUrl: Constants.MY_ORDER_DETAIL,
                orderId: this.list.orderId,
                goodId: this.list.goodId,
              },
            });
          })

          Row({ space: Constants.SPACE_M }) {
            Button('查看服务')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(FontWeight.Medium)
              .height(Constants.BTN_HEIGHT)
              .layoutWeight(1)
              .onClick(() => {
                postCardAction(this, {
                  action: this.actionType,
                  abilityName: this.abilityName,
                  params: {
                    source: Constants.SOURCE,
                    pageUrl: Constants.GOOD_DETAIL,
                    goodId: this.list.goodId,
                  },
                });
              })
          }
        } else {
          List({ space: Constants.SPACE_S }) {
            ForEach(MENU_DATTA.slice(0, 2), (item: MenuModel) => {
              ListItem() {
                Button() {
                  Row({ space: Constants.SPACE_XXS }) {
                    SymbolGlyph(item.image as Resource)
                      .fontColor([$r('sys.color.icon_on_primary')])
                      .fontSize(16)

                    Text(item.label)
                      .fontSize($r('sys.float.Body_L'))
                      .fontColor($r('sys.color.font_on_primary'))
                      .fontWeight(FontWeight.Medium)
                  }
                }
                .height(40)
                .width(Constants.FULL_PERCENT)
                .backgroundColor(item.backgroundColor)
                .onClick(() => {
                  postCardAction(this, {
                    action: this.actionType,
                    abilityName: this.abilityName,
                    params: {
                      source: Constants.SOURCE,
                      pageUrl: Constants.ALL_CATEGORY,
                      tabIndex: item.mainParam!.tabIndex,
                      listInitialIndex: item.mainParam!.listInitialIndex,
                    },
                  });
                })
              }
            }, (item: MenuModel) => item.image + item.label)
          }
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .alignItems(HorizontalAlign.Start)
    .width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)
    .padding({
      top: Constants.PADDING_M,
      bottom: Constants.PADDING_M,
      left: Constants.PADDING_M,
      right: Constants.PADDING_M,
    })
  }
}