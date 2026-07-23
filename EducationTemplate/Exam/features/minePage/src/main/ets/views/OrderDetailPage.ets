/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import { pasteboard } from '@kit.BasicServicesKit';
import { Header } from '../components/Header';
import {
  GlobalContextUtils, OrderInfo, OrderState, SampleOrderInfo, RouterMap, RouterModule, BreakpointType,
  BreakpointModel
} from 'commonlib';
import { MyInfo } from './OrderListPage';

@Builder
export function OrderDetailBuilder() {
  OrderDetailPage();
}

@ComponentV2
export struct OrderDetailPage {
  textTimerController: TextTimerController = new TextTimerController();
  @Local info: OrderInfo = new OrderInfo('', false, OrderState.WaitToPay, '', '', false, false);
  refreshCallback: () => void = () => {
  };
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  buttonWidth: BreakpointType<number> = new BreakpointType<number>({
    sm: 160,
    md: 448,
    lg: 448,
    xl: 448,
  });

  @Computed
  get getButtonWidth() {
    return this.buttonWidth.getValue(this.breakpointModel.currentBreakpoint);
  }

  @Builder
  infoItem(title: string, content: string, image?: Resource) {
    Row() {
      Text(title)
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(22);
      Text(content)
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ left: 12 })
        .lineHeight(20);
      Blank();
      if (image) {
        Image(image)
          .width(12).height(12)
          .onClick(() => {
            if (title === '订单编号') {
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
            }
          });
      }
    }
    .width('100%')
    .margin({ top: 12 });
  }

  @Builder
  goodsTipInfo() {
    Column() {
      Text(this.info.orderState === OrderState.WaitToPay ? '待支付...' :
        (this.info.orderState === OrderState.Paid ? '已完成' : '已取消'))
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));
      if (this.info.orderState === OrderState.WaitToPay) {
        Row() {
          Text('订单将在 ')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'));
          // 计时器
          TextTimer({
            isCountDown: true,
            count: this.info.startTime + 30 * 60 * 1000 - Date.now(),
            controller: this.textTimerController
          })
            .format('HH:mm:ss')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.multi_color_08'))
            .onTimer((_utc: number, elapsedTime: number) => {
              if (elapsedTime >= (this.info.startTime + 30 * 60 * 1000 - Date.now()) / 100) {
                this.info.orderState = OrderState.Cancelled;
                GlobalContextUtils.showToast({ message: '订单已取消' });
              }
            })
            .onAppear(() => {
              this.textTimerController.start();
            })
            .onDisAppear(() => {
              this.textTimerController.reset();
            });
          Text(' 后自动取消')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'));
        }
        .height(19)
        .margin({ top: 6 });
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ left: 8, top: 24 });
  }

  @Builder
  goodsDetailInfo() {
    Column() {
      Text('商品信息')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));
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
      Divider()
        .strokeWidth(2)
        .color($r('sys.color.comp_divider'))
        .margin({ top: 12 });
      Row() {
        Text('实际金额：')
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
    }
    .alignItems(HorizontalAlign.Start)
    .height(154)
    .borderRadius($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(12)
    .margin({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), top: 24 })
    .width('100%');
  }

  @Builder
  orderInfo() {
    Column() {
      Text('订单信息')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));
      Divider()
        .strokeWidth(2)
        .color($r('sys.color.comp_divider'))
        .margin({ top: 12 });
      this.infoItem('支付方式', '华为支付', $r('app.media.iconRight'));
      this.infoItem('订单编号', this.info.orderNo, $r('app.media.copy'));
      this.infoItem('下单时间', '2025-02-12  14:20:50', undefined);
    }
    .alignItems(HorizontalAlign.Start)
    .height(157)
    .borderRadius($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .padding(12)
    .margin({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), top: 12 })
    .width('100%');
  }

  @Builder
  orderBottomInfo() {
    Row() {
      if (this.info.orderState === OrderState.WaitToPay) {
        Text('合计：')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ left: 21 });
        Text('￥' + this.info.price)
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.multi_color_08'))
          .margin({ left: 2 });
      }
      Blank();
      Button(this.info.orderState === OrderState.WaitToPay ? '立即支付' :
        (this.info.orderState === OrderState.Paid ? '立即学习' : '重新下单'))
        .backgroundColor($r('sys.color.multi_color_08'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .width(this.getButtonWidth)
        .height(40)
        .onClick(() => {
          if (this.info.orderState === OrderState.Cancelled) {
            let sampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
            sampleOrderInfo.orderInfos.forEach((orderInfo: OrderInfo) => {
              if (orderInfo.orderNo === this.info.orderNo) {
                orderInfo.orderState = OrderState.Paid;
              }
            });
            sampleOrderInfo.orderInfos = sampleOrderInfo.orderInfos;
            this.refreshCallback();
            RouterModule.pop(true);
          } else if (this.info.orderState === OrderState.WaitToPay) {
            let sampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
            sampleOrderInfo.orderInfos.forEach((orderInfo: OrderInfo) => {
              if (orderInfo.orderNo === this.info.orderNo) {
                orderInfo.orderState = OrderState.Paid;
              }
            });
            sampleOrderInfo.orderInfos = sampleOrderInfo.orderInfos;
            this.refreshCallback();
            RouterModule.pop(true);
          } else if (this.info.orderState === OrderState.Paid) {
            RouterModule.push({ url: RouterMap.COURSE_INTRODUCTION_PAGE });
          }
        })
        .margin({ right: $r('app.float.vp_16') });
    }
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Bottom)
    .backgroundColor($r('sys.color.comp_background_primary'));
  }

  aboutToAppear(): void {
    let temp = RouterModule.getNavParam({ url: RouterMap.Order_Detail_PAGE }) as MyInfo;
    if (temp) {
      this.info = temp.info;
      this.refreshCallback = temp.refreshCallback;
    }
  }

  build() {
    Column() {
      Header({ title: '订单详情' })
        .width('100%')
        .height(56);

      Column() {
        this.goodsTipInfo();
        this.goodsDetailInfo();
        this.orderInfo();
      }
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'));

      Blank()
        .layoutWeight(1)
        .backgroundColor($r('sys.color.background_secondary'));

      this.orderBottomInfo();
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}
