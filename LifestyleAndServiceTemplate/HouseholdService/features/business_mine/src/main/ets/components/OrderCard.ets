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
import { calendarManager } from '@kit.CalendarKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { DialPanel } from 'dial_panel';
import {
  cancelOrder,
  CommonConfirmDialog,
  CommonConstants,
  CurAppInfo,
  FullOrderInfo,
  HomeBaseInfo,
  IAppointmentUpdate,
  OrderStatus,
  OrderToPayParam,
  payOrder,
  PushUtils,
  refund,
  RouterModule,
  UIOrderPart,
  updateAppointmentInfo,
} from 'lib_foundation';
import { CommonUtils, RouterMap, SystemSceneUtils, WindowUtil } from 'module_base';
import { CountDownVM } from '../viewmodel/CountDownVM';

const TAG = '[OrderCard]'

@ComponentV2
struct OperateBtn {
  @Param breakpoint: string = '';
  @Param isShowSubscribe: boolean = true;
  @Param btnWidth: number = 0;
  @Param label: string = '';
  @Param fgColor: ResourceColor = $r('sys.color.font_primary');
  @Param bgColor: ResourceColor = $r('sys.color.comp_background_tertiary');

  build() {
    if (this.breakpoint === 'sm') {
      Button(this.label)
        .fontSize(this.label.length === 4 ? $r('sys.float.Body_M') : $r('sys.float.Body_S'))
        .fontWeight(500)
        .fontColor(this.fgColor)
        .height(28)
        .width(this.btnWidth)
        .backgroundColor(this.bgColor)
        .padding({
          top: 4,
          bottom: 4,
        })
    } else {
      Button(this.label)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(500)
        .fontColor(this.fgColor)
        .constraintSize({ minWidth: 96 })
        .height(28)
        .backgroundColor(this.bgColor)
        .padding({
          top: 4,
          bottom: 4,
          left: 20,
          right: 20,
        })
    }
  }
}

