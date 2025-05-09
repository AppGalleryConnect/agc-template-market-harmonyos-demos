import { RouterMap, RouterModule, CommonConstants, FormatUtil } from 'commonlib';
import { TicketListItem, TicketOwner, TicketTypeInfo } from '../types/Index';
import { BuyVM } from '../viewModels/BuyVM';
import { promptAction } from '@kit.ArkUI';


@Builder
export function BuyInfoBuilder() {
  BuyInfo();
}


@ComponentV2
struct BuyInfo {
  vm: BuyVM = BuyVM.instance;

  isBuyInfoValid(): boolean {
    if (!this.vm.contactPhone) {
      return false;
    }
    if (this.vm.ticketOwner.length === 0 || this.vm.ticketList.length > 0) {
      return false;
    }
    return true;
  }

  isPhoneValid(): boolean {
    const reg = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;
    if (!reg.test(this.vm.contactPhone)) {
      this.vm.isWarning = true;
      promptAction.showToast({ message: '联系电话格式不正确！' });
      return false;
    }
    return true;
  }

  aboutToAppear(): void {
    this.vm.clearOrderInfo()
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            this.ticketInfoBuilder();
            this.ticketListBuilder();
            ForEach(this.vm.ticketOwner.sort((a, b) => a.sortId - b.sortId), (item: TicketOwner, index) => {
              Column() {
                Row() {
                  Row({ space: 7 }) {
                    Text(`参观人${item.sortId}`)
                      .fontSize(CommonConstants.FONT_SIZE_M)
                      .fontColor(CommonConstants.FONT_COLOR_BLACK)
                      .fontWeight(500);
                    Text(item.typeCn)
                      .backgroundColor('#3392D6CC')
                      .fontSize(CommonConstants.FONT_SIZE_XS)
                      .fontColor(CommonConstants.FONT_COLOR_GREEN)
                      .padding({ left: 4, right: 4 })
                      .height(18)
                      .borderRadius(4);
                  };

                  Row({ space: 5.5 }) {
                    Image($r('app.media.icon_public_plus_1')).width(9);
                    Text('常用参观人')
                      .fontSize(CommonConstants.FONT_SIZE_XS)
                      .fontColor(CommonConstants.FONT_COLOR_GREEN);
                  }
                  .width(82)
                  .height(24)
                  .borderRadius(12)
                  .backgroundColor(CommonConstants.BG_COLOR_GREEN)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    RouterModule.push({ url: RouterMap.TICKET_OWNER, param: { ownerIndex: index } });
                  });

                }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                Divider().margin({ top: 10 });

                Row() {
                  Text('姓名')
                    .fontSize(CommonConstants.FONT_SIZE_L)
                    .fontColor(CommonConstants.FONT_COLOR_BLACK)
                    .fontWeight(500);
                  Text(item.name)
                    .textAlign(TextAlign.End)
                    .fontColor(CommonConstants.FONT_COLOR_BLACK)
                    .fontSize(CommonConstants.FONT_SIZE_M);
                }.height(48).width('100%').justifyContent(FlexAlign.SpaceBetween);

                Divider().margin({ bottom: 10 });
                Row() {
                  Text('证件类型')
                    .fontSize(CommonConstants.FONT_SIZE_L)
                    .fontColor(CommonConstants.FONT_COLOR_BLACK)
                    .fontWeight(500);
                  Text(item.cardType)
                    .textAlign(TextAlign.End)
                    .fontColor(CommonConstants.FONT_COLOR_BLACK)
                    .fontSize(CommonConstants.FONT_SIZE_M);
                }.height(48).width('100%').justifyContent(FlexAlign.SpaceBetween);

                Divider().margin({ bottom: 10 });
                Row() {
                  Text('证件号')
                    .fontSize(CommonConstants.FONT_SIZE_L)
                    .fontColor(CommonConstants.FONT_COLOR_BLACK)
                    .fontWeight(500);
                  Text(item.cardId)
                    .textAlign(TextAlign.End)
                    .fontColor(CommonConstants.FONT_COLOR_BLACK)
                    .fontSize(CommonConstants.FONT_SIZE_M);
                }.height(48).width('100%').justifyContent(FlexAlign.SpaceBetween);
              }.baseContainerStyle().margin({ top: 10 });
            }, (item: TicketOwner) => item.personId);


            Column() {
              Row() {
                Row({ space: 4 }) {
                  Text('联系电话').fontSize(CommonConstants.FONT_SIZE_M).fontColor(CommonConstants.FONT_COLOR_BLACK);
                  if (this.vm.isWarning) {
                    Image($r('app.media.ic_public_warning')).width(14);
                  }
                };

                TextInput({ text: this.vm.contactPhone, placeholder: '请输入联系电话' })
                  .type(InputType.PhoneNumber)
                  .fontSize(CommonConstants.FONT_SIZE_M)
                  .textAlign(TextAlign.End)
                  .width(150)
                  .backgroundColor('transparent')
                  .padding(0)
                  .onChange((res) => {
                    this.vm.contactPhone = res;
                    this.vm.isWarning = false;
                  });
              }.width('100%').justifyContent(FlexAlign.SpaceBetween);
            }.baseContainerStyle().margin({ top: 10, bottom: 20 });

          }.constraintSize({ minHeight: '100%' }).padding({ top: 10 });
        }.scrollBar(BarState.Off).height('calc(100% - 65vp)');

        Row() {
          Button('购票')
            .height(40)
            .width('100%')
            .backgroundColor(this.isBuyInfoValid() ? CommonConstants.FONT_COLOR_GREEN : CommonConstants.BG_COLOR_GREEN)
            .enabled(this.isBuyInfoValid())
            .onClick(() => {
              if (this.isPhoneValid()) {
                this.vm.prepayBuyTicket();
              }
            });
        }.width('100%').height(65).padding({ left: 16, right: 16 }).backgroundColor(CommonConstants.BG_COLOR_WHITE);
      }.width('100%').height(CommonConstants.FULL_HEIGHT).backgroundColor(CommonConstants.BG_COLOR_GRAY);

    }.title('购票信息').onReady(() => {
      this.vm.createTicketList();
    });

  }

  @Builder
  ticketListBuilder() {
    Column({ space: 10 }) {
      ForEach(this.vm.ticketList, (item: TicketListItem, index) => {
        if (index !== 0) {
          Divider();
        }
        Row() {
          Row({ space: 7 }) {
            Text(`参观人${item.sortId}`)
              .fontSize(CommonConstants.FONT_SIZE_M)
              .fontColor(CommonConstants.FONT_COLOR_BLACK)
              .fontWeight(500);
            Text(item.typeCn)
              .backgroundColor('#3392D6CC')
              .fontSize(CommonConstants.FONT_SIZE_XS)
              .fontColor(CommonConstants.FONT_COLOR_GREEN)
              .padding({ left: 4, right: 4 })
              .height(18)
              .borderRadius(4);
          };

          Row({ space: 5.5 }) {
            Image($r('app.media.icon_public_plus_1')).width(9);
            Text('常用参观人').fontSize(CommonConstants.FONT_SIZE_XS).fontColor(CommonConstants.FONT_COLOR_GREEN);
          }
          .width(82)
          .height(24)
          .borderRadius(12)
          .backgroundColor(CommonConstants.BG_COLOR_GREEN)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            RouterModule.push({ url: RouterMap.TICKET_OWNER, param: { ticketIndex: index } });
          });

        }.width('100%').justifyContent(FlexAlign.SpaceBetween);
      }, (item: TicketListItem) => item.sortId.toString());

    }.baseContainerStyle().margin({ top: 10 });
  }

  @Builder
  ticketInfoBuilder() {
    Column({ space: 10 }) {
      Text('门票信息')
        .fontSize(CommonConstants.FONT_SIZE_L)
        .fontColor(CommonConstants.FONT_COLOR_BLACK)
        .fontWeight(500)
        .margin({ top: 5 });
      ForEach(this.vm.selectTicketInfo, (item: TicketTypeInfo, index) => {
        if (item.count !== 0) {
          Row() {
            Text(item.typeCn).commonTextStyle().width(200);
            Text(`×${item.count}张`).commonTextStyle().width(50);
            Text('¥' + item.price).commonTextStyle().width(50).textAlign(TextAlign.End);
          }.width('100%').justifyContent(FlexAlign.SpaceBetween);
        }
      }, (item: TicketTypeInfo, index) => index.toString());
      Row() {
        Text('合计').commonTextStyle().width(200);
        Text(`×${this.vm.totalTicket}张`).commonTextStyle().width(50);
        Text('¥' + this.vm.totalPrice).commonTextStyle().width(50).textAlign(TextAlign.End);
      }.width('100%').justifyContent(FlexAlign.SpaceBetween);

      Divider();
      Text('参观时间：' + FormatUtil.dateAsISO(this.vm.currentSelected?.date) + ' ' + this.vm.selectedTime)
        .commonTextStyle();

    }.baseContainerStyle();
  }
}

@Extend(Text)
function commonTextStyle() {
  .fontSize(CommonConstants.FONT_SIZE_S).fontColor(CommonConstants.FONT_COLOR_BLACK);
}

@Extend(Column)
function baseContainerStyle() {
  .width('100%').padding(10).backgroundColor(CommonConstants.BG_COLOR_WHITE).alignItems(HorizontalAlign.Start);
}
