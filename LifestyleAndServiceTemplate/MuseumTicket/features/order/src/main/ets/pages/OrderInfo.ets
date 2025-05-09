import { RouterMap, RouterModule, CommonConstants, FormatUtil } from 'commonlib';
import { Contacts } from 'network';
import { OrderTicketVM } from '../viewModels/OrderTicketVM';
import { promptAction } from '@kit.ArkUI';
import { AlertDialog } from '@kit.ArkUI';

@Builder
export function OrderInfoBuilder() {
  OrderInfo();
}


@ComponentV2
struct OrderInfo {
  vm: OrderTicketVM = OrderTicketVM.instance;
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '确定要删除该参观人吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.delContacts();
        },
      },
    }),
  });
  private reg = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;

  isContactInfoValid(): boolean {
    if (this.vm.confirmContacts.length === 0) {
      return false;
    }
    if (!this.vm.contactPhone) {
      return false;
    }
    return true;
  }

  isPhoneValid(): boolean {
    if (!this.reg.test(this.vm.contactPhone)) {
      this.vm.isWarning = true;
      promptAction.showToast({ message: '联系电话格式不正确！' });
      return false;
    }
    return true;
  }

  aboutToAppear(): void {
    this.vm.clearOrderInfo();
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Column() {
              Row({ space: 10 }) {
                if (this.vm.currentSelected) {
                  Text('预约时间：' + FormatUtil.dateAsISO(this.vm.currentSelected.date)).commonTitleStyle();
                }
                if (this.vm.selectedTime) {
                  Text(this.vm.timeMap.get(this.vm.selectedTime)).commonTitleStyle();
                }
              }.width('100%');

              Row({ space: 3 }) {
                Image($r('app.media.icon_public_plus_1')).width(13);
                Text('常用参观人')
                  .fontSize(CommonConstants.FONT_SIZE_M)
                  .fontColor(CommonConstants.FONT_COLOR_GREEN)
                  .onClick(() => {
                    RouterModule.push({ url: RouterMap.CONTACTS_PAGE });
                  });
              }
              .width(112)
              .margin({ top: 12, bottom: 16 })
              .backgroundColor(CommonConstants.BG_COLOR_GREEN)
              .height(32)
              .borderRadius(32)
              .justifyContent(FlexAlign.Center);

              if (this.vm.confirmContacts.length > 0) {
                Divider().margin({ bottom: 16 });
                Column({ space: 10 }) {
                  Text('参观人信息').commonTitleStyle();
                  ForEach(this.vm.confirmContacts, (item: Contacts, index) => {
                    Column({ space: 12 }) {
                      Row() {
                        Image($r('app.media.icon_public_trash')).width(16).onClick(() => {
                          this.vm.delIndex = index;
                          this.dialogControllerConfirm.open();
                        });
                      }.width('100%').position({ x: 0, y: 0 }).justifyContent(FlexAlign.End);

                      Text(item.name).commonTitleStyle();
                      Text('证件类型：' + item.cardType)
                        .fontColor(CommonConstants.FONT_COLOR_BLACK)
                        .fontSize(CommonConstants.FONT_SIZE_S);
                      Text('证件号码：' + item.cardID.substring(0, 6) + '********' + item.cardID.substring(14))
                        .fontColor(CommonConstants.FONT_COLOR_BLACK)
                        .fontSize(CommonConstants.FONT_SIZE_S);
                    }.commonCardStyle();
                  }, (item: Contacts, index) => item.personID);
                  Row() {
                    Row({ space: 4 }) {
                      Text('联系电话').commonTitleStyle();
                      if (this.vm.isWarning) {
                        Image($r('app.media.ic_public_warning')).width(14);
                      }
                    };

                    TextInput({ placeholder: '请输入联系电话', text: this.vm.contactPhone })
                      .onChange((res) => {
                        this.vm.contactPhone = res;
                        this.vm.isWarning = false;
                      })
                      .width(150)
                      .backgroundColor('transparent')
                      .padding({ left: 0, right: 0 })
                      .textAlign(TextAlign.End)
                      .fontSize(CommonConstants.FONT_SIZE_M)
                      .fontColor(CommonConstants.FONT_COLOR_BLACK);
                  }.width('100%').padding(10).justifyContent(FlexAlign.SpaceBetween);
                };
              }

            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .backgroundColor(CommonConstants.BG_COLOR_WHITE)
            .padding({
              left: 10,
              right: 10,
              top: 15,
              bottom: 10,
            })
            .constraintSize({ minHeight: 401 });

          };
        }.height('calc(100% - 75vp)').scrollBar(BarState.Off).align(Alignment.Top);


        Column() {
          Button('预约')
            .type(ButtonType.Normal)
            .borderRadius(20)
            .backgroundColor(this.isContactInfoValid() ?
            $r('app.color.font_color_green') : CommonConstants.BG_COLOR_GREEN)
            .width('calc(100% - 32vp)')
            .enabled(this.isContactInfoValid())
            .onClick(() => {
              if (this.isPhoneValid()) {
                this.vm.submitOrderInfo();
              }
            });
        }.justifyContent(FlexAlign.Center).height(75).backgroundColor(CommonConstants.BG_COLOR_GRAY);

      }.backgroundColor(CommonConstants.BG_COLOR_GRAY).padding({ top: 10 }).height(CommonConstants.FULL_HEIGHT);

    }.title('预约信息');

  }
}

@Extend(Column)
function commonCardStyle() {
  .alignItems(HorizontalAlign.Start)
  .width('100%')
  .height(93)
  .padding(10)
  .borderRadius(8)
  .backgroundColor('#3392D6CC');
}

@Extend(Text)
function commonTitleStyle() {
  .fontSize(CommonConstants.FONT_SIZE_L).fontColor(CommonConstants.FONT_COLOR_BLACK).fontWeight(500);
}
