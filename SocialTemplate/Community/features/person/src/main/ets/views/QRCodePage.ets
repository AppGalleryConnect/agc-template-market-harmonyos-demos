import { PersistenceV2 } from '@kit.ArkUI';
import { CommonHeader, UserInfo } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';

/**
 * @usage: 我的二维码页 展示当前用户二维码，支持返回
 * @layout: 页面采用纵向布局居中对齐：顶部是标题栏"我的二维码"（左对齐带返回按钮），中间通过 Blank
 * 占位后纵向居中排列二维码组件和描述文案，底部再用 Blank 填充实现垂直居中效果
 * @constraints: 组件使用 @Local userInfo 通过 PersistenceV2.connect
 * 持久化连接不可直接替换实例，二维码内容固定使用 userInfo.id 不可修改
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 我的二维码页
 * @subPage:
 * @component: OHPage,CommonHeader
 * @image: screenshot/person/person_qr.png
 */

@ComponentV2
struct QRCodePage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      useSafePadding: true,
      pageBackgroundColor: $r('sys.color.comp_background_gray')
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: $r('app.string.qrcode'),
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })

      Blank()

      QRCode(this.userInfo.id)
        .width(258)
        .height(258)
        .color($r('sys.color.comp_foreground_primary'))
        .backgroundColor($r('sys.color.background_primary'))
        .contentOpacity(1)
        .padding(25)

      Text($r('app.string.qrcode_desc'))
        .fontSize(12)
        .fontColor($r('app.color.color_66000000'))
        .margin({top: 20})

      Blank()
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}

@Builder
export function QRCodePageBuilder() {
  QRCodePage()
}