@ComponentV2
export struct OrderCard {
  @Param breakpoint: string = '';
  @Param fullOrderInfo: FullOrderInfo = new FullOrderInfo();
  @Local containerWidth: number = 0;
  homeBaseInfo: HomeBaseInfo = AppStorageV2.connect(HomeBaseInfo, () => new HomeBaseInfo())!;
  countDownVM: CountDownVM = CountDownVM.instance;
  private uiContext: UIContext = this.getUIContext();
  private dialPanel: DialPanel = new DialPanel(this.uiContext);

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
  }

  @Computed
  get isShowCancel() {
    return [OrderStatus.TO_PAY].includes(this.fullOrderInfo.status);
  }

  @Computed
  get isShowSubscribe() {
    return [OrderStatus.TO_USE].includes(this.fullOrderInfo.status);
  }

  @Computed
  get isShowSmallBtn() {
    return this.isShowSubscribe && (this.breakpoint === 'sm');
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
  get isShowContact() {
    return [OrderStatus.TO_USE, OrderStatus.NORMAL_FINISH, OrderStatus.REFUND_ING, OrderStatus.REFUND_DONE,
      OrderStatus.CANCEL].includes(this.fullOrderInfo.status);
  }

  @Computed
  get btnWidth() {
    return (this.containerWidth - 24) / 4;
  }

  @Event refreshList: () => void = () => {
  };
  @Event jumpTab: (tabIndex: number) => void = () => {
  };

  build() {
    Column() {
      // 上半部分
      Column({ space: 12 }) {
        Row() {
          Text(`订单号：${this.fullOrderInfo.orderId}`)
            .fontSize($r('sys.float.Caption_L'))
            .margin({ right: 4 })
          Image($r('app.media.ic_copy'))
            .width(16)
            .height(16)
            .onClick(() => {
              CommonUtils.copy(this.fullOrderInfo.orderId)
            })
          Blank()
          Text(this.fullOrderInfo.status)
            .fontSize($r('sys.float.Caption_L'))
            .fontColor(this.fullOrderInfo.status === OrderStatus.TO_PAY ? $r('sys.color.warning') :
              $r('sys.color.font_secondary'))
        }
        .width(CommonConstants.FULL_PERCENT)

        UIOrderPart({ simpleOrderInfo: this.fullOrderInfo })

        Divider().strokeWidth('1px').color($r('sys.color.comp_divider')).width(CommonConstants.FULL_PERCENT)
      }
      .width(CommonConstants.FULL_PERCENT)
      .onSizeChange(((_, newSize) => {
        this.containerWidth = newSize.width as number
      }))
      .onClick(() => {
        const paramToPay = new OrderToPayParam();
        paramToPay.orderInfo = this.fullOrderInfo;
        paramToPay.isFromOrderCard = true;
        RouterModule.push({
          url: RouterMap.MY_ORDER_DETAIL,
          param: paramToPay,
          onPop: () => {
            this.refreshList();
          },
        });
      })

      // 下半部分
      if (this.isShowSubscribe) {
        Row({ space: 8 }) {
          this.SubscribeNotificationBtn()
          this.CalendarBtn()
          this.ApplyRefundBtn()
          this.ContactCustomerServiceBtn()
        }
        .justifyContent(FlexAlign.End)
        .width(CommonConstants.FULL_PERCENT)
        .padding({ top: 12 })
      } else {
        this.BtnBuilder()
      }
    }
    .padding({
      left: 12,
      top: 16,
      right: 12,
      bottom: 16,
    })
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  BtnBuilder() {
    Row({ space: 8 }) {
      if (this.isShowCancel) {
        this.CancelBtn()
      }
      if (this.isShowPay) {
        this.PayBtn()
      }
      if (this.isShowRefund) {
        this.ApplyRefundBtn()
      }
      if (this.isShowContact) {
        this.ContactCustomerServiceBtn()
      }
    }
    .justifyContent(FlexAlign.End)
    .width(CommonConstants.FULL_PERCENT)
    .padding({ top: 12 })
  }

  @Builder
  CancelBtn() {
    OperateBtn({
      btnWidth: this.btnWidth,
      isShowSubscribe: this.isShowSubscribe,
      breakpoint: this.breakpoint,
      label: '取消订单',
    })
      .onClick(() => {
        CommonConfirmDialog.show({
          contentBuilder: CancelContentBuilder,
          confirm: () => {
            this.countDownVM.stopCountdown(this.fullOrderInfo.orderId);
            cancelOrder(this.fullOrderInfo.orderId).then(() => {
              this.jumpTab(0);
            });
          }
        })
      })
  }

  @Builder
  ApplyRefundBtn() {
    OperateBtn({
      btnWidth: this.btnWidth,
      isShowSubscribe: this.isShowSubscribe,
      breakpoint: this.breakpoint,
      label: '申请退款',
    })
      .onClick(() => {
        CommonConfirmDialog.show({
          contentBuilder: ApplyContentBuilder,
          confirm: () => {
            refund(this.fullOrderInfo.orderId).then(() => {
              this.refreshList();
            });
          }
        })
      })
  }

  @Builder
  PayBtn() {
    OperateBtn({
      btnWidth: this.btnWidth,
      isShowSubscribe: this.isShowSubscribe,
      breakpoint: this.breakpoint,
      label: '立即支付',
      fgColor: $r('sys.color.font_on_primary'),
      bgColor: $r('sys.color.comp_background_emphasize'),
    })
      .onClick(() => {
        this.countDownVM.stopCountdown(this.fullOrderInfo.orderId);
        payOrder(this.fullOrderInfo.orderId).then(() => {
          this.getUIContext().getPromptAction().showToast({ message: '支付成功' });
          this.jumpTab(2);
        })
      })
  }

  @Builder
  SubscribeNotificationBtn() {
    OperateBtn({
      btnWidth: this.btnWidth,
      breakpoint: this.breakpoint,
      label: this.fullOrderInfo.setSubscription ? '已订阅通知' : '订阅通知',
      bgColor: this.fullOrderInfo.setSubscription ? $r('sys.color.comp_emphasize_tertiary') :
        $r('sys.color.comp_background_tertiary'),
    })
      .onClick(async () => {
        if (!this.fullOrderInfo.setSubscription) {
          const resp = await SystemSceneUtils.requestSubscribeNotification(CurAppInfo.PUSH_TEMPLATE_ID);
          if (resp && resp?.entityResult?.length && resp.entityResult[0]?.resultCode === 0) {
            const appointInfo: IAppointmentUpdate = {
              orderId: this.fullOrderInfo.orderId,
              setSchedule: this.fullOrderInfo.setSchedule,
              setSubscription: true,
            }
            updateAppointmentInfo(appointInfo).then(() => {
              this.refreshList();
              // todo 模拟发送服务通知
              PushUtils.pushMessage(this.fullOrderInfo.title, this.fullOrderInfo.appointTime);
            });
          }
        } else {
          this.getUIContext().getPromptAction().showToast({ message: '订阅通知暂不支持取消' })
        }
      })
  }

  @Builder
  CalendarBtn() {
    OperateBtn({
      btnWidth: this.btnWidth,
      breakpoint: this.breakpoint,
      label: this.fullOrderInfo.setSchedule ? '已添加日程' : '添加日程',
      bgColor: this.fullOrderInfo.setSchedule ? $r('sys.color.comp_emphasize_tertiary') :
        $r('sys.color.comp_background_tertiary'),
    })
      .onClick(async () => {
        if (!this.fullOrderInfo.setSchedule) {
          await this.addEvent();
        } else {
          this.getUIContext().getPromptAction().showToast({ message: '日程提醒暂不支持取消' })
        }
      })
  }

  async addEvent() {
    const calendarMgr: calendarManager.CalendarManager | null = await SystemSceneUtils.getCalendarMgr();
    if (!calendarMgr) {
      return false;
    }
    const event: calendarManager.Event = {
      title: `家政服务${this.fullOrderInfo.title}`,
      type: calendarManager.EventType.NORMAL,
      startTime: new Date(this.fullOrderInfo.appointTime).getTime(),
      endTime: new Date(this.fullOrderInfo.appointTime).getTime() + 60 * 60 * 1000,
      reminderTime: [10],
    };
    try {
      const calendar = await calendarMgr.getCalendar();
      return calendar.addEvent(event).then((data: number) => {
        const appointInfo: IAppointmentUpdate = {
          orderId: this.fullOrderInfo.orderId,
          setSchedule: true,
          setSubscription: this.fullOrderInfo.setSubscription,
          calendarId: data,
        }
        updateAppointmentInfo(appointInfo).then(() => {
          this.refreshList();
          this.getUIContext().getPromptAction().showToast({ message: '已添加日程' });
        });
        UtilLog.info(TAG, 'success to add calendar event');
        return true;
      }).catch(() => {
        UtilLog.error(TAG, 'fail to add calendar event');
        return false;
      });
    } catch (error) {
      UtilLog.error(TAG, 'fail to get calendar');
      return false;
    }
  }

  @Builder
  ContactCustomerServiceBtn() {
    OperateBtn({
      btnWidth: this.btnWidth,
      isShowSubscribe: this.isShowSubscribe,
      breakpoint: this.breakpoint,
      label: '联系客服',
      fgColor: $r('sys.color.font_on_primary'),
      bgColor: $r('sys.color.comp_background_emphasize'),
    })
      .onClick(() => {
        this.dialPanel
          .setTitle('联系客服')
          .setPhoneNumber(this.homeBaseInfo.hotline)
          .open();
      })
  }
}

@Builder
export function CancelContentBuilder() {
  Column() {
    Text('温馨提示')
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Bold)
      .margin({ top: 16, bottom: 12 })
    Text('您是否要取消未支付的订单？')
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .margin({ bottom: 8 })
    Text('如果您确认取消订单，订单将不会恢复')
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_secondary'))
      .margin({ bottom: 8 })
  }
}

@Builder
export function ApplyContentBuilder() {
  Column() {
    Text('温馨提示')
      .fontSize($r('sys.float.Title_S'))
      .fontWeight(FontWeight.Bold)
      .margin({ top: 16, bottom: 12 })
    Text('您是否要申请退款？')
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .margin({ bottom: 8 })
    Text('如果您确认申请退款，商家会在24小时内完成退款，相关费用返还支付账号并短信通知您')
      .textAlign(TextAlign.Center)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_secondary'))
      .margin({ bottom: 8 })
  }
  .padding({ left: 12, right: 12 })
}