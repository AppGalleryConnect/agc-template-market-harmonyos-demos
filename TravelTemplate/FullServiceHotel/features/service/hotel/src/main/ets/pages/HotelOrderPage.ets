import { CommonButton, CommonDivider, CommonHeader } from 'componentlib';
import { HotelOrderPageVM } from '../viewmodels/HotelOrderPageVM';

@ComponentV2
export default struct HotelOrderPage {
  vm: HotelOrderPageVM = HotelOrderPageVM.instance;

  aboutToAppear(): void {
    this.vm.initData();
  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({ title: this.vm.pageTitle });
        Column() {
          this.roomInfoBuilder();
          this.orderInfoBuilder();
        }
        .padding({
          left: $r('app.string.padding_s'),
          right: $r('app.string.padding_s'),
        });

        Blank();
        this.paymentPanelBuilder();
      }
      .width($r('app.string.width_percent_full'))
      .height($r('app.string.height_percent_full'))
      .backgroundColor($r('app.color.system_color_background_auxiliary'));
    }
    .hideTitleBar(true);
  }

  @Builder
  roomInfoBuilder() {
    Column() {
      Row() {
        Text(this.vm.checkInData.checkInDateLabel)
          .mainLabelStyle()
          .margin({ right: $r('app.string.margin_xs') });
        Text(this.vm.checkInData.checkInDateDescription)
          .subLabelStyle();
        Text('⇀')
          .fontSize(14)
          .fontColor('#FF191919')
          .margin({ left: 7, right: 7 })
          .fontWeight(700);
        Text(this.vm.checkInData.checkOutDateLabel)
          .mainLabelStyle()
          .margin({ right: $r('app.string.margin_xs') });
        Text(this.vm.checkInData.checkOutDateDescription)
          .subLabelStyle();
        Text('|')
          .subLabelStyle()
          .margin({ left: $r('app.string.margin_s'), right: $r('app.string.margin_s') });
        Text('共' + this.vm.checkInData.totalDays + '晚')
          .mainLabelStyle();
      }
      .width($r('app.string.width_percent_full'))
      .margin({ bottom: $r('app.string.margin_s') });

      Row() {
        ForEach(this.vm.checkInData.roomTag, (item: string, index: number) => {
          if (index > 0) {
            Text('·')
              .mainLabelStyle()
              .margin({
                left: $r('app.string.margin_xs'),
                right: $r('app.string.margin_xs'),
              });
          }
          Text(item)
            .mainLabelStyle();
        }, (item: string, index: number) => JSON.stringify(item + index));
      };
    }
    .containerStyle();
  }

  @Builder
  orderInfoBuilder() {
    Column() {
      Text('入住信息')
        .mainLabelStyle()
        .margin({ bottom: $r('app.string.margin_s') });
      this.roomCountInfoBuilder();
      CommonDivider();
      this.nameInfoBuilder();
      CommonDivider();
      this.phoneNumberInfoBuilder();
    }
    .containerStyle();
  }

  @Builder
  roomCountInfoBuilder() {
    Row() {
      Text('房间数')
        .formLabelStyle()
        .width('20%');
      Row() {
        Image($r('app.media.icon_circle_subtract'))
          .height($r('app.integer.icon_size_20'))
          .margin({
            right: $r('app.string.margin_m'),
          })
          .fillColor(this.vm.checkInData.roomCount <= 1 ?
          $r('app.color.icon_color_level4') :
          $r('app.color.icon_color_level1'))
          .onClick(() => this.vm.updateRoomCount(-1));

        Text(this.vm.checkInData.roomCount.toString())
          .formLabelStyle();

        Image($r('app.media.icon_circle_add'))
          .height($r('app.integer.icon_size_20'))
          .margin({
            left: $r('app.string.margin_m'),
            right: $r('app.string.margin_s'),
          })
          .fillColor(this.vm.checkInData.roomCount >= this.vm.REMAIN_ROOM_NUMBER ?
          $r('app.color.icon_color_level4') :
          $r('app.color.icon_color_level1'))
          .onClick(() => this.vm.updateRoomCount(1));
      };
    }
    .width($r('app.string.width_percent_full'));
  }

  @Builder
  nameInfoBuilder() {
    Row() {
      Text('入住人')
        .formLabelStyle()
        .width('20%');
      TextInput({ text: this.vm.checkInData.guestName, placeholder: '请输入住客姓名' })
        .formInputStyle()
        .onChange((value: string) => {
          this.vm.checkInData.guestName = value;
        });
    }
    .width($r('app.string.width_percent_full'));
  }

  @Builder
  phoneNumberInfoBuilder() {
    Row() {
      Text('手机号')
        .formLabelStyle()
        .width('20%');
      TextInput({ text: this.vm.checkInData.guestPhone, placeholder: '请输入手机号' })
        .formInputStyle()
        .maxLength(11)
        .type(InputType.PhoneNumber)
        .onChange((value: string) => {
          this.vm.checkInData.guestPhone = value;
        });
    }
    .width($r('app.string.width_percent_full'));
  }

  @Builder
  paymentPanelBuilder() {
    Row() {
      Column() {
        Text() {
          Span('¥')
            .fontSize($r('app.string.font_size_24'));
          Span(this.vm.checkInData.actualPaidPrice)
            .fontSize($r('app.string.font_size_40'));
        }
        .fontColor($r('app.color.system_color_highlight'));

        Text('总额')
          .fontSize($r('app.string.font_size_24'))
          .fontColor($r('app.color.font_color_level2'));
      }
      .alignItems(HorizontalAlign.Start);

      CommonButton({
        title: '立即支付',
        fullWidth: false,
        handleClick: () => {
          this.vm.prepayRoom();
        },
      });
    }
    .width('100%')
    .backgroundColor($r('app.color.system_color_background_white'))
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: $r('app.string.padding_m'),
      right: $r('app.string.padding_m'),
      top: $r('app.string.padding_m'),
    });
  }
}

@Extend(Text)
function mainLabelStyle() {
  .fontSize($r('app.string.font_size_28'))
  .fontColor($r('app.color.font_color_level1'));
}

@Extend(Text)
function subLabelStyle() {
  .fontSize($r('app.string.font_size_20'))
  .fontColor($r('app.color.font_color_level2'));
}

@Extend(Text)
function formLabelStyle() {
  .fontSize($r('app.string.font_size_24'))
  .fontColor($r('app.color.font_color_level1'));
}

@Extend(TextInput)
function formInputStyle() {
  .type(InputType.Normal)
  .placeholderFont({ size: $r('app.string.font_size_24') })
  .fontSize($r('app.string.font_size_24'))
  .placeholderColor($r('app.color.font_color_level3'))
  .caretColor($r('app.color.system_color_focus'))
  .fontColor($r('app.color.font_color_level1'))
  .backgroundColor($r('app.color.system_color_background_white'))
  .textAlign(TextAlign.Start)
  .layoutWeight(1)
  .borderRadius(0)
  .padding(0)
  .margin(0);
}

@Extend(Column)
function containerStyle() {
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.system_color_background_white'))
  .borderRadius($r('app.string.border_radius_8'))
  .padding($r('app.string.padding_s'))
  .margin({ top: $r('app.string.margin_s') })
  .alignItems(HorizontalAlign.Start)
  .justifyContent(FlexAlign.Center);
}

@Builder
export function hotelOrderPageBuilder() {
  HotelOrderPage();
}