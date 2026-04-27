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
import { DialPanel } from 'dial_panel';
import {
  CommonConfirmDialog,
  CommonConstants,
  GridRowColSetting,
  HomeBaseInfo,
  OrderStatus,
  RouterModule,
  UIOrderPart,
} from 'lib_foundation';
import { CommonUtils, RouterMap, WindowUtil } from 'module_base';
import { FormItem, FormType } from 'module_form';
import { ApplyContentBuilder, CancelContentBuilder } from '../components/OrderCard';
import { MyOrderDetailVM } from '../viewmodel/MyOrderDetailVM';

@Builder
export function MyOrderDetailBuilder() {
  MyOrderDetail()
}

@Extend(Column)
function cardContainer() {
  .width(CommonConstants.FULL_PERCENT)
  .borderRadius(20)
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .alignItems(HorizontalAlign.Start)
}

@ComponentV2
export struct MyOrderDetail {
  @Local breakpoint: string = '';
  orderDetailVM: MyOrderDetailVM = new MyOrderDetailVM();
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  private uiContext: UIContext = this.getUIContext();
  private dialPanel: DialPanel = new DialPanel(this.uiContext);

  @Computed
  get isRefunded() {
    return this.orderDetailVM.fullOrderInfo.status === OrderStatus.REFUND_DONE;
  }

  @Computed
  get isToUse() {
    return this.orderDetailVM.fullOrderInfo.status === OrderStatus.TO_USE;
  }

  @Computed
  get isToPay() {
    return this.orderDetailVM.fullOrderInfo.status === OrderStatus.TO_PAY;
  }

  @Computed
  get isShowCancel() {
    return [OrderStatus.TO_PAY].includes(this.orderDetailVM.fullOrderInfo.status);
  }

  @Computed
  get isShowPay() {
    return [OrderStatus.TO_PAY].includes(this.orderDetailVM.fullOrderInfo.status);
  }

  @Computed
  get isShowRefund() {
    return [OrderStatus.NORMAL_FINISH, OrderStatus.TO_USE].includes(this.orderDetailVM.fullOrderInfo.status);
  }

  @Computed
  get isShowContact() {
    return [OrderStatus.TO_USE, OrderStatus.NORMAL_FINISH, OrderStatus.REFUND_ING, OrderStatus.REFUND_DONE,
      OrderStatus.CANCEL].includes(this.orderDetailVM.fullOrderInfo.status);
  }

