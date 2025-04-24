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
import {
  callPhone,
  cancelOrder,
  CommonUtils,
  OrderStatus,
  refund,
  RouterMap,
  RouterModule,
  FullOrderInfo,
  UIOrderPart,
  HomeBaseInfo,
  CommonConstants,
  payOrder,
} from 'utils';

@ComponentV2
struct OperateBtn {
  @Param label: string = '';
  @Param fgColor: ResourceColor = Color.Black;
  @Param bgColor: ResourceColor = $r('app.color.grey_5');

  build() {
    Button() {
      Text(this.label)
        .fontSize(14)
        .fontWeight(500)
        .fontColor(this.fgColor)
        .width(56)
        .height(20)
        .textAlign(TextAlign.Center)
    }
    .backgroundColor(this.bgColor)
    .padding({
      top: 4,
      bottom: 4,
      left: 8,
      right: 8,
    })
  }
}

@ComponentV2
export struct OrderCard {
  @Param fullOrderInfo: FullOrderInfo = new FullOrderInfo();
  @Event refreshList: () => void = () => {
  };
  @Event jumpTab: (tabIndex: number) => void = () => {
  };
  @Local showApplyRefundSheet: boolean = false;
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;

  build() {
    Column() {
      // 上半部分
      Column({ space: 10 }) {
        Text(this.fullOrderInfo.status)
          .fontSize(12)
          .fontColor($r('app.color.common_theme_color'))
          .alignSelf(ItemAlign.End)

        UIOrderPart({ simpleOrderInfo: this.fullOrderInfo, isFromMine: true })
        if (this.isShowAppointCard) {
          this.AppointmentCard()
        }
      }
      .padding(10)
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor(Color.White)
      .borderWidth({ bottom: 0.5 })
      .borderColor($r('app.color.grey_20'))
      .borderRadius({
        topLeft: 8,
        topRight: 8,
      })
      .onClick(() => {
        RouterModule.push({
          url: RouterMap.MY_ORDER_DETAIL,
          param: this.fullOrderInfo,
          onPop: () => {
            this.refreshList();
          },
        });
      })

      // 下半部分
      Row({ space: 10 }) {
        if (this.isShowCancel) {
          this.CancelBtn()
        }
        if (this.isShowPay) {
          this.PayBtn()
        }
        if (this.isShowRefund) {
          this.ApplyRefundBtn()
        }
        if (this.isShowMore) {
          this.ViewMoreBtn()
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding(10)
      .backgroundColor(Color.White)
      .borderRadius({ bottomLeft: 8, bottomRight: 8 })
      .justifyContent(FlexAlign.End)
    }
  }

  @Builder
  AppointmentCard() {
    Column({ space: 10 }) {
      Row({ space: 2 }) {
        Text('上门时间：').fontSize(10)
        Text(CommonUtils.formatDateTime(this.fullOrderInfo.appointTime))
          .fontSize(10)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
      }

      Row({ space: 2 }) {
        Text('预约地址：').fontSize(10)
        Text(this.fullOrderInfo.addressName).fontSize(10).layoutWeight(1).textAlign(TextAlign.Start)
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(10)
    .borderRadius(4)
    .backgroundColor($r('app.color.common_theme_color_5'))
  }

  @Builder
  SheetAfterSale() {
    Column({ space: 10 }) {
      Row() {
        Text('联系客服')
        Blank()
        Image($r('app.media.ic_public_arrow_right')).width(12)
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding(10)
      .borderRadius(8)
      .backgroundColor(Color.White)
      .onClick(() => {
        CommonUtils.openConfirmDialog({
          content: `联系电话 ${this.homeBaseInfo.hotline}`,
          priBtnV: '取消',
          secBtnV: '联系客服',
          secBtnRole: ButtonRole.NORMAL,
          confirm: () => {
            this.showApplyRefundSheet = false;
            callPhone(this.homeBaseInfo.hotline);
          },
        })
      })

      Row() {
        Text('申请退款')
        Blank()
        Image($r('app.media.ic_public_arrow_right')).width(12)
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding(10)
      .borderRadius(8)
      .backgroundColor(Color.White)
      .onClick(() => {
        this.showApplyRefundSheet = false;
        refund(this.fullOrderInfo.orderId).then(() => {
          CommonUtils.openNoticeDialog({
            content: '已提交退款申请，等待商家退款，退款成功将短信通知您',
            confirm: () => {
              this.refreshList();
            },
          });
        });
      })
    }
    .padding({ left: 10, right: 10, bottom: 40 })
  }

  @Builder
  CancelBtn() {
    OperateBtn({
      label: '取消订单',
    }).onClick(() => {
      cancelOrder(this.fullOrderInfo.orderId).then(() => {
        this.getUIContext().getPromptAction().showToast({ message: '订单已取消' });
        this.jumpTab(0);
      });
    })
  }

  @Builder
  ApplyRefundBtn() {
    OperateBtn({
      label: '申请售后',
    })
      .bindSheet($$this.showApplyRefundSheet, this.SheetAfterSale(), {
        height: SheetSize.FIT_CONTENT,
        title: { title: '申请售后' },
      })
      .onClick(() => {
        this.showApplyRefundSheet = true;
      })
  }

  @Builder
  ViewMoreBtn() {
    OperateBtn({
      label: '查看详情',
    })
      .onClick(() => {
        RouterModule.push({
          url: RouterMap.MY_ORDER_DETAIL,
          param: this.fullOrderInfo,
          onPop: () => {
            this.refreshList();
          },
        });
      })
  }

  @Builder
  PayBtn() {
    OperateBtn({
      label: '去支付',
      fgColor: Color.White,
      bgColor: $r('app.color.common_theme_color'),
    })
      .onClick(() => {
        payOrder(this.fullOrderInfo.orderId).then(() => {
          this.getUIContext().getPromptAction().showToast({ message: '支付成功' });
          this.jumpTab(2);
        })
      })
  }

  @Computed
  get isShowAppointCard() {
    return [OrderStatus.TO_USE].includes(this.fullOrderInfo.status);
  }

  @Computed
  get isShowCancel() {
    return [OrderStatus.TO_PAY].includes(this.fullOrderInfo.status);
  }

  @Computed
  get isShowPay() {
    return [OrderStatus.TO_PAY].includes(this.fullOrderInfo.status);
  }

  @Computed
  get isShowRefund() {
    return [OrderStatus.NORMAL_FINISH, OrderStatus.TO_USE].includes(this.fullOrderInfo.status);
  }

  @Computed
  get isShowMore() {
    return [OrderStatus.REFUND_ING, OrderStatus.REFUND_DONE, OrderStatus.CANCEL].includes(this.fullOrderInfo.status);
  }
}