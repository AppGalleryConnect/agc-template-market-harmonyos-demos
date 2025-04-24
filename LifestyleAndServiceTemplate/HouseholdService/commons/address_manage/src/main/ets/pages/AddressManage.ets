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

import { AddressInfo, CommonConstants, RouterMap, RouterModule, UIEmpty } from 'utils'
import { ParamAddressPage, TypeAddressPage } from '../common/Constant';
import { AddressVM } from '../viewmodel/AddressVM'
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function AddressManageBuilder() {
  AddressManage()
}

@ComponentV2
export struct AddressManage {
  addrVM: AddressVM = AddressVM.instance;

  aboutToAppear(): void {
    this.addrVM.init();
  }

  build() {
    NavDestination() {
      Column() {
        if (this.addrVM.list.length) {
          List({ space: 10, scroller: this.addrVM.listScroller }) {
            ForEach(this.addrVM.list, (v: AddressInfo) => {
              ListItem() {
                this.SingleLocationCard(v)
              }
              .padding({
                left: 10,
                right: 10,
              })
              .swipeAction({
                end: {
                  builder: () => {
                    this.ItemEnd(v)
                  },
                  onAction: () => {
                    this.addrVM.deleteConfirm(v.id);
                  },
                },
                edgeEffect: SwipeEdgeEffect.Spring,
              })
            }, (item: AddressInfo) => JSON.stringify(item))
          }
          .width(CommonConstants.FULL_PERCENT)
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .padding({
            top: 10,
            bottom: 20,
          })
        } else {
          Column() {
            UIEmpty({ emptyDesc: '暂无地址', fg: 12 }).margin({ top: 200 })
          }
          .layoutWeight(1)
        }

        this.BottomBar()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title('地址管理', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  ItemEnd(v: AddressInfo) {
    Row() {
      Button() {
        Image($r('app.media.ic_public_delete_filled')).width(24).height(24).fillColor(Color.White)
      }
      .type(ButtonType.Circle)
      .width(40)
      .height(40)
      .backgroundColor($r('app.color.common_red'))
      .onClick(() => {
        this.addrVM.deleteConfirm(v.id!);
      })
    }
    .padding({ left: 20, right: 20 })
  }

  @Builder
  SingleLocationCard(v: AddressInfo) {
    Column({ space: 10 }) {
      Row() {
        Text(v.name).fontSize(10).fontColor($r('app.color.common_grey'))
        Blank()
        Image($r('app.media.ic_public_feedback')).width(16).onClick(() => {
          const param: ParamAddressPage = {
            type: TypeAddressPage.EDIT,
            param: v,
          };
          RouterModule.push({ url: RouterMap.EDIT_ADDRESS, param: param });
        })
      }
      .width(CommonConstants.FULL_PERCENT)

      Text(v.address).fontSize(14).fontWeight(500)
      Row({ space: 4 }) {
        Text(v.contactName).fontSize(12).fontColor($r('app.color.common_grey'))
        Text(v.contactPhone).fontSize(12).fontColor($r('app.color.common_grey'))
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(10)
    .borderRadius(8)
    .backgroundColor(this.addrVM.isSelected(v) ? $r('app.color.common_theme_color_5') : Color.White)
    .borderWidth(1)
    .borderColor(this.addrVM.isSelected(v) ? $r('app.color.common_theme_color') : Color.White)
    .stateStyles({
      pressed: {
        .backgroundColor($r('app.color.grey_10'))
        .borderColor($r('app.color.grey_10'))
      },
    })
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      if (this.addrVM.needPop) {
        RouterModule.pop(v);
      }
    })
  }

  @Builder
  BottomBar() {
    Row() {
      Button('新增地址')
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(500)
        .width(CommonConstants.FULL_PERCENT)
        .height(40)
        .onClick(() => {
          const param: ParamAddressPage = {
            type: TypeAddressPage.NEW,
          };
          RouterModule.push({ url: RouterMap.EDIT_ADDRESS, param });
        })
    }
    .padding(10)
  }
}
