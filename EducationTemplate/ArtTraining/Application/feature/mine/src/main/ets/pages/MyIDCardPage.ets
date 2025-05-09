import { AccountUtil, UserInfoModel } from 'commonlib';
import { CommonHeader } from 'componentlib';

@Builder
export function myIDCardPageBuilder() {
  MyIDCardPage();
}

@ComponentV2
export struct MyIDCardPage {
  @Local userInfo: UserInfoModel = AccountUtil.getUserInfo();

  build() {
    NavDestination() {
      CommonHeader({ title: '我的学员证' });
      Column() {
        this.infoCardBuilder();
      }
      .layoutWeight(1)
      .padding({
        left: $r('app.string.padding_xxl'),
        right: $r('app.string.padding_xxl'),
      })
      .width($r('app.string.width_percent_full'))
      .backgroundColor($r('app.color.system_color_background_auxiliary'));
    }
    .hideTitleBar(true);
  }

  @Builder
  infoCardBuilder() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.img_idcard'))
        .width($r('app.string.width_percent_full'));
      Column() {
        Image(this.userInfo.avatar)
          .width(64)
          .height(64)
          .borderRadius(32)
          .alt($r('app.media.ic_default_avatar'));
        Text(this.userInfo.nickname ? this.userInfo.nickname : '华为用户')
          .fontSize($r('app.string.font_size_20'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.system_color_background_white'))
          .margin({ top: $r('app.string.margin_l') });

        Row() {
          Column() {
            Text('学号: ').infoLabelStyle();
            Text('联系手机: ').infoLabelStyle();
            Text('微信号: ').infoLabelStyle();
            Text('生日: ').infoLabelStyle();
          }
          .alignItems(HorizontalAlign.Start)
          .width($r('app.string.width_percent_40'));

          Column() {
            Text(this.userInfo.studentID ? this.userInfo.studentID : '未获取')
              .infoContentStyle(this.userInfo.studentID);
            Text(this.userInfo.phone ? this.userInfo.phone : '未获取').infoContentStyle(this.userInfo.phone);
            Text(this.userInfo.wechat ? this.userInfo.wechat : '未编辑').infoContentStyle(this.userInfo.wechat);
            Text(this.userInfo.birthday ? this.userInfo.birthday : '未编辑').infoContentStyle(this.userInfo.birthday);
          }
          .alignItems(HorizontalAlign.Start);
        }
        .width($r('app.string.width_percent_75'))
        .margin({ top: 50 });
      }
      .margin({ top: 200 });

    }
    .width($r('app.string.width_percent_full'));
  }
}

@Extend(Text)
function infoLabelStyle() {
  .fontColor($r('app.color.font_color_info'))
  .fontSize($r('app.string.font_size_14'))
  .fontWeight(FontWeight.Medium)
  .margin({ bottom: $r('app.string.margin_l') });
}

@Extend(Text)
function infoContentStyle(content: string) {
  .fontColor(content ? $r('app.color.font_color_level1') : $r('app.color.font_color_level2'))
  .fontSize($r('app.string.font_size_14'))
  .fontWeight(FontWeight.Medium)
  .margin({ bottom: $r('app.string.margin_l') });
}