  @Computed
  get getTitle() {
    if (this.isToUse) {
      return '已支付'
    }
    if (this.isToPay) {
      return '待支付...'
    }
    return this.orderDetailVM.fullOrderInfo.status;
  }

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
    this.orderDetailVM.init();
    this.orderDetailVM.autoCancelOrder();
  }

  build() {
    NavDestination() {
      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({ span: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS, }) {
          Column({ space: 12 }) {
            Refresh({ refreshing: $$this.orderDetailVM.isRefreshing }) {
              Scroll() {
                Column({ space: 12 }) {
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
              .padding({
                left: GridRowColSetting.getPageMargin(this.breakpoint),
                right: GridRowColSetting.getPageMargin(this.breakpoint)
              })
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
      }
      .onBreakpointChange((bp) => {
        this.breakpoint = bp;
      })
    }
    .onWillAppear(() => {
      this.orderDetailVM.getLeftTime();
    })
    .title('订单详情', {
      paddingStart: { value: GridRowColSetting.getPageMargin(this.breakpoint), unit: 1 }
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      if (!this.orderDetailVM.isFromOrderCard) {
        RouterModule.popToName(RouterMap.MAIN);
        return true;
      }
      RouterModule.pop(1);
      return true;
    })
  }

  @Builder
  TitleInfo() {
    Column({ space: 6 }) {
      Text(this.getTitle).fontSize(24).fontWeight(500).lineHeight(32)
      if (this.isToPay) {
        Text() {
          Span('订单将在').fontColor($r('sys.color.font_secondary'))
          Span(this.orderDetailVM.leftTime).fontColor($r('sys.color.multi_color_08'))
          Span('后自动取消').fontColor($r('sys.color.font_secondary'))
        }
        .lineHeight(19)
        .fontSize($r('sys.float.Body_M'))
      } else {
        Column().height(8)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 24,
      bottom: 4,
      left: 8,
      right: 8
    })
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
    .padding({ left: 12, right: 12 })
    .cardContainer()
  }

  @Builder
  GoodInfoCard() {
    Column({ space: 8 }) {
      Text('商品信息')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .lineHeight(24)
      UIOrderPart({ simpleOrderInfo: this.orderDetailVM.fullOrderInfo })
    }
    .padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12
    })
    .cardContainer()
  }

  @Builder
  RemarkInfoCard() {
    Column() {
      FormItem({
        param: {
          type: FormType.TEXT,
          label: '备注信息',
          last: true,
        },
        value: this.orderDetailVM.fullOrderInfo.remark || '暂无',
      })
    }
    .padding({ left: 12, right: 12 })
    .cardContainer()
  }

  @Builder
  TicketInfoCard() {
    Column({ space: 10 }) {
      Text('订单信息')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .lineHeight(24)
      Divider().strokeWidth('1px')
      Column({ space: 8 }) {
        Row({ space: 12 }) {
          Text('订单编号').fontWeight(FontWeight.Medium).fontSize(14).width(64)
          Text(this.orderDetailVM.fullOrderInfo.orderId)
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
            .layoutWeight(1)
          Image($r('app.media.ic_copy'))
            .width(16)
            .height(16)
            .onClick(() => {
              CommonUtils.copy(this.orderDetailVM.fullOrderInfo.orderId)
            })
        }

        Row({ space: 12 }) {
          Text('手机号').fontSize(14).fontWeight(FontWeight.Medium).width(64)
          Text(this.orderDetailVM.fullOrderInfo.contactPhone).fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
        }

        Row({ space: 12 }) {
          Text('下单时间').fontSize(14).fontWeight(FontWeight.Medium).width(64)
          Text(CommonUtils.formatDateTime(this.orderDetailVM.fullOrderInfo.orderTime)).fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
        }

        if (this.orderDetailVM.fullOrderInfo.payTime) {
          Row({ space: 12 }) {
            Text('支付方式').fontSize(14).fontWeight(FontWeight.Medium).width(64)
            Text('华为支付').fontSize(12).fontColor($r('sys.color.font_secondary'))
          }
        }

        if (this.orderDetailVM.fullOrderInfo.payTime) {
          Row({ space: 12 }) {
            Text('支付时间').fontSize(14).fontWeight(FontWeight.Medium).width(64)
            Text(CommonUtils.formatDateTime(this.orderDetailVM.fullOrderInfo.payTime)).fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }
        }
        if (this.isRefunded && this.orderDetailVM.fullOrderInfo.refundTime) {
          Row({ space: 12 }) {
            Text('退款时间').fontSize(14).fontWeight(FontWeight.Medium).width(64)
            Text(CommonUtils.formatDateTime(this.orderDetailVM.fullOrderInfo.refundTime)).fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }
        } else if (this.orderDetailVM.fullOrderInfo.consumeTime) {
          Row({ space: 12 }) {
            Text('使用时间').fontSize(14).fontWeight(FontWeight.Medium).width(64)
            Text(CommonUtils.formatDateTime(this.orderDetailVM.fullOrderInfo.consumeTime)).fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12
    })
    .cardContainer()
  }

  @Builder
  bottomOperate() {
    Row({ space: 8 }) {
      if (this.isShowCancel) {
        Row() {
          OperateBtn({
            label: '取消订单',
            fgColor: $r('sys.color.warning'),
            bgColor: $r('sys.color.comp_background_tertiary'),
          })
        }
        .layoutWeight(1)
        .onClick(() => {
          CommonConfirmDialog.show({
            contentBuilder: CancelContentBuilder,
            confirm: () => {
              this.orderDetailVM.cancelOrder();
            }
          })
        })
      }
      if (this.isShowPay) {
        Row() {
          OperateBtn({
            label: '立即支付',
          })
        }
        .layoutWeight(1)
        .onClick(() => {
          this.orderDetailVM.payOrder();
        })
      }
      if (this.isShowRefund) {
        Row() {
          OperateBtn({
            label: '申请退款',
            fgColor: $r('sys.color.warning'),
            bgColor: $r('sys.color.comp_background_tertiary'),
          })
        }
        .layoutWeight(1)
        .onClick(() => {
          CommonConfirmDialog.show({
            contentBuilder: ApplyContentBuilder,
            confirm: () => {
              this.orderDetailVM.applyRefund();
            }
          })
        })
      }
      if (this.isShowContact) {
        Row() {
          OperateBtn({
            label: '联系客服',
          })
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .onClick(() => {
          this.dialPanel
            .setTitle('联系客服')
            .setPhoneNumber(this.homeBaseInfo.hotline)
            .open();
        })
      }
    }
    .justifyContent(FlexAlign.Center)
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: 8,
      bottom: 8,
      left: 16,
      right: 16
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@ComponentV2
struct OperateBtn {
  @Param label: string = '';
  @Param fgColor: ResourceColor = $r('sys.color.font_on_primary');
  @Param bgColor: ResourceColor = $r('sys.color.comp_background_emphasize');

  build() {
    Button(this.label)
      .constraintSize({ maxWidth: 448 })
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(500)
      .fontColor(this.fgColor)
      .height(40)
      .layoutWeight(1)
      .backgroundColor(this.bgColor)
      .padding({
        top: 9,
        bottom: 9,
        left: 16,
        right: 16,
      })
  }
}
