import { AccountUtil, UserInfoModel } from 'commonlib';

@ComponentV2
export struct VIPCard {
  @Local userInfo: UserInfoModel = AccountUtil.getUserInfo();

  build() {
    Stack({ alignContent: Alignment.Center }) {
      this.cardBackgroundBuilder();
      this.cardInfoBuilder();
    }
    .width('100%')
    .height('180lpx')
    .margin({
      bottom: $r('app.string.margin_m'),
    });
  }

  @Builder
  cardBackgroundBuilder() {
    Row() {
      Image($r('app.media.icon_vip_card_logo')).height('60%');
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
    .padding({ right: $r('app.string.padding_m') })
    .borderRadius($r('app.string.border_radius_16'))
    .linearGradient({
      angle: 142,
      colors: [[0xFF75ADF7, 0.002], [0xFF4A8CF3, 1.0]],
    });
  }

  @Builder
  cardInfoBuilder() {
    Column() {
      if (this.userInfo.memberInfo) {
        Row() {
          Text(`${this.userInfo.nickname ? this.userInfo.nickname : '华为用户'}，您好`)
            .fontColor(Color.White)
            .fontSize($r('app.string.font_size_32'))
            .fontWeight(700)
            .margin({
              right: $r('app.string.margin_s'),
            });

          Row() {
            Image($r('app.media.icon_vip'))
              .width(8);
            Text(this.userInfo.memberInfo.memberClassTName)
              .fontColor($r('app.color.font_color_level1_invert'))
              .fontSize($r('app.string.font_size_16'));
          }
          .height('32lpx')
          .borderRadius('16lpx')
          .backgroundColor('#34ffffff')
          .padding({
            left: '10lpx',
            right: '10lpx',
          });
        }
        .alignItems(VerticalAlign.Bottom)
        .margin({
          top: $r('app.string.margin_s'),
          bottom: $r('app.string.margin_s'),
          left: $r('app.string.margin_s'),
        });

        Blank();

        Row() {
          Text(`${this.userInfo.memberInfo.pointBalance ?? 0} `)
            .fontColor(Color.White)
            .fontSize($r('app.string.font_size_28'))
            .fontWeight(500)
            .fontStyle(FontStyle.Italic)
            .margin({ left: $r('app.string.margin_s') });
          Text('/ 5000')
            .fontSize($r('app.string.font_size_20'))
            .fontColor($r('app.color.icon_color_level2_invert'))
            .margin({ left: $r('app.string.margin_xs'), right: $r('app.string.margin_m') });

          Text(`距黄金级还需${5000 - Number(this.userInfo.memberInfo.pointBalance)}积分`)
            .fontSize($r('app.string.font_size_20'))
            .fontColor($r('app.color.icon_color_level1_invert'));
        }
        .alignItems(VerticalAlign.Bottom)
        .margin({ bottom: $r('app.string.margin_xs') });

        Progress({
          value: Number(this.userInfo.memberInfo.pointBalance),
          total: 5000,
          type: ProgressType.Linear,
        })
          .color('#FEF4DF')
          .style({
            strokeWidth: 5,
          })
          .width('60%')
          .margin({
            left: $r('app.string.margin_s'),
            bottom: $r('app.string.margin_xs'),
          })
          .backgroundColor($r('app.color.icon_color_level3_invert'));
      }
    }
    .width('100%')
    .height('100%')
    .padding($r('app.string.padding_s'))
    .alignItems(HorizontalAlign.Start);
  }
}