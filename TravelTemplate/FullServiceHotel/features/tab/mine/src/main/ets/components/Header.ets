import { CommonConstants, RouterMap, RouterModule, TelUtil } from 'commonlib';
import { MinePageVM } from '../viewModels/MinePageVM';

@ComponentV2
export struct Header {
  vm: MinePageVM = MinePageVM.instance;

  build() {
    Flex({
      alignItems: ItemAlign.Center,
    }) {
      Row() {
        // 头像
        Image(this.vm.userInfo.avatar)
          .width(40)
          .borderRadius(20)
          .alt($r('app.media.ic_default_avatar'))
          .margin({
            left: $r('app.string.margin_s'),
            right: $r('app.string.margin_s'),
          })
        // 用户名
        Text(this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '华为用户')
          .fontSize($r('app.string.font_size_36'))
          .fontWeight(600)
      }
      .justifyContent(FlexAlign.Start)
      .flexGrow(1)
      .onClick(() => {
        RouterModule.push({
          url: 'ProfileEditPage',
        });
      })

      // 二维码
      Image($r('app.media.ic_qrcode'))
        .width(20)
        .fillColor($r('app.color.icon_color_level1'))
        .margin({ right: $r('app.string.margin_m') })
        .onClick(() => RouterModule.push({ url: RouterMap.COMMON_QR_CODE }))
      // 联系客服
      Image($r('app.media.ic_custom_service'))
        .fillColor($r('app.color.icon_color_level1'))
        .margin({ right: $r('app.string.margin_s') })
        .width(20)
        .onClick(() => {
          TelUtil.makeCall(CommonConstants.TEL_NUMBER);;
        })
    }
    .margin({
      top: $r('app.string.margin_m'),
      bottom: $r('app.string.margin_m'),
    })
  }
}