import { MyOrdersVM } from '../viewModels/MyOrdersVM';
import { CommonConstants } from 'commonlib';
import { OrderClass } from '../types/Index';
import { TicketOwner } from 'network';
import { AlertDialog } from '@kit.ArkUI';

@Builder
export function TicketDetailBuilder() {
  TicketDetail();
}


@ComponentV2
struct TicketDetail {
  vm: MyOrdersVM = MyOrdersVM.instance;
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '确定要取消订单吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.cancelOrderInDetail(this.vm.orderDetail!.orderNo);
        },
      },
    }),
  });

  aboutToAppear(): void {
    this.vm.getOrderDetail();
  }

  build() {
    NavDestination() {
      if (this.vm.isLoading) {
        LoadingProgress().width(40);
      } else {
        Scroll() {
          Column() {
            this.tagBuilder();
            Row() {
              Text(this.vm.orderDetail?.performanceName)
                .fontColor(CommonConstants.FONT_COLOR_BLACK)
                .fontSize(CommonConstants.FONT_SIZE_M)
                .fontWeight(500);
              Text(this.vm.orderDetail?.visitTime)
                .fontColor(CommonConstants.FONT_COLOR_BLACK)
                .fontSize(CommonConstants.FONT_SIZE_M)
                .fontWeight(500);
            }
            .width('100%')
            .height(40)
            .backgroundColor('#1A0A554A')
            .padding({ left: 10, right: 10 })
            .justifyContent(FlexAlign.SpaceBetween);

            this.noticeBuilder();
            Column() {
              if (!this.vm.orderDetail?.isFree) {
                this.ticketOwnerBuilder();
              }
              this.orderInfoBuilder();
            }.padding(10).backgroundColor(CommonConstants.BG_COLOR_WHITE);

          }
          .width('100%')
          .backgroundColor(CommonConstants.BG_COLOR_GRAY)
          .constraintSize({ minHeight: CommonConstants.FULL_HEIGHT })
          .padding({ bottom: 10 });
        }
        .scrollBar(BarState.Off)
        .height(this.vm.orderDetail && this.vm.orderDetail.status === OrderClass.PENDING_PAYMENT ? 'calc(100% - 65vp)' :
        CommonConstants.FULL_HEIGHT);

        if (this.vm.orderDetail && this.vm.orderDetail.status === OrderClass.PENDING_PAYMENT) {
          Row() {
            Button('取消订单')
              .fontWeight(500)
              .width(72)
              .height(28)
              .margin({ right: 10 })
              .backgroundColor('#0C000000')
              .fontSize(CommonConstants.FONT_SIZE_M)
              .padding(0)
              .fontColor(CommonConstants.FONT_COLOR_BLACK)
              .onClick(() => {
                this.dialogControllerConfirm.open();
              });
            Button('去付款')
              .fontWeight(500)
              .width(72)
              .height(28)
              .backgroundColor(CommonConstants.FONT_COLOR_GREEN)
              .fontSize(CommonConstants.FONT_SIZE_M)
              .padding(0)
              .onClick(() => {
                this.vm.toPay(this.vm.orderDetail?.orderStr as string);
              });

          }
          .height(65)
          .width('100%')
          .backgroundColor(CommonConstants.BG_COLOR_WHITE)
          .justifyContent(FlexAlign.End)
          .padding(10);
        }
      }


    }.title(this.vm.navTitle);
  }

  @Builder
  ticketOwnerBuilder() {
    Text('购票人信息').commonTitleStyle();
    Divider();
    Column() {
      Row() {
        Text('购票人:').commonTextStyle().width(61);
        Column() {
          ForEach(this.vm.orderDetail?.ticketOwner, (item: TicketOwner) => {
            Row() {
              Text(item.name + `（${this.vm.ticketTypeMap.get(item.ticketType)}）`).commonTextStyle().width(120);
              Text(`×${item.ticket}张`).commonTextStyle().width(40);
              Text('¥' + item.price).commonTextStyle();
            }.justifyContent(FlexAlign.SpaceBetween).width('100%');
          }, (item: TicketOwner) => item.personId);
          Divider();
          Row() {
            Text('合计').commonTextStyle().width(120);
            Text(`×${this.vm.getTotal(this.vm.orderDetail?.ticketOwner).total}张`).commonTextStyle().width(40);
            Text('¥' + this.vm.getTotal(this.vm.orderDetail?.ticketOwner).totalPrice).commonTextStyle();
          }.justifyContent(FlexAlign.SpaceBetween).width('100%');
        }.width('calc(100% - 61vp)');
      }.alignItems(VerticalAlign.Top);

      Row() {
        Text('联系电话:').commonTextStyle().width(61);
        Text(this.vm.orderDetail?.contactPhone).commonTextStyle();
      };
    }.alignItems(HorizontalAlign.Start).width('100%');

    Divider().margin({ bottom: 10 });
  }

  @Builder
  orderInfoBuilder() {
    Text('订单信息').commonTitleStyle();
    Column() {
      if (this.vm.orderDetail?.isFree) {
        this.visitorBuilder();
      } else {
        Text('下单时间：' + this.vm.orderDetail?.placeTime).commonTextStyle();
        if (this.vm.orderDetail?.status !== OrderClass.PENDING_PAYMENT && this.vm.orderDetail?.payTime) {
          Text('付款时间：' + this.vm.orderDetail?.payTime).commonTextStyle();
        }
        if (this.vm.orderDetail?.status !== OrderClass.PENDING_PAYMENT && this.vm.orderDetail?.actualPay) {
          Text('实付款：' + this.vm.orderDetail?.actualPay).commonTextStyle();
        }
      }
      if (this.vm.orderDetail?.status === OrderClass.INVALIDATION) {
        Text('取消时间：' + this.vm.orderDetail?.cancelTime).commonTextStyle();
      }

    }.alignItems(HorizontalAlign.Start).width('100%');
  }

  @Builder
  visitorBuilder() {
    Text(`参观人：${this.vm.orderDetail?.visitors?.map(item => item.name).join('、')}`).commonTextStyle();
    Text(`参观人数：${this.vm.orderDetail?.visitors?.length}人`).commonTextStyle();
    Text(`联系电话：${this.vm.orderDetail?.contactPhone}`).commonTextStyle();
    Text('预约时间：' + this.vm.orderDetail?.orderTime).commonTextStyle();
  }

  @Builder
  tagBuilder() {
    Row({ space: 7.5 }) {
      Image(this.vm.getIcon(this.vm.orderDetail?.status ?? '')).width(20);
      Text(this.vm.getLabel(this.vm.orderDetail?.status ?? ''))
        .fontSize(CommonConstants.FONT_SIZE_L)
        .fontColor(CommonConstants.FONT_COLOR_BLACK);
    }.height(48).width('100%').padding({ left: 12 });
  }

  @Builder
  noticeBuilder() {
    Column({ space: 10 }) {
      Text('温馨提示').fontColor(CommonConstants.FONT_COLOR_BLACK);
      ForEach(this.vm.orderDetail?.notice, (item: string[]) => {
        Column() {
          ForEach(item, (v: string) => {
            Text(v).fontSize(CommonConstants.FONT_SIZE_S).fontColor(CommonConstants.FONT_COLOR_BLACK);
          }, (v: string) => v);
        }.alignItems(HorizontalAlign.Start).width('100%');
      }, (item: string[], index) => index.toString());

    }
    .padding({
      left: 20,
      right: 20,
      bottom: 10,
      top: 20,
    })
    .backgroundColor(CommonConstants.BG_COLOR_WHITE)
    .margin({ bottom: 10 });
  }
}

@Extend(Text)
function commonTextStyle() {
  .height(32).fontSize(CommonConstants.FONT_SIZE_S).fontColor(CommonConstants.FONT_COLOR_BLACK);
}

@Extend(Text)
function commonTitleStyle() {
  .fontSize(CommonConstants.FONT_SIZE_L)
  .height(21)
  .fontWeight(500)
  .fontColor(CommonConstants.FONT_COLOR_BLACK)
  .width('100%')
  .margin({ bottom: 4 });
}
