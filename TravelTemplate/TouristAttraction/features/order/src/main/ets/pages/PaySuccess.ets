import { common } from '@kit.AbilityKit';
import { Constant, Logger, SystemUtil } from 'common';
import { TitleBar } from 'uicomponents';
import { GetOrderDetailRequest, https } from 'network';
import { mapTicketOrderDetail } from '../mapper/Index';
import { TicketOrderInfo } from 'types';

@Builder
export function PaySuccessBuilder() {
  PaySuccess();
}

@ComponentV2
export struct PaySuccess {
  @Local orderNo: string = '';
  @Local category: number = 0;
  @Local ticketOrderInfo: TicketOrderInfo = new TicketOrderInfo();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: DeleteConfirmDialog({
      cancel: () => {
        this.routerToInfo()
      },
      confirm: () => {
        this.addEvent(this.getUIContext().getHostContext() as common.UIAbilityContext)
      },
    }),
    customStyle: false,
    autoCancel: true,
  });

  routerToInfo() {
    this.mainPathStack.pushPathByName(this.category === 0 ? 'TicketOrderDetail' : 'CommodityOrderDetail', {
      category: this.category,
      orderNo: this.orderNo,
    } as GetOrderDetailRequest);
  }

  async addEvent(context: Context) {
    const timeStamp = new Date(this.ticketOrderInfo.startTime).getTime()
    const isSuccess = await SystemUtil.addEvent(timeStamp, this.ticketOrderInfo.productName, context);
    if (!isSuccess) {
      this.getUIContext().getPromptAction().showToast({ message: $r('app.string.toast_schedule_added_fail') });
      this.routerToInfo()
      return;
    }
    this.getUIContext().getPromptAction().showToast({ message: $r('app.string.toast_schedule_added') });
    this.ticketOrderInfo.isAddSchedule = true
    this.updateOrder(this.ticketOrderInfo)
  }

  updateOrder(info: TicketOrderInfo) {
    let param: GetOrderDetailRequest = {
      category: 0,
      orderNo: info.orderNo,
      isAddSchedule: true,
    };
    https.modifyOrderDetail(param).then((res: ESObject) => {
      this.routerToInfo()
    });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '支付结果', clickEvent: () => {
            this.mainPathStack.pushPathByName('Main', '')
          },
        });

        Column() {
          Column({ space: 14 }) {
            Image($r('app.media.success')).height(80).width(80);
            Text('支付成功').fontSize($r('sys.float.Body_M')).fontColor('rgba(0, 0, 0, 0.6)');
          }.margin({ top: 90, bottom: 90 });

          Row() {
            Button('查看订单')
              .width(Constant.FULL_PERCENT)
              .padding({ left: 24, right: 24 })
              .backgroundColor('rgb(100, 187, 92)')
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize($r('sys.float.Body_M'))
              .onClick(() => {
                const arr = this.mainPathStack.getPathStack();
                if (arr.length >= 2 && arr[arr.length-2].name === 'TicketReserve') {
                  this.dialogController?.open()
                } else {
                  this.routerToInfo()
                }
              });
          }.padding({ left: 24, right: 24 });
        }.height('90%').justifyContent(FlexAlign.Start);
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      let params = context.pathInfo.param as GetOrderDetailRequest;
      this.orderNo = params.orderNo ?? '';
      this.category = params.category ?? 0;
      https.getOrderDetail(params).then((res: ESObject) => {
        this.ticketOrderInfo = mapTicketOrderDetail(res.data[0]);
      });
      Logger.info('purchase info is ' + this.orderNo);
    });
  }
}

@CustomDialog
export struct DeleteConfirmDialog {
  controller?: CustomDialogController;
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };

  build() {
    Column({ space: 16 }) {
      Text(`是否添加至日程`)
        .fontWeight(500)
        .width('100%')
        .textAlign(TextAlign.Center);

      Row({ space: 120 }) {
        Text('取消').fontWeight(500).opacity(0.6).onClick(() => {
          this.cancel()
          this.controller?.close();
        });
        Text('确认').fontWeight(500).fontColor('#E84026').onClick(() => {
          this.confirm();
          this.controller?.close();
        });
      }.width('100%').justifyContent(FlexAlign.Center);
    }
    .size({ width: '90%', height: 120 })
    .justifyContent(FlexAlign.Center)
  }
}