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
  CommonUtils,
  OrderStatus,
  CommonConstants,
  FormItem,
  FormType,
  UIOrderPart,
  FullOrderInfo,
  RouterModule,
  RouterMap,
  getOrder,
} from 'utils'
import { MyOrderDetailVM } from '../viewmodel/MyOrderDetailVM';
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function MyOrderDetailBuilder() {
  MyOrderDetail()
}

@Extend(Column)
function cardContainer() {
  .width(CommonConstants.FULL_PERCENT)
  .padding(10)
  .borderRadius(8)
  .backgroundColor(Color.White)
  .alignItems(HorizontalAlign.Start)
}

@ComponentV2
export struct MyOrderDetail {
  orderDetailVM: MyOrderDetailVM = new MyOrderDetailVM();

  aboutToAppear(): void {
    this.orderDetailVM.init();
  }

  build() {
    NavDestination() {
      Column() {
        Refresh({ refreshing: $$this.orderDetailVM.isRefreshing }) {
          Scroll() {
            Column({ space: 10 }) {
              this.TitleInfo()
              this.AppointInfoCard()
              this.GoodInfoCard()
              this.RemarkInfoCard()
              this.TicketInfoCard()
            }.alignItems(HorizontalAlign.Start)
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .align(Alignment.Top)
          .padding(10)
        }
        .layoutWeight(1)
        .onRefreshing(() => {
          this.orderDetailVM.onRefreshing();
        })

        this.bottomOperate()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title('订单详情', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
    .onBackPressed(() => {
      RouterModule.pop(1);
      return true;
    })
  }

  @Computed
  get isRefunded() {
    return this.orderDetailVM.fullOrderInfo.status === OrderStatus.REFUND_DONE;
  }

  @Computed
  get getTitle() {
    return this.orderDetailVM.fullOrderInfo.status;
  }

  @Computed
  get getTitleIcon() {
    if (this.isRefunded) {
      return $r('app.media.ic_order_refund');
    }
    if ([OrderStatus.TO_PAY, OrderStatus.TO_USE,
      OrderStatus.REFUND_ING].includes(this.orderDetailVM.fullOrderInfo.status)) {
      return $r('app.media.ic_order_to_use');
    }
    return $r('app.media.ic_order_finished');
  }

  @Builder
  TitleInfo() {
    Row({ space: 10 }) {
      Image(this.getTitleIcon)
        .width(20).height(20)
      Text(this.getTitle).fontSize(16).fontWeight(500)
    }
    .padding({ top: 12, bottom: 12 })
  }

  @Builder
  AppointInfoCard() {
    Column() {
      FormItem({
        param: {
          type: FormType.TEXT,
          label: '预约地址',
        },
        value: this.orderDetailVM.fullOrderInfo.addressName,
      })

      FormItem({
        param: {
          type: FormType.TEXT,
          label: '上门时间',
          last: true,
        },
        value: CommonUtils.formatDateTime(this.orderDetailVM.fullOrderInfo.appointTime),
      })
    }
    .cardContainer()
  }

  @Builder
  GoodInfoCard() {
    Column({ space: 4 }) {
      UIOrderPart({ simpleOrderInfo: this.orderDetailVM.fullOrderInfo, isFromMine: true })
    }
    .cardContainer()
  }

  @Builder
  RemarkInfoCard() {
    Column() {
      FormItem({
        param: {
          type: FormType.TEXT,
          label: '备注',
          last: true,
        },
        value: this.orderDetailVM.fullOrderInfo.remark || '暂无',
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ left: 10, right: 10 })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  @Builder
  TicketInfoCard() {
    Column({ space: 10 }) {
      Text('订单信息').fontWeight(500)
      Column({ space: 10 }) {
        Row() {
          Text('订单号').fontSize(12).width(80)
          Text(this.orderDetailVM.fullOrderInfo.orderId).fontSize(12)
        }

        if (this.orderDetailVM.fullOrderInfo.payTime) {
          Row() {
            Text('交易方式').fontSize(12).width(80)
            Text('华为支付').fontSize(12)
          }
        }

        Row() {
          Text('手机号').fontSize(12).width(80)
          Text(this.orderDetailVM.fullOrderInfo.contactPhone).fontSize(12)
        }

        Row() {
          Text('下单时间').fontSize(12).width(80)
          Text(CommonUtils.formatDateTime(this.orderDetailVM.fullOrderInfo.orderTime)).fontSize(12)
        }

        if (this.orderDetailVM.fullOrderInfo.payTime) {
          Row() {
            Text('付款时间').fontSize(12).width(80)
            Text(CommonUtils.formatDateTime(this.orderDetailVM.fullOrderInfo.payTime)).fontSize(12)
          }
        }
        if (this.isRefunded && this.orderDetailVM.fullOrderInfo.refundTime) {
          Row() {
            Text('退款时间').fontSize(12).width(80)
            Text(CommonUtils.formatDateTime(this.orderDetailVM.fullOrderInfo.refundTime)).fontSize(12)
          }
        } else if (this.orderDetailVM.fullOrderInfo.consumeTime) {
          Row() {
            Text('使用时间').fontSize(12).width(80)
            Text(CommonUtils.formatDateTime(this.orderDetailVM.fullOrderInfo.consumeTime)).fontSize(12)
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .cardContainer()
  }

  @Builder
  bottomOperate() {
    if ([OrderStatus.TO_PAY].includes(this.orderDetailVM.fullOrderInfo.status)) {
      Row() {
        Button('立即支付')
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(500)
          .width(CommonConstants.FULL_PERCENT)
          .height(40)
          .backgroundColor($r('app.color.common_theme_color'))
          .onClick(() => {
            this.orderDetailVM.payOrder();
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: 10,
        right: 10,
        top: 16,
        bottom: 16,
      })
      .backgroundColor(Color.White)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
  }
}
