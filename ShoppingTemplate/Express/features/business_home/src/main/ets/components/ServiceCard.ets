import { LengthMetrics } from '@kit.ArkUI';
import { SkeletonType, UISkeleton } from '@hw-agconnect/ui-skeleton';
import { RouterMap, TelUtil } from 'lib_foundation';
import { HomePageVM } from '../viewModels/HomePageVM';
import { CommonButton } from './CommonButton';

@ComponentV2
export struct ServiceCard {
  vm: HomePageVM = HomePageVM.instance;
  @Param loading: boolean = false;

  @Builder
  buttonBuilder(image: ResourceStr, title: string, tip: string, func: Function) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Text(tip)
        .fontSize(10)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
    }
    .height(this.vm.isTabVertical ? 114 : 80)
    .padding({
      left: this.vm.breakPointModel.pagePadding,
      right: this.vm.breakPointModel.pagePadding,
      top: 14
    })
    .alignSelf(ItemAlign.Stretch)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#DEE9F6')
    .backgroundImage(image)
    .backgroundImageSize({ width: '100%', height: '100%' })
    .backgroundImageResizable({
      slice: {
        left: '10px',
        top: `54px`,
        right: `${this.vm.windowModel.windowWidth * 0.45}px`,
        bottom: '20px',
      },
    })
    .borderRadius(8)
    .onClick(() => {
      func()
    })
  }

  build() {
    Column() {
      UISkeleton({
        options: [{
          type: SkeletonType.RECT,
          radius: 16,
          width: '100%',
          height: this.vm.isTabVertical ? 264 : 196,
        }],
        loading: this.loading
      }) {
        Flex({ space: { main: LengthMetrics.vp(12) }}) {
          Column() {
            this.buttonBuilder($r('app.media.ic_get'), '上门取件', '专业小哥，上门服务', () => {
              this.vm.loginJumpPage(RouterMap.EXPRESS_PAGE);
            })
            this.buttonBuilder($r('app.media.ic_service'), '咨询客服', '在线客服，专业解答', () => {
              TelUtil.makeCall('联系客服', '0012356')
            })
          }
          .flexGrow(1)
          .height(this.vm.isTabVertical ? 240 : 172)
          .justifyContent(FlexAlign.SpaceBetween)

          Column() {
            Text('网购退换货')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .margin({ bottom: 4 })
            Text() {
              Span('低至')
              Span(' 4.8元 ')
                .fontColor('#0A59F7')
              Span('起！')
            }
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .margin({ bottom: 8 })

            CommonButton({ text: '立即寄件' })
          }
          .height(this.vm.isTabVertical ? 240 : 172)
          .flexGrow(1)
          .padding({
            left: this.vm.breakPointModel.pagePadding,
            right: this.vm.breakPointModel.pagePadding,
            top: 14
          })
          .alignItems(HorizontalAlign.Start)
          .backgroundColor('#E2F1F0')
          .backgroundImage($r('app.media.bg_return_exchange'))
          .backgroundImageSize({ width: '100%', height: '100%' })
          .backgroundImageResizable({
            slice: {
              left: '10px',
              top: `104px`,
              right: `${this.vm.windowModel.windowWidth * 0.45}px`,
              bottom: '20px',
            },
          })
          .borderRadius(8)
          .onClick(() => {
            this.vm.loginJumpPage(RouterMap.EXPRESS_PAGE);
          })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .padding(12)
        .borderRadius(16)
      }
    }
    .width('100%')
    .height(this.vm.isTabVertical ? 264 : 196)
    .margin({ top: 12 })
  }
}