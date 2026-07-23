/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AppStorageV2 } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';
import {
  BreakpointType,
  GlobalContextUtils,
  OrderInfo,
  OrderState,
  SampleOrderInfo,
  RouterMap,
  RouterModule
} from 'commonlib';
import { MineVM } from '../viewModel/MineVM';

export enum OrderListType {
  //全部订单
  All = 0,
  //待支付
  WaitToPay,
  //已支付
  Paid,
  //已取消
  Cancelled
}

@ComponentV2
export struct OrderListPage {
  @Param orderType: OrderListType = OrderListType.All;
  @Local orderInfo: OrderInfo[] = [];
  @Local propOrder: SampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
  @Param currentIndex: number = 0;
  mineVM: MineVM = MineVM.instance;

  @Monitor('currentIndex')
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      if (path === 'currentIndex') {
        this.refreshData();
      }
    });
  }

  aboutToAppear(): void {
    this.refreshData();
  }

  refreshData() {
    if (this.orderType === OrderListType.All) {
      this.orderInfo = this.propOrder.orderInfos;
    } else if (this.orderType === OrderListType.WaitToPay) {
      this.orderInfo = this.propOrder.orderInfos.filter((item: OrderInfo) => item.orderState === OrderState.WaitToPay);
    } else if (this.orderType === OrderListType.Paid) {
      this.orderInfo = this.propOrder.orderInfos.filter((item: OrderInfo) => item.orderState === OrderState.Paid);
    } else if (this.orderType === OrderListType.Cancelled) {
      this.orderInfo = this.propOrder.orderInfos.filter((item: OrderInfo) => item.orderState === OrderState.Cancelled);
    }
  }

  build() {
    Column() {
      if (this.orderInfo.length <= 0) {
        Image($r('app.media.Empty'))
          .width(105)
          .height(95).margin({ top: 207, bottom: 36 });
        Text('订单空空如也~~去精品课程逛逛吧！')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_tertiary'));

      } else {
        List({ space: 12 }) {
          ForEach(this.orderInfo, (obj: OrderInfo) => {
            ListItem() {
              OrderItem({
                info: obj,
                refreshEvent: () => {
                  this.refreshData();
                }
              });
            };
          }, (item: OrderInfo, idx: number) => item.orderNo + idx);
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .layoutWeight(1)
        .lanes(new BreakpointType<number>({
          sm: 1,
          md: 2,
          lg: 3,
          xl: 3
        }).getValue(this.mineVM.breakPointModel.currentBreakpoint), 12);
      }
    }
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_16')
    })
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
  }
}

@ComponentV2
struct OrderItem {
  @Param info: OrderInfo = new OrderInfo('', false, OrderState.WaitToPay, '', '', false, false);
  @Param refreshEvent: () => void = () => {
  };

  build() {
    Column() {
      Row() {
        Text('订单号：' + this.info.orderNo)
          .fontSize($r('sys.float.Caption_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'));
        Image($r('app.media.copy'))
          .width(12)
          .height(12)
          .margin({ left: 6 })
          .onClick(() => {
            try {
              let paste: string = pasteboard.MIMETYPE_TEXT_PLAIN;
              let orderNo: string = this.info.orderNo;
              let pasteData: pasteboard.PasteData = pasteboard.createData(paste, orderNo);
              let sysPaste: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
              sysPaste.setData(pasteData, (err) => {
                if (err) {
                  GlobalContextUtils.showToast({ message: '复制失败' });
                  return;
                }
                GlobalContextUtils.showToast({ message: '复制成功' });
              });
            } catch (e) {
            }
          });
        Blank();
        Text(this.info.orderState === OrderState.WaitToPay ? '待支付' :
          (this.info.orderState === OrderState.Paid ? '已支付' : '已取消'))
          .fontSize($r('sys.float.Caption_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor(this.info.orderState === OrderState.WaitToPay ? $r('sys.color.multi_color_08') :
            $r('sys.color.font_secondary'));
        Image($r('app.media.iconRight'))
          .width(12)
          .height(12)
          .margin({ left: 8 })
          .onClick(() => {
          });
      }
      .width('100%');

      Row() {
        Image($r('app.media.avatar'))
          .width(24)
          .height(24)
          .borderRadius(12);
        Text(this.info.userName)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: 12 });
      }
      .width('100%')
      .margin({ top: 12 });

      Text(this.info.content)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 12, right: 12, top: 8 });
      Row() {
        Text('总计：')
          .fontSize($r('sys.float.Caption_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'));
        Text('￥' + this.info.price)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.multi_color_08'));
      }
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.End)
      .width('100%')
      .margin({ top: 12 });

      Row() {
        Button(this.info.orderState === OrderState.WaitToPay ? '取消订单' : '删除订单')
          .padding(0)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .width(72)
          .height(28)
          .onClick(() => {
            if (this.info.orderState === OrderState.WaitToPay) {
              let sampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
              sampleOrderInfo.orderInfos.forEach((orderInfo: OrderInfo) => {
                if (orderInfo.orderNo === this.info.orderNo) {
                  orderInfo.orderState = OrderState.Cancelled;
                }
              });
              sampleOrderInfo.orderInfos = sampleOrderInfo.orderInfos;
              this.refreshEvent();
            } else {
              let sampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
              let arr = sampleOrderInfo.orderInfos.filter((item: OrderInfo) => item.orderNo !== this.info.orderNo);
              sampleOrderInfo.orderInfos = arr;
              this.refreshEvent();
            }
          });
        Button(this.info.orderState === OrderState.WaitToPay ? '立即支付' :
          (this.info.orderState === OrderState.Paid ? '立即学习' : '重新下单'))
          .padding(0)
          .backgroundColor($r('sys.color.multi_color_08'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .width(72)
          .height(28)
          .margin({ left: 8 })
          .onClick(() => {
            if (this.info.orderState === OrderState.Cancelled || this.info.orderState === OrderState.WaitToPay) {
              let sampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
              sampleOrderInfo.orderInfos.forEach((orderInfo: OrderInfo) => {
                if (orderInfo.orderNo === this.info.orderNo) {
                  orderInfo.orderState = OrderState.Paid;
                }
              });
              sampleOrderInfo.orderInfos = sampleOrderInfo.orderInfos;
              this.refreshEvent();
            } else if (this.info.orderState === OrderState.Paid) {
              // 跳转我的课程详情页
              RouterModule.push({ url: RouterMap.COURSE_INTRODUCTION_PAGE });
            }
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({ top: 12 });
    }
    .onClick(() => {
      let myInfo: MyInfo = new MyInfo();
      myInfo.info = this.info;
      myInfo.refreshCallback = () => {
        this.refreshEvent();
      };
      RouterModule.push({ url: RouterMap.Order_Detail_PAGE, param: myInfo });
    })
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: 12,
      right: 12,
      top: $r('app.float.vp_16'),
      bottom: $r('app.float.vp_16')
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .width('100%')
    .height(180)
    .borderRadius($r('app.float.vp_16'));
  }
}

export class MyInfo {
  info: OrderInfo = new OrderInfo('', false, OrderState.WaitToPay, '', '', false, false);
  refreshCallback: () => void = () => {
  };
}