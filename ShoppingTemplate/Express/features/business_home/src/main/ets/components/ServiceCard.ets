import { RouterModule } from 'lib_foundation';
import { RouterMap, TelUtil } from 'module_base';
import { HomePageVM } from '../viewModels/HomePageVM';
import { CommonButton } from './CommonButton';

@ComponentV2
export struct ServiceCard {
  vm: HomePageVM = HomePageVM.instance;

  @Builder
  buttonBuilder(image: ResourceStr, title: string, tip: string, func: Function) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 14, bottom: 4, left: 12 })
      Text(tip)
        .fontSize(10)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 12 })
    }
    .width('100%')
    .height(80)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#DEE9F6')
    .backgroundImage(image)
    .backgroundImageSize(ImageSize.Cover)
    .borderRadius(8)
    .onClick(() => {
      if (!this.vm.userInfoModel.isLogin) {
        RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
        return
      }
      func()
    })
  }

  build() {
    Column() {
      Flex() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
          this.buttonBuilder($r('app.media.ic_get'), '上门取件', '专业小哥，上门服务', () => {
            RouterModule.push({ url: RouterMap.EXPRESS_PAGE })
          })
          this.buttonBuilder($r('app.media.ic_service'), '咨询客服', '在线客服，专业解答', () => {
            TelUtil.makeCall('联系客服', '10000000000')
          })
        }
        .width(146)
        .height(172)
        .margin({ right: 12 })

        Column() {
          Text('网购退换货')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 12, bottom: 4, left: 12 })
          Text() {
            Span('低至')
            Span(' 4.8元 ')
              .fontColor('#0A59F7')
            Span('起！')
          }
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ bottom: 4, left: 12 })

          CommonButton({ text: '立即寄件' })
            .margin({ left: 12 })
        }
        .height(172)
        .alignItems(HorizontalAlign.Start)
        .flexGrow(1)
        .backgroundColor('#E2F1F0')
        .backgroundImage($r('app.media.ic_change'))
        .backgroundImageSize(ImageSize.Cover)
        .borderRadius(8)
        .onClick(() => {
          if (this.vm.userInfoModel.isLogin) {
            RouterModule.push({ url: RouterMap.EXPRESS_PAGE })
          } else {
            RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
          }
        })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .padding(12)
      .borderRadius(16)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }
}